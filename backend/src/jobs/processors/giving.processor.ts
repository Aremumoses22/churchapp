// ═══════════════════════════════════════════════════════════════
// Giving Job Processors
// Phase 7: Background Job Processing
// ═══════════════════════════════════════════════════════════════

import type { Job } from 'bullmq';
import prisma from '../../config/database';
import { logger } from '../../utils/logger';
import { emailService } from '../../services/email.service';
import { notifyPledgeReminder } from '../../services/notification.triggers';

/**
 * Process recurring donations that are due today.
 * Finds all active recurring donations where next_charge_date <= now
 * and creates donation records for them.
 */
export async function processRecurringDonations(job: Job): Promise<void> {
  logger.info('[Job] Processing recurring donations...');

  const today = new Date();
  today.setHours(0, 0, 0, 0);

  const dueRecurring = await prisma.recurringDonation.findMany({
    where: {
      status: 'ACTIVE',
      nextChargeDate: { lte: today },
    },
    include: {
      user: { select: { id: true, name: true, email: true } },
      category: { select: { id: true, name: true } },
      church: { select: { id: true, name: true } },
    },
  });

  let processed = 0;
  let failed = 0;

  for (const recurring of dueRecurring) {
    try {
      // Create donation record
      const receiptNum = `REC-${Date.now()}-${Math.random().toString(36).slice(2, 6).toUpperCase()}`;
      await prisma.donation.create({
        data: {
          userId: recurring.userId,
          churchId: recurring.churchId,
          categoryId: recurring.categoryId,
          amount: recurring.amount,
          currency: recurring.currency,
          paymentMethod: 'CARD',
          paymentProvider: 'STRIPE',
          transactionRef: `auto-${recurring.id}-${Date.now()}`,
          receiptNumber: receiptNum,
          status: 'SUCCESS',
          metadata: { recurringDonationId: recurring.id },
        },
      });

      // Calculate next charge date based on frequency
      const nextDate = new Date(today);
      switch (recurring.frequency) {
        case 'WEEKLY': nextDate.setDate(nextDate.getDate() + 7); break;
        case 'BIWEEKLY': nextDate.setDate(nextDate.getDate() + 14); break;
        case 'MONTHLY': nextDate.setMonth(nextDate.getMonth() + 1); break;
        case 'QUARTERLY': nextDate.setMonth(nextDate.getMonth() + 3); break;
        case 'ANNUALLY': nextDate.setFullYear(nextDate.getFullYear() + 1); break;
        default: nextDate.setMonth(nextDate.getMonth() + 1);
      }

      // Update the recurring donation's next charge date
      await prisma.recurringDonation.update({
        where: { id: recurring.id },
        data: { nextChargeDate: nextDate, lastChargedAt: today },
      });

      // Send receipt email
      await emailService.sendGivingReceiptEmail(
        recurring.user.email,
        recurring.user.name,
        recurring.amount,
        recurring.currency,
        recurring.category?.name || 'General',
        recurring.church.name,
        receiptNum,
      );

      processed++;
    } catch (error) {
      logger.error(`[Job] Failed to process recurring donation ${recurring.id}:`, error);
      failed++;
    }
  }

  logger.info(`[Job] Recurring donations: ${processed} processed, ${failed} failed out of ${dueRecurring.length}`);
}

/**
 * Send pledge reminders for pledges nearing their target date.
 * Reminds users who have active pledges with remaining balance.
 */
export async function sendPledgeReminders(job: Job): Promise<void> {
  logger.info('[Job] Sending pledge reminders...');

  const thirtyDaysFromNow = new Date();
  thirtyDaysFromNow.setDate(thirtyDaysFromNow.getDate() + 30);

  const pledges = await prisma.pledge.findMany({
    where: {
      status: 'ACTIVE',
      endDate: { lte: thirtyDaysFromNow },
    },
    include: {
      user: { select: { id: true, name: true, email: true, fcmTokens: true } },
      campaign: { select: { title: true } },
    },
  });

  let sent = 0;
  for (const pledge of pledges) {
    const remaining = pledge.totalAmount - pledge.paidAmount;
    if (remaining <= 0) continue;

    try {
      // Send push notification
      await notifyPledgeReminder(pledge.userId, pledge.id, remaining);

      // Send email
      await emailService.sendPledgeReminderEmail(
        pledge.user.email,
        pledge.user.name,
        pledge.campaign?.title || 'Church Pledge',
        remaining,
        'USD',
        pledge.endDate,
      );

      sent++;
    } catch (error) {
      logger.error(`[Job] Failed to send pledge reminder for ${pledge.id}:`, error);
    }
  }

  logger.info(`[Job] Pledge reminders sent: ${sent} out of ${pledges.length}`);
}

/**
 * Update campaign totals by recalculating from actual donations.
 */
export async function updateCampaignTotals(job: Job): Promise<void> {
  logger.info('[Job] Updating campaign totals...');

  const campaigns = await prisma.givingCampaign.findMany({
    where: { isActive: true },
  });

  for (const campaign of campaigns) {
    const result = await prisma.donation.aggregate({
      where: {
        campaignId: campaign.id,
        status: 'SUCCESS',
      },
      _sum: { amount: true },
      _count: true,
    });

    await prisma.givingCampaign.update({
      where: { id: campaign.id },
      data: {
        raisedAmount: result._sum.amount || 0,
      },
    });
  }

  logger.info(`[Job] Updated ${campaigns.length} campaign totals`);
}

/**
 * Send giving receipt email (triggered on-demand after donation).
 */
export async function sendGivingReceipt(job: Job): Promise<void> {
  const { donationId } = job.data as { donationId: string };
  logger.info(`[Job] Sending giving receipt for donation ${donationId}`);

  const donation = await prisma.donation.findUnique({
    where: { id: donationId },
    include: {
      user: { select: { name: true, email: true } },
      category: { select: { name: true } },
      church: { select: { name: true } },
    },
  });

  if (!donation) {
    logger.warn(`[Job] Donation ${donationId} not found`);
    return;
  }

  await emailService.sendGivingReceiptEmail(
    donation.user.email,
    donation.user.name,
    donation.amount,
    donation.currency,
    donation.category?.name || 'General',
    donation.church.name,
    donation.receiptNumber || `DON-${donation.id.slice(0, 8).toUpperCase()}`,
  );

  logger.info(`[Job] Giving receipt sent for donation ${donationId}`);
}
