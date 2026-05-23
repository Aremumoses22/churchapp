import prisma from '../../../config/database';
import { DonationStatus, PrayerRequestStatus, LiveServiceStatus } from '../../../generated/prisma/client';
import { subMonths, subWeeks, startOfMonth, startOfWeek, endOfMonth, endOfWeek, startOfYear, format } from 'date-fns';

function churchWhere(churchId: string | null | undefined) {
  return churchId ? { churchId } : {};
}

export const analyticsService = {
  async overview(churchId: string | null | undefined) {
    const where = churchWhere(churchId);
    const now = new Date();
    const startOfThisMonth = startOfMonth(now);
    const startOfThisYear = startOfYear(now);

    const [
      totalMembers,
      newMembersThisMonth,
      donationsYTD,
      donationsMTD,
      upcomingEvents,
      activePrayerRequests,
      activeGroups,
      liveCurrent,
    ] = await Promise.all([
      prisma.user.count({ where: { ...where, isActive: true } }),
      prisma.user.count({ where: { ...where, createdAt: { gte: startOfThisMonth } } }),
      prisma.donation.aggregate({
        where: { ...where, status: DonationStatus.SUCCESS, createdAt: { gte: startOfThisYear } },
        _sum: { amount: true },
      }),
      prisma.donation.aggregate({
        where: { ...where, status: DonationStatus.SUCCESS, createdAt: { gte: startOfThisMonth } },
        _sum: { amount: true },
      }),
      prisma.event.count({ where: { ...where, startDate: { gte: now } } }),
      prisma.prayerRequest.count({ where: { ...where, status: PrayerRequestStatus.ACTIVE } }),
      prisma.connectGroup.count({ where: { ...where, isActive: true } }),
      prisma.liveService.findFirst({ where: { ...where, status: LiveServiceStatus.LIVE }, select: { viewerCount: true } }),
    ]);

    return {
      totalMembers,
      newMembersThisMonth,
      totalDonationsYTD: donationsYTD._sum?.amount ?? 0,
      totalDonationsMTD: donationsMTD._sum?.amount ?? 0,
      upcomingEvents,
      activePrayerRequests,
      activeGroups,
      liveServiceViewers: liveCurrent?.viewerCount ?? 0,
    };
  },

  async givingTrend(churchId: string | null | undefined) {
    const where = churchWhere(churchId);
    const months: { month: string; total: number }[] = [];
    const now = new Date();

    for (let i = 11; i >= 0; i--) {
      const date = subMonths(now, i);
      const start = startOfMonth(date);
      const end = endOfMonth(date);
      const agg = await prisma.donation.aggregate({
        where: { ...where, status: DonationStatus.SUCCESS, createdAt: { gte: start, lte: end } },
        _sum: { amount: true },
      });
      months.push({ month: format(date, 'MMM yy'), total: agg._sum?.amount ?? 0 });
    }

    return months;
  },

  async attendanceTrend(churchId: string | null | undefined) {
    const where = churchWhere(churchId);
    const weeks: { week: string; count: number }[] = [];
    const now = new Date();

    for (let i = 11; i >= 0; i--) {
      const date = subWeeks(now, i);
      const start = startOfWeek(date, { weekStartsOn: 0 });
      const end = endOfWeek(date, { weekStartsOn: 0 });
      const count = await prisma.attendance.count({
        where: { ...where, serviceDate: { gte: start, lte: end } },
      });
      weeks.push({ week: format(start, 'dd MMM'), count });
    }

    return weeks;
  },

  async membershipGrowth(churchId: string | null | undefined) {
    const where = churchWhere(churchId);
    const months: { month: string; newMembers: number }[] = [];
    const now = new Date();

    for (let i = 11; i >= 0; i--) {
      const date = subMonths(now, i);
      const start = startOfMonth(date);
      const end = endOfMonth(date);
      const count = await prisma.user.count({
        where: { ...where, createdAt: { gte: start, lte: end } },
      });
      months.push({ month: format(date, 'MMM yy'), newMembers: count });
    }

    return months;
  },

  async engagement(churchId: string | null | undefined) {
    const where = churchWhere(churchId);
    const since = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);

    const [sermonPlays, eventRegistrations, forumPosts, prayerInteractions] = await Promise.all([
      prisma.userSermonProgress.count({ where: { sermon: { ...where }, lastPlayedAt: { gte: since } } }),
      prisma.eventRegistration.count({ where: { event: { ...where }, registeredAt: { gte: since } } }),
      prisma.forumThread.count({ where: { ...where, createdAt: { gte: since } } }),
      prisma.prayerInteraction.count({ where: { prayerRequest: { ...where }, createdAt: { gte: since } } }),
    ]);

    return { sermonPlays, eventRegistrations, forumPosts, prayerInteractions, periodDays: 30 };
  },
};
