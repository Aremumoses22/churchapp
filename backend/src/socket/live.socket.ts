// ═══════════════════════════════════════════════════════════════
// Live Service Socket — Real-time live streaming events
// ═══════════════════════════════════════════════════════════════

import { Server, Socket } from 'socket.io';
import prisma from '../config/database';
import { logger } from '../utils/logger';

export function setupLiveSocket(io: Server, socket: Socket): void {
  const user = socket.user!;

  // ── Join a live service room ───────────────────────
  socket.on('live:join', async (data: { liveServiceId: string }) => {
    try {
      const service = await prisma.liveService.findUnique({
        where: { id: data.liveServiceId },
      });

      if (!service || service.status === 'ENDED') {
        socket.emit('live:error', { message: 'Live service not available' });
        return;
      }

      socket.join(`live:${data.liveServiceId}`);

      // Increment viewer count
      await prisma.liveService.update({
        where: { id: data.liveServiceId },
        data: { viewerCount: { increment: 1 } },
      });

      const updated = await prisma.liveService.findUnique({
        where: { id: data.liveServiceId },
        select: { viewerCount: true },
      });

      io.to(`live:${data.liveServiceId}`).emit('live:viewers', {
        liveServiceId: data.liveServiceId,
        viewerCount: updated?.viewerCount || 0,
      });
    } catch (error) {
      logger.error('live:join error:', error);
    }
  });

  // ── Leave a live service room ──────────────────────
  socket.on('live:leave', async (data: { liveServiceId: string }) => {
    try {
      socket.leave(`live:${data.liveServiceId}`);

      // Decrement viewer count (min 0)
      const service = await prisma.liveService.findUnique({
        where: { id: data.liveServiceId },
        select: { viewerCount: true },
      });

      if (service && service.viewerCount > 0) {
        await prisma.liveService.update({
          where: { id: data.liveServiceId },
          data: { viewerCount: { decrement: 1 } },
        });
      }

      const updated = await prisma.liveService.findUnique({
        where: { id: data.liveServiceId },
        select: { viewerCount: true },
      });

      io.to(`live:${data.liveServiceId}`).emit('live:viewers', {
        liveServiceId: data.liveServiceId,
        viewerCount: updated?.viewerCount || 0,
      });
    } catch (error) {
      logger.error('live:leave error:', error);
    }
  });

  // ── Send a live chat message ───────────────────────
  socket.on('live:message', async (data: {
    liveServiceId: string;
    content: string;
    type?: string;
  }) => {
    try {
      const service = await prisma.liveService.findUnique({
        where: { id: data.liveServiceId },
        select: { status: true },
      });

      if (!service || service.status !== 'LIVE') {
        socket.emit('live:error', { message: 'Service is not live' });
        return;
      }

      const chatMsg = await prisma.liveChatMessage.create({
        data: {
          liveServiceId: data.liveServiceId,
          userId: user.id,
          content: data.content,
          type: (data.type as any) || 'MESSAGE',
        },
      });

      // Get user info for broadcast
      const userInfo = await prisma.user.findUnique({
        where: { id: user.id },
        select: { id: true, name: true, avatarUrl: true },
      });

      io.to(`live:${data.liveServiceId}`).emit('live:message', {
        id: chatMsg.id,
        user: userInfo,
        content: chatMsg.content,
        type: chatMsg.type,
        createdAt: chatMsg.createdAt,
      });
    } catch (error) {
      logger.error('live:message error:', error);
    }
  });

  // ── Send a reaction ────────────────────────────────
  socket.on('live:reaction', (data: { liveServiceId: string; emoji: string }) => {
    io.to(`live:${data.liveServiceId}`).emit('live:reaction', {
      userId: user.id,
      emoji: data.emoji,
    });
  });

  // ── Send a prayer request during live ──────────────
  socket.on('live:prayer', async (data: {
    liveServiceId: string;
    content: string;
  }) => {
    try {
      const chatMsg = await prisma.liveChatMessage.create({
        data: {
          liveServiceId: data.liveServiceId,
          userId: user.id,
          content: data.content,
          type: 'PRAYER',
        },
      });

      const userInfo = await prisma.user.findUnique({
        where: { id: user.id },
        select: { id: true, name: true, avatarUrl: true },
      });

      io.to(`live:${data.liveServiceId}`).emit('live:prayer', {
        id: chatMsg.id,
        user: userInfo,
        content: chatMsg.content,
        createdAt: chatMsg.createdAt,
      });
    } catch (error) {
      logger.error('live:prayer error:', error);
    }
  });
}
