// ═══════════════════════════════════════════════════════════════
// Chat Socket — Real-time messaging events
// ═══════════════════════════════════════════════════════════════

import { Server, Socket } from 'socket.io';
import prisma from '../config/database';
import { logger } from '../utils/logger';

export function setupChatSocket(io: Server, socket: Socket): void {
  const user = socket.user!;

  // Join all user's conversation rooms on connect
  joinConversationRooms(socket, user.id).catch((err) =>
    logger.error('Failed to join conversation rooms:', err),
  );

  // ── Send a message ─────────────────────────────────
  socket.on('chat:message', async (data: {
    conversationId: string;
    content: string;
    type?: string;
    mediaUrl?: string;
    replyToId?: string;
  }) => {
    try {
      const { conversationId, content, type, mediaUrl, replyToId } = data;

      // Verify user is a member of the conversation
      const membership = await prisma.conversationMember.findUnique({
        where: {
          conversationId_userId: { conversationId, userId: user.id },
        },
      });

      if (!membership) {
        socket.emit('chat:error', { message: 'Not a member of this conversation' });
        return;
      }

      // Create the message
      const message = await prisma.message.create({
        data: {
          conversationId,
          senderId: user.id,
          content,
          type: (type as any) || 'TEXT',
          mediaUrl,
          replyToId,
        },
        include: {
          sender: {
            select: { id: true, name: true, avatarUrl: true },
          },
          replyTo: {
            select: {
              id: true,
              content: true,
              sender: { select: { id: true, name: true } },
            },
          },
        },
      });

      // Update conversation's lastMessageAt
      await prisma.conversation.update({
        where: { id: conversationId },
        data: { lastMessageAt: new Date() },
      });

      // Broadcast to all members in the conversation room
      io.to(`conversation:${conversationId}`).emit('chat:message', {
        message,
        conversationId,
      });
    } catch (error) {
      logger.error('chat:message error:', error);
      socket.emit('chat:error', { message: 'Failed to send message' });
    }
  });

  // ── Typing indicator ───────────────────────────────
  socket.on('chat:typing', (data: { conversationId: string; isTyping: boolean }) => {
    socket.to(`conversation:${data.conversationId}`).emit('chat:typing', {
      userId: user.id,
      conversationId: data.conversationId,
      isTyping: data.isTyping,
    });
  });

  // ── Mark conversation as read ──────────────────────
  socket.on('chat:read', async (data: { conversationId: string }) => {
    try {
      await prisma.conversationMember.update({
        where: {
          conversationId_userId: { conversationId: data.conversationId, userId: user.id },
        },
        data: { lastReadAt: new Date() },
      });

      io.to(`conversation:${data.conversationId}`).emit('chat:read', {
        userId: user.id,
        conversationId: data.conversationId,
        readAt: new Date().toISOString(),
      });
    } catch (error) {
      logger.error('chat:read error:', error);
    }
  });

  // ── Join a conversation room (after creating/being added) ──
  socket.on('chat:join', (data: { conversationId: string }) => {
    socket.join(`conversation:${data.conversationId}`);
  });
}

/**
 * Join all conversation rooms for a user on connect
 */
async function joinConversationRooms(socket: Socket, userId: string): Promise<void> {
  const memberships = await prisma.conversationMember.findMany({
    where: { userId },
    select: { conversationId: true },
  });

  for (const m of memberships) {
    socket.join(`conversation:${m.conversationId}`);
  }
}
