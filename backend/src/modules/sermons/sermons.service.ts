import prisma from '../../config/database';
import { ApiError } from '../../utils/apiError';
import { logger } from '../../utils/logger';
import type { ListSermonsInput, SaveProgressInput, SaveNotesInput } from './sermons.validation';

export const sermonsService = {
  // ────────────────────────────────────────────────────
  // LIST SERMONS (paginated, filtered)
  // ────────────────────────────────────────────────────
  async list(churchId: string, input: ListSermonsInput) {
    const { page, limit, seriesId, speaker, search, tag, startDate, endDate } = input;
    const skip = (page - 1) * limit;

    const where: any = { churchId };

    if (seriesId) where.seriesId = seriesId;
    if (speaker) where.speaker = { contains: speaker, mode: 'insensitive' };
    if (tag) where.tags = { has: tag };
    if (search) {
      where.OR = [
        { title: { contains: search, mode: 'insensitive' } },
        { speaker: { contains: search, mode: 'insensitive' } },
        { description: { contains: search, mode: 'insensitive' } },
      ];
    }
    if (startDate) where.date = { ...where.date, gte: new Date(startDate) };
    if (endDate) where.date = { ...where.date, lte: new Date(endDate) };

    const [sermons, total] = await Promise.all([
      prisma.sermon.findMany({
        where,
        skip,
        take: limit,
        orderBy: { date: 'desc' },
        include: {
          series: { select: { id: true, title: true } },
        },
      }),
      prisma.sermon.count({ where }),
    ]);

    return { sermons, total, page, limit };
  },

  // ────────────────────────────────────────────────────
  // GET FEATURED SERMONS
  // ────────────────────────────────────────────────────
  async getFeatured(churchId: string) {
    const sermons = await prisma.sermon.findMany({
      where: { churchId, isFeatured: true },
      orderBy: { date: 'desc' },
      take: 5,
      include: {
        series: { select: { id: true, title: true } },
      },
    });

    return sermons;
  },

  // ────────────────────────────────────────────────────
  // GET SERMON BY ID
  // ────────────────────────────────────────────────────
  async getById(sermonId: string, userId?: string) {
    const sermon = await prisma.sermon.findUnique({
      where: { id: sermonId },
      include: {
        series: { select: { id: true, title: true, imageUrl: true } },
      },
    });

    if (!sermon) throw ApiError.notFound('Sermon not found');

    // Increment play count
    await prisma.sermon.update({
      where: { id: sermonId },
      data: { playCount: { increment: 1 } },
    });

    // Get user-specific data if authenticated
    let progress = null;
    let notes = null;
    let isSaved = false;

    if (userId) {
      [progress, notes, isSaved] = await Promise.all([
        prisma.userSermonProgress.findUnique({
          where: { userId_sermonId: { userId, sermonId } },
          select: { position: true, completed: true, lastPlayedAt: true },
        }),
        prisma.userSermonNote.findUnique({
          where: { userId_sermonId: { userId, sermonId } },
          select: { content: true, updatedAt: true },
        }),
        prisma.savedSermon.findUnique({
          where: { userId_sermonId: { userId, sermonId } },
        }).then((s) => !!s),
      ]);
    }

    return { ...sermon, userProgress: progress, userNotes: notes, isSaved };
  },

  // ────────────────────────────────────────────────────
  // GET STREAM URL
  // ────────────────────────────────────────────────────
  async getStreamUrl(sermonId: string) {
    const sermon = await prisma.sermon.findUnique({
      where: { id: sermonId },
      select: { audioUrl: true, videoUrl: true },
    });

    if (!sermon) throw ApiError.notFound('Sermon not found');

    return { audioUrl: sermon.audioUrl, videoUrl: sermon.videoUrl };
  },

  // ────────────────────────────────────────────────────
  // SAVE PROGRESS
  // ────────────────────────────────────────────────────
  async saveProgress(userId: string, sermonId: string, input: SaveProgressInput) {
    const sermon = await prisma.sermon.findUnique({ where: { id: sermonId } });
    if (!sermon) throw ApiError.notFound('Sermon not found');

    const progress = await prisma.userSermonProgress.upsert({
      where: { userId_sermonId: { userId, sermonId } },
      update: {
        position: input.position,
        completed: input.completed ?? false,
        lastPlayedAt: new Date(),
      },
      create: {
        userId,
        sermonId,
        position: input.position,
        completed: input.completed ?? false,
        lastPlayedAt: new Date(),
      },
    });

    return progress;
  },

  // ────────────────────────────────────────────────────
  // TOGGLE SAVE (bookmark)
  // ────────────────────────────────────────────────────
  async toggleSave(userId: string, sermonId: string) {
    const sermon = await prisma.sermon.findUnique({ where: { id: sermonId } });
    if (!sermon) throw ApiError.notFound('Sermon not found');

    const existing = await prisma.savedSermon.findUnique({
      where: { userId_sermonId: { userId, sermonId } },
    });

    if (existing) {
      await prisma.savedSermon.delete({
        where: { userId_sermonId: { userId, sermonId } },
      });
      return { saved: false, message: 'Sermon removed from saved' };
    } else {
      await prisma.savedSermon.create({
        data: { userId, sermonId },
      });
      return { saved: true, message: 'Sermon saved' };
    }
  },

  // ────────────────────────────────────────────────────
  // GET SAVED SERMONS
  // ────────────────────────────────────────────────────
  async getSaved(userId: string) {
    const saved = await prisma.savedSermon.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
      include: {
        sermon: {
          include: {
            series: { select: { id: true, title: true } },
          },
        },
      },
    });

    return saved.map((s) => s.sermon);
  },

  // ────────────────────────────────────────────────────
  // GET NOTES
  // ────────────────────────────────────────────────────
  async getNotes(userId: string, sermonId: string) {
    const notes = await prisma.userSermonNote.findUnique({
      where: { userId_sermonId: { userId, sermonId } },
    });

    return notes || { content: '', updatedAt: null };
  },

  // ────────────────────────────────────────────────────
  // SAVE / UPDATE NOTES
  // ────────────────────────────────────────────────────
  async saveNotes(userId: string, sermonId: string, input: SaveNotesInput) {
    const sermon = await prisma.sermon.findUnique({ where: { id: sermonId } });
    if (!sermon) throw ApiError.notFound('Sermon not found');

    const notes = await prisma.userSermonNote.upsert({
      where: { userId_sermonId: { userId, sermonId } },
      update: { content: input.content },
      create: { userId, sermonId, content: input.content },
    });

    return notes;
  },

  // ════════════════════════════════════════════════════
  // SERIES
  // ════════════════════════════════════════════════════

  // ────────────────────────────────────────────────────
  // LIST SERIES
  // ────────────────────────────────────────────────────
  async listSeries(churchId: string) {
    const series = await prisma.sermonSeries.findMany({
      where: { churchId },
      orderBy: [{ sortOrder: 'asc' }, { startDate: 'desc' }],
      include: {
        _count: { select: { sermons: true } },
      },
    });

    return series.map((s) => ({
      ...s,
      sermonCount: s._count.sermons,
      _count: undefined,
    }));
  },

  // ────────────────────────────────────────────────────
  // GET SERIES BY ID
  // ────────────────────────────────────────────────────
  async getSeriesById(seriesId: string) {
    const series = await prisma.sermonSeries.findUnique({
      where: { id: seriesId },
      include: {
        sermons: {
          orderBy: { date: 'desc' },
          select: {
            id: true, title: true, speaker: true, date: true,
            duration: true, thumbnailUrl: true, playCount: true,
          },
        },
      },
    });

    if (!series) throw ApiError.notFound('Series not found');

    return series;
  },
};
