// ═══════════════════════════════════════════════════════════════
// Maintenance Job Processors
// Phase 7: Background Job Processing
// ═══════════════════════════════════════════════════════════════

import type { Job } from 'bullmq';
import prisma from '../../config/database';
import { logger } from '../../utils/logger';
import { notifyBirthdayAnniversary } from '../../services/notification.triggers';

/**
 * Clean up expired data:
 * - Expired invite links
 * - Old read notifications (> 90 days)
 * - Expired verification & reset tokens
 */
export async function cleanupExpiredData(job: Job): Promise<void> {
  logger.info('[Job] Cleaning up expired data...');

  const now = new Date();
  const ninetyDaysAgo = new Date(now.getTime() - 90 * 24 * 60 * 60 * 1000);

  // Delete expired invite links
  const expiredInvites = await prisma.inviteLink.deleteMany({
    where: {
      expiresAt: { lte: now },
    },
  });

  // Delete old read notifications (older than 90 days)
  const oldNotifications = await prisma.notification.deleteMany({
    where: {
      isRead: true,
      createdAt: { lte: ninetyDaysAgo },
    },
  });

  // Clear expired verification tokens
  const expiredVerifications = await prisma.user.updateMany({
    where: {
      verificationExpires: { lte: now },
      emailVerified: false,
    },
    data: {
      verificationToken: null,
      verificationExpires: null,
    },
  });

  // Clear expired reset tokens
  const expiredResets = await prisma.user.updateMany({
    where: {
      resetTokenExpires: { lte: now },
    },
    data: {
      resetToken: null,
      resetTokenExpires: null,
    },
  });

  logger.info(
    `[Job] Cleanup results: ` +
    `${expiredInvites.count} invite links, ` +
    `${oldNotifications.count} old notifications, ` +
    `${expiredVerifications.count} expired verifications, ` +
    `${expiredResets.count} expired reset tokens`,
  );
}

/**
 * Send birthday greetings to users whose birthday is today.
 * Uses the user's joinedDate as a proxy for birthday (since we don't store DOB).
 * In a real app, you'd add a dateOfBirth field.
 */
export async function sendBirthdayGreetings(job: Job): Promise<void> {
  logger.info('[Job] Sending birthday / join-anniversary greetings...');

  const today = new Date();
  const month = today.getMonth() + 1; // 1-indexed
  const day = today.getDate();

  // Find users whose joinedDate month/day matches today (join anniversary)
  // Using raw query for date part extraction
  const users = await prisma.$queryRaw<Array<{ id: string; name: string; email: string; church_id: string }>>`
    SELECT id, name, email, church_id
    FROM users
    WHERE EXTRACT(MONTH FROM joined_date) = ${month}
      AND EXTRACT(DAY FROM joined_date) = ${day}
      AND is_active = true
      AND church_id IS NOT NULL
  `;

  let sent = 0;
  for (const user of users) {
    try {
      await notifyBirthdayAnniversary(user.id);
      sent++;
    } catch (error) {
      logger.error(`[Job] Failed birthday greeting for user ${user.id}:`, error);
    }
  }

  logger.info(`[Job] Birthday/anniversary greetings sent: ${sent} out of ${users.length}`);
}

/**
 * Rebuild search indexes by updating denormalized search data.
 * Ensures search results stay fresh.
 */
export async function rebuildSearchIndexes(job: Job): Promise<void> {
  logger.info('[Job] Rebuilding search indexes...');

  // Update sermon play counts from actual tracking data
  const sermons = await prisma.sermon.findMany({
    select: { id: true, _count: { select: { progress: true } } },
  });

  for (const sermon of sermons) {
    await prisma.sermon.update({
      where: { id: sermon.id },
      data: { playCount: sermon._count.progress },
    });
  }

  // Update forum thread reply counts
  const threads = await prisma.forumThread.findMany({
    select: { id: true, _count: { select: { replies: true } } },
  });

  for (const thread of threads) {
    await prisma.forumThread.update({
      where: { id: thread.id },
      data: { replyCount: thread._count.replies },
    });
  }

  // Update prayer request prayer counts
  const prayers = await prisma.prayerRequest.findMany({
    select: { id: true, _count: { select: { interactions: true } } },
  });

  for (const prayer of prayers) {
    await prisma.prayerRequest.update({
      where: { id: prayer.id },
      data: { prayerCount: prayer._count.interactions },
    });
  }

  logger.info(`[Job] Search indexes rebuilt: ${sermons.length} sermons, ${threads.length} threads, ${prayers.length} prayers`);
}
