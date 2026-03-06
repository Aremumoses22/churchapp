// ═══════════════════════════════════════════════════════════════
// Devotionals Job Processors
// Phase 7: Background Job Processing
// ═══════════════════════════════════════════════════════════════

import type { Job } from 'bullmq';
import prisma from '../../config/database';
import { logger } from '../../utils/logger';
import { notifyDailyDevotional, notifyReadingPlanReminder } from '../../services/notification.triggers';

/**
 * Publish daily devotional — sends push notifications to all users
 * when today's devotional is available.
 */
export async function publishDailyDevotional(job: Job): Promise<void> {
  logger.info('[Job] Publishing daily devotional...');

  const today = new Date();
  today.setHours(0, 0, 0, 0);

  // Find today's devotional
  const devotional = await prisma.devotional.findFirst({
    where: {
      date: today,
    },
    include: {
      church: { select: { id: true, name: true } },
    },
  });

  if (!devotional) {
    logger.info('[Job] No devotional found for today');
    return;
  }

  // Use sendToChurch to notify all members at once
  try {
    await notifyDailyDevotional(devotional.churchId, devotional.id, devotional.title);
    logger.info(`[Job] Daily devotional published: "${devotional.title}" to church ${devotional.churchId}`);
  } catch (error) {
    logger.error('[Job] Failed to send devotional notification:', error);
  }
}

/**
 * Send reading plan reminders to users who haven't completed today's reading.
 */
export async function sendReadingPlanReminders(job: Job): Promise<void> {
  logger.info('[Job] Sending reading plan reminders...');

  // Find active user reading plans (started but not completed)
  const activeUserPlans = await prisma.userReadingPlan.findMany({
    where: {
      completedAt: null,
      startedAt: { lte: new Date() },
    },
    include: {
      user: { select: { id: true, name: true, email: true } },
      plan: { select: { title: true, durationDays: true } },
      progress: true,
    },
  });

  let remindersSent = 0;
  for (const userPlan of activeUserPlans) {
    // Calculate what day they should be on
    const daysSinceStart = Math.floor(
      (Date.now() - new Date(userPlan.startedAt).getTime()) / (1000 * 60 * 60 * 24),
    );
    const currentDay = Math.min(daysSinceStart + 1, userPlan.plan.durationDays);

    // Check if they've completed today's reading
    const todaysProgress = userPlan.progress.find((p) => p.dayNumber === currentDay);
    if (todaysProgress?.completedAt) continue; // Already done today

    try {
      await notifyReadingPlanReminder(userPlan.userId, userPlan.planId);
      remindersSent++;
    } catch (error) {
      logger.error(`[Job] Failed reading plan reminder for user ${userPlan.userId}:`, error);
    }
  }

  logger.info(`[Job] Reading plan reminders sent: ${remindersSent} out of ${activeUserPlans.length}`);
}
