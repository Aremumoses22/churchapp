// ═══════════════════════════════════════════════════════════════
// Central Notification Service
// Handles creating DB notifications, sending push, and socket emit
// ═══════════════════════════════════════════════════════════════

import prisma from '../config/database';
import { pushService } from './push.service';
import { emitToUser, emitToChurch } from '../socket/index';
import { logger } from '../utils/logger';
import type { NotificationType } from '../generated/prisma/client';

interface NotificationPayload {
  type: NotificationType;
  title: string;
  body: string;
  data?: Record<string, string>; // entityId, entityType, deepLink
}

/**
 * Central notification dispatcher
 * 1. Creates a DB notification record
 * 2. Emits via Socket.io for real-time delivery
 * 3. Sends FCM push notification if user has tokens + prefs allow it
 */
export const notificationService = {
  /**
   * Send notification to a single user
   */
  async sendToUser(userId: string, payload: NotificationPayload): Promise<void> {
    try {
      // 1. Create DB record
      const notification = await prisma.notification.create({
        data: {
          userId,
          type: payload.type,
          title: payload.title,
          body: payload.body,
          data: payload.data || {},
        },
      });

      // 2. Emit via Socket.io
      emitToUser(userId, 'notification:new', {
        id: notification.id,
        type: notification.type,
        title: notification.title,
        body: notification.body,
        data: notification.data,
        isRead: false,
        createdAt: notification.createdAt,
      });

      // 3. Send FCM push if user has tokens and notification prefs allow it
      await sendPushToUser(userId, payload);
    } catch (error) {
      logger.error(`Failed to send notification to user ${userId}:`, error);
    }
  },

  /**
   * Send notification to multiple users
   */
  async sendToUsers(userIds: string[], payload: NotificationPayload): Promise<void> {
    // Batch create notifications
    const promises = userIds.map((userId) => this.sendToUser(userId, payload));
    await Promise.allSettled(promises);
  },

  /**
   * Send notification to all members of a church
   */
  async sendToChurch(churchId: string, payload: NotificationPayload, excludeUserId?: string): Promise<void> {
    try {
      // Get all active church members
      const members = await prisma.user.findMany({
        where: {
          churchId,
          isActive: true,
          ...(excludeUserId ? { NOT: { id: excludeUserId } } : {}),
        },
        select: { id: true },
      });

      const userIds = members.map((m) => m.id);

      // Create notifications in bulk
      if (userIds.length > 0) {
        await prisma.notification.createMany({
          data: userIds.map((userId) => ({
            userId,
            type: payload.type,
            title: payload.title,
            body: payload.body,
            data: payload.data || {},
          })),
        });
      }

      // Emit via Socket.io to church room
      emitToChurch(churchId, 'notification:new', {
        type: payload.type,
        title: payload.title,
        body: payload.body,
        data: payload.data,
        createdAt: new Date(),
      });

      // Send push notifications to all members
      await sendPushToMultipleUsers(userIds, payload);

      logger.info(`Notification sent to ${userIds.length} church members: ${payload.title}`);
    } catch (error) {
      logger.error(`Failed to send church notification:`, error);
    }
  },

  /**
   * Get notifications for a user (paginated)
   */
  async getUserNotifications(
    userId: string,
    options: { page?: number; limit?: number; type?: string; unreadOnly?: boolean },
  ) {
    const page = options.page || 1;
    const limit = options.limit || 20;
    const skip = (page - 1) * limit;

    const where: any = { userId };
    if (options.type) where.type = options.type;
    if (options.unreadOnly) where.isRead = false;

    const [notifications, total] = await Promise.all([
      prisma.notification.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip,
        take: limit,
      }),
      prisma.notification.count({ where }),
    ]);

    return {
      notifications,
      meta: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  },

  /**
   * Mark a single notification as read
   */
  async markAsRead(notificationId: string, userId: string) {
    return prisma.notification.update({
      where: { id: notificationId, userId },
      data: { isRead: true, readAt: new Date() },
    });
  },

  /**
   * Mark all notifications as read for a user
   */
  async markAllAsRead(userId: string) {
    return prisma.notification.updateMany({
      where: { userId, isRead: false },
      data: { isRead: true, readAt: new Date() },
    });
  },

  /**
   * Get unread notification count
   */
  async getUnreadCount(userId: string): Promise<number> {
    return prisma.notification.count({
      where: { userId, isRead: false },
    });
  },

  /**
   * Delete old notifications (cleanup — older than 90 days)
   */
  async cleanupOldNotifications(daysOld = 90): Promise<number> {
    const cutoff = new Date();
    cutoff.setDate(cutoff.getDate() - daysOld);

    const result = await prisma.notification.deleteMany({
      where: { createdAt: { lt: cutoff } },
    });

    return result.count;
  },
};

// ── Private helpers ──────────────────────────────────────

/**
 * Check user notification preferences to see if this type is allowed
 */
function isNotificationAllowed(prefs: Record<string, any>, type: string): boolean {
  // Default: allow all if no prefs configured
  if (!prefs || Object.keys(prefs).length === 0) return true;

  // Map notification type to preference key
  const prefMap: Record<string, string> = {
    SERMON: 'sermons',
    EVENT: 'events',
    CHAT: 'messages',
    GIVING: 'giving',
    PRAYER: 'prayerRequests',
    ANNOUNCEMENT: 'announcements',
    GROUP: 'groups',
    FORUM: 'forum',
    VOLUNTEER: 'volunteer',
    DEVOTIONAL: 'devotionals',
    PERSONAL: 'personal',
    SECURITY: 'security',
    SYSTEM: 'system',
  };

  const prefKey = prefMap[type];
  if (!prefKey) return true;

  // If explicitly set to false, don't send
  return prefs[prefKey] !== false;
}

/**
 * Send FCM push notification to a user if they have tokens and prefs allow it
 */
async function sendPushToUser(userId: string, payload: NotificationPayload): Promise<void> {
  try {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { fcmTokens: true, notificationPrefs: true },
    });

    if (!user || user.fcmTokens.length === 0) return;

    const prefs = (user.notificationPrefs as Record<string, any>) || {};
    if (!isNotificationAllowed(prefs, payload.type)) return;

    const failedTokens = await pushService.sendToMultiple(user.fcmTokens, {
      title: payload.title,
      body: payload.body,
      data: {
        ...payload.data,
        type: payload.type,
      },
    });

    // Clean up stale tokens
    if (failedTokens.length > 0) {
      const validTokens = user.fcmTokens.filter((t) => !failedTokens.includes(t));
      await prisma.user.update({
        where: { id: userId },
        data: { fcmTokens: validTokens },
      });
    }
  } catch (error) {
    logger.error(`Failed to send push to user ${userId}:`, error);
  }
}

/**
 * Send FCM push notification to multiple users
 */
async function sendPushToMultipleUsers(
  userIds: string[],
  payload: NotificationPayload,
): Promise<void> {
  if (userIds.length === 0) return;

  try {
    const users = await prisma.user.findMany({
      where: { id: { in: userIds } },
      select: { id: true, fcmTokens: true, notificationPrefs: true },
    });

    const allTokens: string[] = [];
    for (const user of users) {
      if (user.fcmTokens.length === 0) continue;
      const prefs = (user.notificationPrefs as Record<string, any>) || {};
      if (!isNotificationAllowed(prefs, payload.type)) continue;
      allTokens.push(...user.fcmTokens);
    }

    if (allTokens.length > 0) {
      await pushService.sendToMultiple(allTokens, {
        title: payload.title,
        body: payload.body,
        data: {
          ...payload.data,
          type: payload.type,
        },
      });
    }
  } catch (error) {
    logger.error('Failed to send push to multiple users:', error);
  }
}
