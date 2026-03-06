// ═══════════════════════════════════════════════════════════════
// BullMQ Queue Infrastructure
// Phase 7: Background Job Processing
// ═══════════════════════════════════════════════════════════════

import { Queue, type ConnectionOptions } from 'bullmq';
import env from '../config/env';
import { logger } from '../utils/logger';

// ── Redis connection for BullMQ ─────────────────────
// BullMQ requires maxRetriesPerRequest: null on the connection
const url = new URL(env.redisUrl);
export const bullConnection: ConnectionOptions = {
  host: url.hostname,
  port: parseInt(url.port || '6379', 10),
  password: url.password || undefined,
  db: parseInt(url.pathname?.slice(1) || '0', 10),
  maxRetriesPerRequest: null,
};

// ── Queue names ─────────────────────────────────────
export const QUEUE_NAMES = {
  GIVING: 'giving',
  EVENTS: 'events',
  DEVOTIONALS: 'devotionals',
  ATTENDANCE: 'attendance',
  MILESTONES: 'milestones',
  MAINTENANCE: 'maintenance',
  VOLUNTEERS: 'volunteers',
} as const;

// ── Job names ───────────────────────────────────────
export const JOB_NAMES = {
  // Giving queue
  PROCESS_RECURRING_DONATIONS: 'process-recurring-donations',
  SEND_PLEDGE_REMINDERS: 'send-pledge-reminders',
  UPDATE_CAMPAIGN_TOTALS: 'update-campaign-totals',
  SEND_GIVING_RECEIPT: 'send-giving-receipt',

  // Events queue
  SEND_EVENT_REMINDERS: 'send-event-reminders',

  // Devotionals queue
  PUBLISH_DAILY_DEVOTIONAL: 'publish-daily-devotional',
  SEND_READING_PLAN_REMINDERS: 'send-reading-plan-reminders',

  // Attendance queue
  CALCULATE_ATTENDANCE_STREAKS: 'calculate-attendance-streaks',

  // Milestones queue
  GENERATE_MILESTONES: 'generate-milestones',

  // Maintenance queue
  CLEANUP_EXPIRED_DATA: 'cleanup-expired-data',
  SEND_BIRTHDAY_GREETINGS: 'send-birthday-greetings',
  REBUILD_SEARCH_INDEXES: 'rebuild-search-indexes',

  // Volunteers queue
  SEND_VOLUNTEER_SHIFT_REMINDERS: 'send-volunteer-shift-reminders',
} as const;

// ── Create queues ───────────────────────────────────
const queueMap = new Map<string, Queue>();

export function getQueue(name: string): Queue {
  if (!queueMap.has(name)) {
    const queue = new Queue(name, {
      connection: bullConnection,
      defaultJobOptions: {
        attempts: 3,
        backoff: {
          type: 'exponential',
          delay: 5000,
        },
        removeOnComplete: { count: 100 },
        removeOnFail: { count: 500 },
      },
    });
    queueMap.set(name, queue);
    logger.info(`📋 Queue created: ${name}`);
  }
  return queueMap.get(name)!;
}

// ── Convenience: get all queues ─────────────────────
export function getAllQueues(): Queue[] {
  return Array.from(queueMap.values());
}

// ── Close all queues ────────────────────────────────
export async function closeAllQueues(): Promise<void> {
  for (const [name, queue] of queueMap) {
    await queue.close();
    logger.info(`📋 Queue closed: ${name}`);
  }
  queueMap.clear();
}
