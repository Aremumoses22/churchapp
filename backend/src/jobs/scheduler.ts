// ═══════════════════════════════════════════════════════════════
// BullMQ Scheduler — Recurring job schedules
// Phase 7: Background Job Processing
// ═══════════════════════════════════════════════════════════════

import { getQueue, QUEUE_NAMES, JOB_NAMES } from './queue';
import { logger } from '../utils/logger';

/**
 * Register all repeatable (cron-based) jobs.
 * Safe to call multiple times — BullMQ deduplicates repeatable jobs by key.
 */
export async function registerScheduledJobs(): Promise<void> {
  logger.info('⏰ Registering scheduled jobs...');

  // ── Giving jobs ─────────────────────────────────
  const givingQ = getQueue(QUEUE_NAMES.GIVING);

  // Process recurring donations — daily at 2 AM
  await givingQ.upsertJobScheduler(
    JOB_NAMES.PROCESS_RECURRING_DONATIONS,
    { pattern: '0 2 * * *' },
    { name: JOB_NAMES.PROCESS_RECURRING_DONATIONS, data: {} },
  );

  // Send pledge reminders — daily at 9 AM
  await givingQ.upsertJobScheduler(
    JOB_NAMES.SEND_PLEDGE_REMINDERS,
    { pattern: '0 9 * * *' },
    { name: JOB_NAMES.SEND_PLEDGE_REMINDERS, data: {} },
  );

  // Update campaign totals — every 30 minutes
  await givingQ.upsertJobScheduler(
    JOB_NAMES.UPDATE_CAMPAIGN_TOTALS,
    { pattern: '*/30 * * * *' },
    { name: JOB_NAMES.UPDATE_CAMPAIGN_TOTALS, data: {} },
  );

  // ── Events jobs ─────────────────────────────────
  const eventsQ = getQueue(QUEUE_NAMES.EVENTS);

  // Send event reminders — every hour
  await eventsQ.upsertJobScheduler(
    JOB_NAMES.SEND_EVENT_REMINDERS,
    { pattern: '0 * * * *' },
    { name: JOB_NAMES.SEND_EVENT_REMINDERS, data: {} },
  );

  // ── Devotionals jobs ────────────────────────────
  const devotionalsQ = getQueue(QUEUE_NAMES.DEVOTIONALS);

  // Publish daily devotional — daily at 5 AM
  await devotionalsQ.upsertJobScheduler(
    JOB_NAMES.PUBLISH_DAILY_DEVOTIONAL,
    { pattern: '0 5 * * *' },
    { name: JOB_NAMES.PUBLISH_DAILY_DEVOTIONAL, data: {} },
  );

  // Send reading plan reminders — daily at 8 AM
  await devotionalsQ.upsertJobScheduler(
    JOB_NAMES.SEND_READING_PLAN_REMINDERS,
    { pattern: '0 8 * * *' },
    { name: JOB_NAMES.SEND_READING_PLAN_REMINDERS, data: {} },
  );

  // ── Attendance jobs ─────────────────────────────
  const attendanceQ = getQueue(QUEUE_NAMES.ATTENDANCE);

  // Calculate attendance streaks — daily at 3 AM
  await attendanceQ.upsertJobScheduler(
    JOB_NAMES.CALCULATE_ATTENDANCE_STREAKS,
    { pattern: '0 3 * * *' },
    { name: JOB_NAMES.CALCULATE_ATTENDANCE_STREAKS, data: {} },
  );

  // ── Milestones jobs ─────────────────────────────
  const milestonesQ = getQueue(QUEUE_NAMES.MILESTONES);

  // Generate milestones — daily at 4 AM
  await milestonesQ.upsertJobScheduler(
    JOB_NAMES.GENERATE_MILESTONES,
    { pattern: '0 4 * * *' },
    { name: JOB_NAMES.GENERATE_MILESTONES, data: {} },
  );

  // ── Maintenance jobs ────────────────────────────
  const maintenanceQ = getQueue(QUEUE_NAMES.MAINTENANCE);

  // Cleanup expired data — daily at 1 AM
  await maintenanceQ.upsertJobScheduler(
    JOB_NAMES.CLEANUP_EXPIRED_DATA,
    { pattern: '0 1 * * *' },
    { name: JOB_NAMES.CLEANUP_EXPIRED_DATA, data: {} },
  );

  // Send birthday greetings — daily at 7 AM
  await maintenanceQ.upsertJobScheduler(
    JOB_NAMES.SEND_BIRTHDAY_GREETINGS,
    { pattern: '0 7 * * *' },
    { name: JOB_NAMES.SEND_BIRTHDAY_GREETINGS, data: {} },
  );

  // Rebuild search indexes — daily at midnight
  await maintenanceQ.upsertJobScheduler(
    JOB_NAMES.REBUILD_SEARCH_INDEXES,
    { pattern: '0 0 * * *' },
    { name: JOB_NAMES.REBUILD_SEARCH_INDEXES, data: {} },
  );

  // ── Volunteer jobs ──────────────────────────────
  const volunteerQ = getQueue(QUEUE_NAMES.VOLUNTEERS);

  // Send volunteer shift reminders — daily at 6 AM
  await volunteerQ.upsertJobScheduler(
    JOB_NAMES.SEND_VOLUNTEER_SHIFT_REMINDERS,
    { pattern: '0 6 * * *' },
    { name: JOB_NAMES.SEND_VOLUNTEER_SHIFT_REMINDERS, data: {} },
  );

  logger.info('✅ All scheduled jobs registered (12 jobs)');
}
