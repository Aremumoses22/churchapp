// ═══════════════════════════════════════════════════════════════
// BullMQ Workers — Process jobs from all queues
// Phase 7: Background Job Processing
// ═══════════════════════════════════════════════════════════════

import { Worker, type Processor } from 'bullmq';
import { bullConnection, QUEUE_NAMES, JOB_NAMES } from './queue';
import { logger } from '../utils/logger';

// ── Import job processors ───────────────────────────
import {
  processRecurringDonations,
  sendPledgeReminders,
  updateCampaignTotals,
  sendGivingReceipt,
} from './processors/giving.processor';

import { sendEventReminders } from './processors/events.processor';

import {
  publishDailyDevotional,
  sendReadingPlanReminders,
} from './processors/devotionals.processor';

import { calculateAttendanceStreaks } from './processors/attendance.processor';

import { generateMilestones } from './processors/milestones.processor';

import {
  cleanupExpiredData,
  sendBirthdayGreetings,
  rebuildSearchIndexes,
} from './processors/maintenance.processor';

import { sendVolunteerShiftReminders } from './processors/volunteers.processor';

// ── Worker references ───────────────────────────────
const workers: Worker[] = [];

/**
 * Create a worker that routes jobs to the correct processor
 */
function createWorker(queueName: string, processors: Record<string, Processor>) {
  const worker = new Worker(
    queueName,
    async (job) => {
      const processor = processors[job.name];
      if (!processor) {
        logger.warn(`[Worker:${queueName}] Unknown job: ${job.name}`);
        return;
      }
      await processor(job);
    },
    {
      connection: bullConnection,
      concurrency: 3,
    },
  );

  worker.on('completed', (job) => {
    logger.info(`[Worker:${queueName}] ✅ ${job.name} completed (${job.id})`);
  });

  worker.on('failed', (job, error) => {
    logger.error(`[Worker:${queueName}] ❌ ${job?.name} failed (${job?.id}):`, error.message);
  });

  worker.on('error', (error) => {
    logger.error(`[Worker:${queueName}] Error:`, error.message);
  });

  workers.push(worker);
  logger.info(`👷 Worker started: ${queueName} (${Object.keys(processors).length} job types)`);
  return worker;
}

/**
 * Start all workers — call this during server bootstrap
 */
export function startWorkers(): void {
  logger.info('🔧 Starting BullMQ workers...');

  // Giving worker
  createWorker(QUEUE_NAMES.GIVING, {
    [JOB_NAMES.PROCESS_RECURRING_DONATIONS]: processRecurringDonations,
    [JOB_NAMES.SEND_PLEDGE_REMINDERS]: sendPledgeReminders,
    [JOB_NAMES.UPDATE_CAMPAIGN_TOTALS]: updateCampaignTotals,
    [JOB_NAMES.SEND_GIVING_RECEIPT]: sendGivingReceipt,
  });

  // Events worker
  createWorker(QUEUE_NAMES.EVENTS, {
    [JOB_NAMES.SEND_EVENT_REMINDERS]: sendEventReminders,
  });

  // Devotionals worker
  createWorker(QUEUE_NAMES.DEVOTIONALS, {
    [JOB_NAMES.PUBLISH_DAILY_DEVOTIONAL]: publishDailyDevotional,
    [JOB_NAMES.SEND_READING_PLAN_REMINDERS]: sendReadingPlanReminders,
  });

  // Attendance worker
  createWorker(QUEUE_NAMES.ATTENDANCE, {
    [JOB_NAMES.CALCULATE_ATTENDANCE_STREAKS]: calculateAttendanceStreaks,
  });

  // Milestones worker
  createWorker(QUEUE_NAMES.MILESTONES, {
    [JOB_NAMES.GENERATE_MILESTONES]: generateMilestones,
  });

  // Maintenance worker
  createWorker(QUEUE_NAMES.MAINTENANCE, {
    [JOB_NAMES.CLEANUP_EXPIRED_DATA]: cleanupExpiredData,
    [JOB_NAMES.SEND_BIRTHDAY_GREETINGS]: sendBirthdayGreetings,
    [JOB_NAMES.REBUILD_SEARCH_INDEXES]: rebuildSearchIndexes,
  });

  // Volunteers worker
  createWorker(QUEUE_NAMES.VOLUNTEERS, {
    [JOB_NAMES.SEND_VOLUNTEER_SHIFT_REMINDERS]: sendVolunteerShiftReminders,
  });

  logger.info('✅ All BullMQ workers started (7 workers, 12 job types)');
}

/**
 * Gracefully stop all workers
 */
export async function stopWorkers(): Promise<void> {
  logger.info('🛑 Stopping BullMQ workers...');
  await Promise.all(workers.map((w) => w.close()));
  workers.length = 0;
  logger.info('✅ All workers stopped');
}
