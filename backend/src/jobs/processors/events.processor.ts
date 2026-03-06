// ═══════════════════════════════════════════════════════════════
// Events Job Processors
// Phase 7: Background Job Processing
// ═══════════════════════════════════════════════════════════════

import type { Job } from 'bullmq';
import prisma from '../../config/database';
import { logger } from '../../utils/logger';
import { notifyEventReminder } from '../../services/notification.triggers';

/**
 * Send event reminders — 24h and 1h before event start.
 * Runs every hour to catch upcoming events.
 */
export async function sendEventReminders(job: Job): Promise<void> {
  logger.info('[Job] Checking for upcoming event reminders...');

  const now = new Date();
  const oneHourFromNow = new Date(now.getTime() + 60 * 60 * 1000);
  const twentyFourHoursFromNow = new Date(now.getTime() + 24 * 60 * 60 * 1000);
  const twentyThreeHoursFromNow = new Date(now.getTime() + 23 * 60 * 60 * 1000);

  // Find events starting in ~24h (between 23h-24h window)
  const events24h = await prisma.event.findMany({
    where: {
      startDate: {
        gte: twentyThreeHoursFromNow,
        lte: twentyFourHoursFromNow,
      },
    },
    include: {
      registrations: {
        where: { status: 'REGISTERED' },
        include: {
          user: { select: { id: true, name: true, email: true } },
        },
      },
    },
  });

  // Find events starting in ~1h (between now and 1h)
  const events1h = await prisma.event.findMany({
    where: {
      startDate: {
        gte: now,
        lte: oneHourFromNow,
      },
    },
    include: {
      registrations: {
        where: { status: 'REGISTERED' },
        include: {
          user: { select: { id: true, name: true, email: true } },
        },
      },
    },
  });

  let remindersSent = 0;

  // 24h reminders — notifyEventReminder sends to all registrants internally
  for (const event of events24h) {
    try {
      await notifyEventReminder(event.id, '24 hours');
      remindersSent += event.registrations.length;
    } catch (error) {
      logger.error(`[Job] Failed 24h reminder for event ${event.id}:`, error);
    }
  }

  // 1h reminders
  for (const event of events1h) {
    try {
      await notifyEventReminder(event.id, '1 hour');
      remindersSent += event.registrations.length;
    } catch (error) {
      logger.error(`[Job] Failed 1h reminder for event ${event.id}:`, error);
    }
  }

  logger.info(`[Job] Event reminders sent: ${remindersSent} (24h events: ${events24h.length}, 1h events: ${events1h.length})`);
}
