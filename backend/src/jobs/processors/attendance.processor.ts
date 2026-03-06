// ═══════════════════════════════════════════════════════════════
// Attendance Job Processors
// Phase 7: Background Job Processing
// ═══════════════════════════════════════════════════════════════

import type { Job } from 'bullmq';
import prisma from '../../config/database';
import { logger } from '../../utils/logger';
import { getRedis } from '../../config/redis';

/**
 * Calculate attendance streaks for all users.
 * A streak is the number of consecutive weeks a user has attended at least one service.
 * Stores streaks in Redis for fast access.
 */
export async function calculateAttendanceStreaks(job: Job): Promise<void> {
  logger.info('[Job] Calculating attendance streaks...');

  const redis = getRedis();

  // Get all users who have at least one attendance record
  const usersWithAttendance = await prisma.attendance.groupBy({
    by: ['userId'],
  });

  let calculated = 0;
  for (const { userId } of usersWithAttendance) {
    try {
      // Get all attendance records for this user, ordered by date desc
      const attendances = await prisma.attendance.findMany({
        where: { userId },
        orderBy: { serviceDate: 'desc' },
        select: { serviceDate: true },
      });

      if (attendances.length === 0) continue;

      // Calculate weekly streak
      let streak = 0;
      const now = new Date();
      const weekMs = 7 * 24 * 60 * 60 * 1000;

      // Get unique weeks (Mon-Sun) the user attended
      const attendedWeeks = new Set<string>();
      for (const att of attendances) {
        const date = new Date(att.serviceDate);
        // Get the Monday of that week
        const day = date.getDay();
        const mondayOffset = day === 0 ? -6 : 1 - day;
        const monday = new Date(date);
        monday.setDate(date.getDate() + mondayOffset);
        monday.setHours(0, 0, 0, 0);
        attendedWeeks.add(monday.toISOString().split('T')[0]);
      }

      // Sort weeks in descending order
      const sortedWeeks = Array.from(attendedWeeks).sort().reverse();

      // Calculate current streak from the most recent week
      const currentMonday = new Date(now);
      const currentDay = currentMonday.getDay();
      const currentMondayOffset = currentDay === 0 ? -6 : 1 - currentDay;
      currentMonday.setDate(currentMonday.getDate() + currentMondayOffset);
      currentMonday.setHours(0, 0, 0, 0);

      const lastMonday = new Date(currentMonday);
      lastMonday.setDate(lastMonday.getDate() - 7);

      // Check if user attended this week or last week
      const currentWeekStr = currentMonday.toISOString().split('T')[0];
      const lastWeekStr = lastMonday.toISOString().split('T')[0];

      if (!attendedWeeks.has(currentWeekStr) && !attendedWeeks.has(lastWeekStr)) {
        streak = 0;
      } else {
        // Count consecutive weeks backward
        let checkDate = attendedWeeks.has(currentWeekStr) ? currentMonday : lastMonday;
        while (true) {
          const weekStr = checkDate.toISOString().split('T')[0];
          if (attendedWeeks.has(weekStr)) {
            streak++;
            checkDate = new Date(checkDate.getTime() - weekMs);
          } else {
            break;
          }
        }
      }

      // Store in Redis with 24h TTL
      await redis.set(`attendance:streak:${userId}`, streak.toString(), 'EX', 86400);

      // Also store total attendance count
      await redis.set(`attendance:total:${userId}`, attendances.length.toString(), 'EX', 86400);

      calculated++;
    } catch (error) {
      logger.error(`[Job] Failed to calculate streak for user ${userId}:`, error);
    }
  }

  logger.info(`[Job] Attendance streaks calculated for ${calculated} users`);
}
