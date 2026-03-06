import prisma from '../../config/database';
import { ApiError } from '../../utils/apiError';
import { logger } from '../../utils/logger';
import type { CreateAlbumInput, AddPhotoInput, UpdatePodcastProgressInput } from './media.validation';

export const mediaService = {
  // ── Photo Albums ──────────────────────────────────
  async listAlbums(churchId: string, page: number, limit: number, eventId?: string) {
    const skip = (page - 1) * limit;

    const where: any = { churchId };
    if (eventId) where.eventId = eventId;

    const [albums, total] = await Promise.all([
      prisma.photoAlbum.findMany({
        where,
        include: {
          _count: { select: { photos: true } },
          event: { select: { id: true, title: true } },
        },
        orderBy: { createdAt: 'desc' },
        skip,
        take: limit,
      }),
      prisma.photoAlbum.count({ where }),
    ]);

    return {
      albums: albums.map((a) => ({
        ...a,
        photoCount: a._count.photos,
        _count: undefined,
      })),
      meta: { page, limit, total, totalPages: Math.ceil(total / limit) },
    };
  },

  async createAlbum(churchId: string, input: CreateAlbumInput) {
    if (input.eventId) {
      const event = await prisma.event.findUnique({ where: { id: input.eventId } });
      if (!event) throw ApiError.notFound('Event not found');
    }

    const album = await prisma.photoAlbum.create({
      data: {
        churchId,
        title: input.title,
        description: input.description,
        coverImageUrl: input.coverImageUrl,
        eventId: input.eventId,
      },
    });

    logger.info(`Photo album ${album.id} created for church ${churchId}`);
    return album;
  },

  async getAlbum(albumId: string, churchId: string) {
    const album = await prisma.photoAlbum.findFirst({
      where: { id: albumId, churchId },
      include: {
        photos: {
          include: {
            uploadedBy: { select: { id: true, name: true } },
          },
          orderBy: { createdAt: 'desc' },
        },
        event: { select: { id: true, title: true } },
      },
    });
    if (!album) throw ApiError.notFound('Album not found');
    return album;
  },

  // ── Photos ────────────────────────────────────────
  async addPhoto(userId: string, churchId: string, albumId: string, input: AddPhotoInput) {
    const album = await prisma.photoAlbum.findFirst({
      where: { id: albumId, churchId },
    });
    if (!album) throw ApiError.notFound('Album not found');

    const photo = await prisma.$transaction(async (tx) => {
      const p = await tx.photo.create({
        data: {
          albumId,
          churchId,
          uploadedById: userId,
          imageUrl: input.imageUrl,
          thumbnailUrl: input.thumbnailUrl,
          caption: input.caption,
        },
        include: {
          uploadedBy: { select: { id: true, name: true } },
        },
      });

      await tx.photoAlbum.update({
        where: { id: albumId },
        data: { photoCount: { increment: 1 } },
      });

      return p;
    });

    logger.info(`Photo ${photo.id} added to album ${albumId} by user ${userId}`);
    return photo;
  },

  // ── Podcasts ──────────────────────────────────────
  async listPodcasts(churchId: string, userId: string, page: number, limit: number) {
    const skip = (page - 1) * limit;

    const [episodes, total] = await Promise.all([
      prisma.podcastEpisode.findMany({
        where: { churchId },
        include: {
          progress: {
            where: { userId },
            take: 1,
          },
        },
        orderBy: { publishedAt: 'desc' },
        skip,
        take: limit,
      }),
      prisma.podcastEpisode.count({ where: { churchId } }),
    ]);

    return {
      episodes: episodes.map((e) => ({
        ...e,
        userProgress: e.progress[0] || null,
        progress: undefined,
      })),
      meta: { page, limit, total, totalPages: Math.ceil(total / limit) },
    };
  },

  async getPodcast(episodeId: string, churchId: string, userId: string) {
    const episode = await prisma.podcastEpisode.findFirst({
      where: { id: episodeId, churchId },
      include: {
        progress: {
          where: { userId },
          take: 1,
        },
      },
    });
    if (!episode) throw ApiError.notFound('Podcast episode not found');

    // Increment play count
    await prisma.podcastEpisode.update({
      where: { id: episodeId },
      data: { playCount: { increment: 1 } },
    });

    return {
      ...episode,
      userProgress: episode.progress[0] || null,
      progress: undefined,
    };
  },

  async updatePodcastProgress(userId: string, episodeId: string, input: UpdatePodcastProgressInput) {
    const episode = await prisma.podcastEpisode.findUnique({ where: { id: episodeId } });
    if (!episode) throw ApiError.notFound('Podcast episode not found');

    const progress = await prisma.userPodcastProgress.upsert({
      where: { userId_episodeId: { userId, episodeId } },
      update: {
        position: input.position,
        completed: input.completed ?? (input.position >= episode.duration),
      },
      create: {
        userId,
        episodeId,
        position: input.position,
        completed: input.completed ?? (input.position >= episode.duration),
      },
    });

    return progress;
  },

  // ── Worship Songs ─────────────────────────────────
  async listSongs(churchId: string, page: number, limit: number, key?: string, search?: string) {
    const skip = (page - 1) * limit;

    const where: any = { churchId };
    if (key) where.key = key;
    if (search) {
      where.OR = [
        { title: { contains: search, mode: 'insensitive' } },
        { artist: { contains: search, mode: 'insensitive' } },
      ];
    }

    const [songs, total] = await Promise.all([
      prisma.worshipSong.findMany({
        where,
        include: {
          _count: { select: { sections: true } },
        },
        orderBy: { title: 'asc' },
        skip,
        take: limit,
      }),
      prisma.worshipSong.count({ where }),
    ]);

    return {
      songs: songs.map((s) => ({
        ...s,
        sectionCount: s._count.sections,
        _count: undefined,
      })),
      meta: { page, limit, total, totalPages: Math.ceil(total / limit) },
    };
  },

  async getSong(songId: string, churchId: string) {
    const song = await prisma.worshipSong.findFirst({
      where: { id: songId, churchId },
      include: {
        sections: {
          include: { lines: { orderBy: { lineNumber: 'asc' } } },
          orderBy: { sortOrder: 'asc' },
        },
      },
    });
    if (!song) throw ApiError.notFound('Worship song not found');
    return song;
  },
};
