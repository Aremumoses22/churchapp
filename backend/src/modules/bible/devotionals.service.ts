import prisma from '../../config/database';
import { ApiError } from '../../utils/apiError';

export const devotionalsService = {
  // ────────────────────────────────────────────────────
  // GET TODAY'S DEVOTIONAL
  // ────────────────────────────────────────────────────
  async getToday(churchId: string, userId: string) {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const devotional = await prisma.devotional.findFirst({
      where: {
        churchId,
        date: { lte: today },
      },
      orderBy: { date: 'desc' },
    });

    if (!devotional) {
      return null;
    }

    const read = await prisma.userDevotionalRead.findUnique({
      where: { userId_devotionalId: { userId, devotionalId: devotional.id } },
    });

    return { ...devotional, isRead: !!read };
  },

  // ────────────────────────────────────────────────────
  // GET DEVOTIONAL BY DATE
  // ────────────────────────────────────────────────────
  async getByDate(churchId: string, userId: string, dateStr: string) {
    const date = new Date(dateStr);
    date.setHours(0, 0, 0, 0);

    const devotional = await prisma.devotional.findFirst({
      where: { churchId, date },
    });

    if (!devotional) throw ApiError.notFound('No devotional for this date');

    const read = await prisma.userDevotionalRead.findUnique({
      where: { userId_devotionalId: { userId, devotionalId: devotional.id } },
    });

    return { ...devotional, isRead: !!read };
  },

  // ────────────────────────────────────────────────────
  // MARK AS READ
  // ────────────────────────────────────────────────────
  async markRead(userId: string, devotionalId: string) {
    const devotional = await prisma.devotional.findUnique({ where: { id: devotionalId } });
    if (!devotional) throw ApiError.notFound('Devotional not found');

    await prisma.userDevotionalRead.upsert({
      where: { userId_devotionalId: { userId, devotionalId } },
      update: { readAt: new Date() },
      create: { userId, devotionalId },
    });

    return { message: 'Devotional marked as read' };
  },

  // ────────────────────────────────────────────────────
  // GET READING STREAK
  // ────────────────────────────────────────────────────
  async getStreak(userId: string, churchId: string) {
    // Get all devotional reads, ordered by devotional date DESC
    const reads = await prisma.userDevotionalRead.findMany({
      where: { userId },
      include: {
        devotional: {
          select: { date: true, churchId: true },
        },
      },
      orderBy: { devotional: { date: 'desc' } },
    });

    // Filter for same church
    const churchReads = reads.filter((r) => r.devotional.churchId === churchId);

    // Calculate consecutive days streak
    let streak = 0;
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    // Check if today's devotional was read
    const todayRead = churchReads.some((r) => {
      const readDate = new Date(r.devotional.date);
      readDate.setHours(0, 0, 0, 0);
      return readDate.getTime() === today.getTime();
    });

    const startDate = todayRead ? today : new Date(today.getTime() - 86400000);

    // Count consecutive days backwards
    let checkDate = new Date(startDate);
    for (const read of churchReads) {
      const readDate = new Date(read.devotional.date);
      readDate.setHours(0, 0, 0, 0);

      if (readDate.getTime() === checkDate.getTime()) {
        streak++;
        checkDate = new Date(checkDate.getTime() - 86400000);
      } else if (readDate.getTime() < checkDate.getTime()) {
        break;
      }
    }

    return {
      currentStreak: streak,
      todayCompleted: todayRead,
      totalReads: churchReads.length,
    };
  },
};
