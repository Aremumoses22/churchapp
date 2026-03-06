import prisma from '../../config/database';
import { getRedis } from '../../config/redis';
import { ApiError } from '../../utils/apiError';
import { logger } from '../../utils/logger';
import type { RecordAttendanceInput, ListAttendanceInput } from './attendance.validation';

export const attendanceService = {
  // ────────────────────────────────────────────────────
  // RECORD ATTENDANCE
  // ────────────────────────────────────────────────────
  async recordAttendance(userId: string, churchId: string, input: RecordAttendanceInput) {
    // Check for duplicate attendance (same user, date, service type)
    const existing = await prisma.attendance.findUnique({
      where: {
        userId_serviceDate_serviceType: {
          userId,
          serviceDate: input.serviceDate,
          serviceType: input.serviceType,
        },
      },
    });

    if (existing) {
      throw ApiError.conflict('Attendance already recorded for this service');
    }

    const attendance = await prisma.attendance.create({
      data: {
        userId,
        churchId,
        serviceDate: input.serviceDate,
        serviceType: input.serviceType,
        checkinMethod: input.checkinMethod,
        notes: input.notes,
      },
    });

    logger.info(`Attendance recorded: ${userId} on ${input.serviceDate}`);
    return attendance;
  },

  // ────────────────────────────────────────────────────
  // GET ATTENDANCE HISTORY
  // ────────────────────────────────────────────────────
  async getAttendanceHistory(userId: string, query: ListAttendanceInput) {
    const { page, limit, startDate, endDate, serviceType } = query;

    const where: any = { userId };
    if (startDate) where.serviceDate = { ...where.serviceDate, gte: startDate };
    if (endDate) where.serviceDate = { ...where.serviceDate, lte: endDate };
    if (serviceType) where.serviceType = serviceType;

    const [attendances, total] = await Promise.all([
      prisma.attendance.findMany({
        where,
        orderBy: { serviceDate: 'desc' },
        skip: (page - 1) * limit,
        take: limit,
      }),
      prisma.attendance.count({ where }),
    ]);

    return {
      attendances,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit),
      },
    };
  },

  // ────────────────────────────────────────────────────
  // GET ATTENDANCE STREAK
  // ────────────────────────────────────────────────────
  async getAttendanceStreak(userId: string) {
    const redis = getRedis();

    // Try cache first
    const cachedStreak = await redis.get(`attendance:streak:${userId}`);
    const cachedTotal = await redis.get(`attendance:total:${userId}`);

    if (cachedStreak !== null) {
      return {
        currentStreak: parseInt(cachedStreak, 10),
        totalAttendances: cachedTotal ? parseInt(cachedTotal, 10) : 0,
      };
    }

    // Calculate on-the-fly if not cached
    const total = await prisma.attendance.count({ where: { userId } });
    const attendances = await prisma.attendance.findMany({
      where: { userId },
      orderBy: { serviceDate: 'desc' },
      select: { serviceDate: true },
    });

    // Calculate weekly streak
    let streak = 0;
    const weekMs = 7 * 24 * 60 * 60 * 1000;
    const attendedWeeks = new Set<string>();

    for (const att of attendances) {
      const date = new Date(att.serviceDate);
      const day = date.getDay();
      const mondayOffset = day === 0 ? -6 : 1 - day;
      const monday = new Date(date);
      monday.setDate(date.getDate() + mondayOffset);
      monday.setHours(0, 0, 0, 0);
      attendedWeeks.add(monday.toISOString().split('T')[0]);
    }

    const now = new Date();
    const currentMonday = new Date(now);
    const currentDay = currentMonday.getDay();
    const currentMondayOffset = currentDay === 0 ? -6 : 1 - currentDay;
    currentMonday.setDate(currentMonday.getDate() + currentMondayOffset);
    currentMonday.setHours(0, 0, 0, 0);

    const lastMonday = new Date(currentMonday);
    lastMonday.setDate(lastMonday.getDate() - 7);

    const currentWeekStr = currentMonday.toISOString().split('T')[0];
    const lastWeekStr = lastMonday.toISOString().split('T')[0];

    if (attendedWeeks.has(currentWeekStr) || attendedWeeks.has(lastWeekStr)) {
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

    // Cache results
    await redis.set(`attendance:streak:${userId}`, streak.toString(), 'EX', 86400);
    await redis.set(`attendance:total:${userId}`, total.toString(), 'EX', 86400);

    return {
      currentStreak: streak,
      totalAttendances: total,
    };
  },

  // ────────────────────────────────────────────────────
  // DELETE ATTENDANCE RECORD
  // ────────────────────────────────────────────────────
  async deleteAttendance(userId: string, attendanceId: string) {
    const attendance = await prisma.attendance.findFirst({
      where: { id: attendanceId, userId },
    });

    if (!attendance) {
      throw ApiError.notFound('Attendance record not found');
    }

    await prisma.attendance.delete({ where: { id: attendanceId } });

    // Invalidate cache
    const redis = getRedis();
    await redis.del(`attendance:streak:${userId}`, `attendance:total:${userId}`);

    return { message: 'Attendance record deleted' };
  },

  // ────────────────────────────────────────────────────
  // GET ATTENDANCE STATS (for church admins)
  // ────────────────────────────────────────────────────
  async getAttendanceStats(churchId: string) {
    const now = new Date();
    const thirtyDaysAgo = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);

    const [totalRecords, uniqueAttendees, recentRecords] = await Promise.all([
      prisma.attendance.count({ where: { churchId } }),
      prisma.attendance.groupBy({
        by: ['userId'],
        where: { churchId },
      }),
      prisma.attendance.count({
        where: { churchId, serviceDate: { gte: thirtyDaysAgo } },
      }),
    ]);

    // Attendance by service type
    const byServiceType = await prisma.attendance.groupBy({
      by: ['serviceType'],
      where: { churchId },
      _count: true,
    });

    return {
      totalRecords,
      uniqueAttendees: uniqueAttendees.length,
      last30Days: recentRecords,
      byServiceType: byServiceType.map((g) => ({
        serviceType: g.serviceType,
        count: g._count,
      })),
    };
  },
};
