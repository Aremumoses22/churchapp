// ═══════════════════════════════════════════════════════════════
// Notification Socket — Real-time notification push
// ═══════════════════════════════════════════════════════════════

import { Server, Socket } from 'socket.io';
import prisma from '../config/database';
import { logger } from '../utils/logger';

export function setupNotificationSocket(io: Server, socket: Socket): void {
  const user = socket.user!;

  // ── Mark notification as read (via socket) ─────────
  socket.on('notification:read', async (data: { notificationId: string }) => {
    try {
      await prisma.notification.update({
        where: { id: data.notificationId, userId: user.id },
        data: { isRead: true, readAt: new Date() },
      });

      socket.emit('notification:updated', {
        notificationId: data.notificationId,
        isRead: true,
      });
    } catch (error) {
      logger.error('notification:read error:', error);
    }
  });

  // ── Mark all notifications as read ─────────────────
  socket.on('notification:read-all', async () => {
    try {
      await prisma.notification.updateMany({
        where: { userId: user.id, isRead: false },
        data: { isRead: true, readAt: new Date() },
      });

      socket.emit('notification:all-read');
    } catch (error) {
      logger.error('notification:read-all error:', error);
    }
  });

  // ── Get unread count ───────────────────────────────
  socket.on('notification:unread-count', async () => {
    try {
      const count = await prisma.notification.count({
        where: { userId: user.id, isRead: false },
      });

      socket.emit('notification:unread-count', { count });
    } catch (error) {
      logger.error('notification:unread-count error:', error);
    }
  });
}
