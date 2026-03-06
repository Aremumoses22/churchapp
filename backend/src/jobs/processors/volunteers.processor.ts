// ═══════════════════════════════════════════════════════════════
// Volunteer Job Processors
// Phase 7: Background Job Processing
// ═══════════════════════════════════════════════════════════════

import type { Job } from 'bullmq';
import prisma from '../../config/database';
import { logger } from '../../utils/logger';
import { notifyVolunteerShiftReminder } from '../../services/notification.triggers';
import { emailService } from '../../services/email.service';

/**
 * Send volunteer shift reminders 24h before scheduled shifts.
 */
export async function sendVolunteerShiftReminders(job: Job): Promise<void> {
  logger.info('[Job] Sending volunteer shift reminders...');

  const now = new Date();
  const tomorrow = new Date(now.getTime() + 24 * 60 * 60 * 1000);
  const twentyThreeHours = new Date(now.getTime() + 23 * 60 * 60 * 1000);

  // Find shifts happening in ~24h
  const upcomingShifts = await prisma.rosterShift.findMany({
    where: {
      date: {
        gte: twentyThreeHours,
        lte: tomorrow,
      },
      status: 'SCHEDULED',
    },
    include: {
      user: { select: { id: true, name: true, email: true } },
      opportunity: { select: { title: true, department: true } },
    },
  });

  let sent = 0;
  for (const shift of upcomingShifts) {
    try {
      await notifyVolunteerShiftReminder(
        shift.userId,
        shift.date.toISOString().split('T')[0],
        shift.startTime,
        shift.opportunity.title,
      );

      await emailService.sendVolunteerShiftEmail(
        shift.user.email,
        shift.user.name,
        shift.opportunity.title,
        shift.opportunity.department,
        shift.date,
        shift.startTime,
        shift.endTime,
      );

      sent++;
    } catch (error) {
      logger.error(`[Job] Failed shift reminder for shift ${shift.id}:`, error);
    }
  }

  logger.info(`[Job] Volunteer shift reminders sent: ${sent} out of ${upcomingShifts.length}`);
}
