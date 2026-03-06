import prisma from '../../config/database';
import { ApiError } from '../../utils/apiError';

export const homeService = {
  /**
   * Get home feed aggregation for a user
   * Returns: verse of the day, latest sermon, featured sermons,
   * upcoming events, devotional info, reading plan progress, live status
   */
  async getFeed(userId: string, churchId: string) {
    const now = new Date();
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());

    // Run all queries in parallel for speed
    const [
      church,
      latestSermon,
      featuredSermons,
      upcomingEvents,
      todayDevotional,
      activeReadingPlans,
      verseOfTheDay,
      devotionalStreak,
      activeCampaign,
      recentAnnouncements,
      urgentPrayerRequests,
    ] = await Promise.all([
      // Church basic info (for live stream status, etc.)
      prisma.church.findUnique({
        where: { id: churchId },
        select: {
          id: true,
          name: true,
          logoUrl: true,
          settings: true,
        },
      }),

      // Latest sermon
      prisma.sermon.findFirst({
        where: { churchId, date: { lte: now } },
        orderBy: { date: 'desc' },
        select: {
          id: true,
          title: true,
          speaker: true,
          thumbnailUrl: true,
          duration: true,
          date: true,
          series: { select: { id: true, title: true } },
        },
      }),

      // Featured sermons (up to 5)
      prisma.sermon.findMany({
        where: { churchId, isFeatured: true, date: { lte: now } },
        orderBy: { date: 'desc' },
        take: 5,
        select: {
          id: true,
          title: true,
          speaker: true,
          thumbnailUrl: true,
          duration: true,
          date: true,
          series: { select: { id: true, title: true } },
        },
      }),

      // Upcoming events (next 5)
      prisma.event.findMany({
        where: {
          churchId,
          startDate: { gte: now },
        },
        orderBy: { startDate: 'asc' },
        take: 5,
        select: {
          id: true,
          title: true,
          imageUrl: true,
          startDate: true,
          endDate: true,
          location: true,
          category: true,
          isFeatured: true,
        },
      }),

      // Today's devotional
      prisma.devotional.findFirst({
        where: {
          churchId,
          date: {
            gte: today,
            lt: new Date(today.getTime() + 24 * 60 * 60 * 1000),
          },
        },
        select: {
          id: true,
          title: true,
          scriptureRef: true,
          content: true,
          authorName: true,
          date: true,
        },
      }),

      // User's active reading plans
      prisma.userReadingPlan.findMany({
        where: {
          userId,
          completedAt: null,
        },
        take: 3,
        include: {
          plan: {
            select: {
              id: true,
              title: true,
              imageUrl: true,
              durationDays: true,
            },
          },
          progress: {
            select: { id: true },
          },
        },
      }),

      // Verse of the day — pick a deterministic verse based on the day
      getVerseOfTheDay(today),

      // Devotional streak
      getDevotionalStreak(userId),

      // Active giving campaign (most recent)
      prisma.givingCampaign.findFirst({
        where: { churchId, isActive: true },
        orderBy: { startDate: 'desc' },
        select: {
          id: true,
          title: true,
          goalAmount: true,
          raisedAmount: true,
          endDate: true,
        },
      }),

      // Recent announcements (Phase 4) — latest 3 non-expired
      prisma.announcement.findMany({
        where: {
          churchId,
          publishedAt: { lte: now },
          OR: [{ expiresAt: null }, { expiresAt: { gt: now } }],
        },
        orderBy: [{ isUrgent: 'desc' }, { isPinned: 'desc' }, { publishedAt: 'desc' }],
        take: 3,
        select: {
          id: true,
          title: true,
          content: true,
          isUrgent: true,
          isPinned: true,
          publishedAt: true,
        },
      }),

      // Urgent prayer requests (Phase 4) — latest 3 urgent+active
      prisma.prayerRequest.findMany({
        where: {
          churchId,
          status: 'ACTIVE',
          isUrgent: true,
        },
        orderBy: { createdAt: 'desc' },
        take: 3,
        select: {
          id: true,
          title: true,
          prayerCount: true,
          createdAt: true,
        },
      }),
    ]);

    if (!church) throw ApiError.notFound('Church not found');

    // Check user's sermon progress for the latest sermon
    let sermonProgress: { position: number; completed: boolean } | null = null;
    if (latestSermon) {
      const progress = await prisma.userSermonProgress.findUnique({
        where: {
          userId_sermonId: { userId, sermonId: latestSermon.id },
        },
        select: { position: true, completed: true },
      });
      sermonProgress = progress;
    }

    // Check if user read today's devotional
    let devotionalRead = false;
    if (todayDevotional) {
      const read = await prisma.userDevotionalRead.findUnique({
        where: {
          userId_devotionalId: { userId, devotionalId: todayDevotional.id },
        },
      });
      devotionalRead = !!read;
    }

    // Transform reading plans with progress percentage
    const readingPlans = activeReadingPlans.map((urp) => ({
      enrollmentId: urp.id,
      plan: urp.plan,
      completedDays: urp.progress.length,
      totalDays: urp.plan.durationDays,
      progressPercent: Math.round((urp.progress.length / urp.plan.durationDays) * 100),
      startedAt: urp.startedAt,
    }));

    const settings = (church.settings as Record<string, unknown>) || {};

    return {
      church: {
        id: church.id,
        name: church.name,
        logoUrl: church.logoUrl,
        isLive: false, // Will be managed via WebSocket in a later phase
        livestreamUrl: (settings.livestreamUrl as string) || null,
      },
      verseOfTheDay,
      latestSermon: latestSermon
        ? {
            ...latestSermon,
            progress: sermonProgress,
          }
        : null,
      featuredSermons,
      upcomingEvents,
      devotional: todayDevotional
        ? {
            ...todayDevotional,
            content: todayDevotional.content.substring(0, 200) + '…', // Preview only
            isRead: devotionalRead,
          }
        : null,
      devotionalStreak,
      readingPlans,
      activeCampaign: activeCampaign
        ? {
            id: activeCampaign.id,
            title: activeCampaign.title,
            goal: activeCampaign.goalAmount,
            raised: activeCampaign.raisedAmount,
            percentage: activeCampaign.goalAmount > 0
              ? Math.min(100, Math.round((activeCampaign.raisedAmount / activeCampaign.goalAmount) * 100))
              : 0,
            endDate: activeCampaign.endDate,
          }
        : null,
      announcements: recentAnnouncements.map((a) => ({
        id: a.id,
        title: a.title,
        content: a.content.substring(0, 150) + (a.content.length > 150 ? '…' : ''),
        isUrgent: a.isUrgent,
        isPinned: a.isPinned,
        publishedAt: a.publishedAt,
      })),
      urgentPrayerRequests: urgentPrayerRequests.map((p) => ({
        id: p.id,
        title: p.title,
        prayerCount: p.prayerCount,
        createdAt: p.createdAt,
      })),
    };
  },
};

// ── Helper functions ─────────────────────────────────────

/**
 * Get a deterministic "verse of the day" from the BibleVerse table.
 * Uses the day-of-year as a seed to pick a verse.
 */
async function getVerseOfTheDay(today: Date) {
  // Day of year (1-365)
  const start = new Date(today.getFullYear(), 0, 0);
  const diff = today.getTime() - start.getTime();
  const dayOfYear = Math.floor(diff / (1000 * 60 * 60 * 24));

  // Count available verses
  const totalVerses = await prisma.bibleVerse.count();
  if (totalVerses === 0) {
    return {
      reference: 'John 3:16',
      text: 'For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life.',
    };
  }

  // Pick a verse deterministically
  const offset = dayOfYear % totalVerses;
  const verse = await prisma.bibleVerse.findFirst({
    skip: offset,
    orderBy: { id: 'asc' },
    include: {
      book: { select: { name: true } },
    },
  });

  if (!verse) {
    return {
      reference: 'John 3:16',
      text: 'For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life.',
    };
  }

  return {
    reference: `${verse.book.name} ${verse.chapter}:${verse.verse}`,
    text: verse.text,
  };
}

/**
 * Calculate the user's devotional reading streak (consecutive days)
 */
async function getDevotionalStreak(userId: string): Promise<number> {
  const reads = await prisma.userDevotionalRead.findMany({
    where: { userId },
    orderBy: { readAt: 'desc' },
    select: { readAt: true },
    take: 365, // Max 1 year lookback
  });

  if (reads.length === 0) return 0;

  let streak = 0;
  const today = new Date();
  today.setHours(0, 0, 0, 0);

  // Check if they read today or yesterday (streak is still active)
  const lastRead = new Date(reads[0].readAt);
  lastRead.setHours(0, 0, 0, 0);

  const diffDays = Math.floor((today.getTime() - lastRead.getTime()) / (1000 * 60 * 60 * 24));
  if (diffDays > 1) return 0; // Streak broken

  // Count consecutive days
  const readDates = new Set(
    reads.map((r) => {
      const d = new Date(r.readAt);
      d.setHours(0, 0, 0, 0);
      return d.getTime();
    }),
  );

  let checkDate = new Date(lastRead);
  while (readDates.has(checkDate.getTime())) {
    streak++;
    checkDate.setDate(checkDate.getDate() - 1);
  }

  return streak;
}
