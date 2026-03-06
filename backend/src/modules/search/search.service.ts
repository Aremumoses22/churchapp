import prisma from '../../config/database';
import { logger } from '../../utils/logger';
import type { SearchInput } from './search.validation';

interface SearchResult {
  type: string;
  id: string;
  title: string;
  description: string | null;
  imageUrl: string | null;
  createdAt: Date;
}

export const searchService = {
  async search(churchId: string, input: SearchInput) {
    const { q, type, page, limit } = input;
    const skip = (page - 1) * limit;
    const searchTerm = q.toLowerCase();

    const results: SearchResult[] = [];
    let totalEstimate = 0;

    const searchTypes = type === 'all'
      ? ['sermons', 'events', 'groups', 'people', 'forum', 'media']
      : [type];

    // Run searches in parallel for the requested types
    const searchPromises: Promise<void>[] = [];

    if (searchTypes.includes('sermons')) {
      searchPromises.push(
        prisma.sermon.findMany({
          where: {
            churchId,
            OR: [
              { title: { contains: searchTerm, mode: 'insensitive' } },
              { speaker: { contains: searchTerm, mode: 'insensitive' } },
              { description: { contains: searchTerm, mode: 'insensitive' } },
            ],
          },
          select: { id: true, title: true, description: true, thumbnailUrl: true, createdAt: true },
          take: type === 'all' ? 5 : limit,
          skip: type === 'all' ? 0 : skip,
          orderBy: { createdAt: 'desc' },
        }).then((sermons) => {
          sermons.forEach((s) => results.push({
            type: 'sermon',
            id: s.id,
            title: s.title,
            description: s.description,
            imageUrl: s.thumbnailUrl,
            createdAt: s.createdAt,
          }));
        })
      );
    }

    if (searchTypes.includes('events')) {
      searchPromises.push(
        prisma.event.findMany({
          where: {
            churchId,
            OR: [
              { title: { contains: searchTerm, mode: 'insensitive' } },
              { description: { contains: searchTerm, mode: 'insensitive' } },
              { location: { contains: searchTerm, mode: 'insensitive' } },
            ],
          },
          select: { id: true, title: true, description: true, imageUrl: true, createdAt: true },
          take: type === 'all' ? 5 : limit,
          skip: type === 'all' ? 0 : skip,
          orderBy: { startDate: 'desc' },
        }).then((events) => {
          events.forEach((e) => results.push({
            type: 'event',
            id: e.id,
            title: e.title,
            description: e.description,
            imageUrl: e.imageUrl,
            createdAt: e.createdAt,
          }));
        })
      );
    }

    if (searchTypes.includes('groups')) {
      searchPromises.push(
        prisma.connectGroup.findMany({
          where: {
            churchId,
            OR: [
              { name: { contains: searchTerm, mode: 'insensitive' } },
              { description: { contains: searchTerm, mode: 'insensitive' } },
            ],
          },
          select: { id: true, name: true, description: true, imageUrl: true, createdAt: true },
          take: type === 'all' ? 5 : limit,
          skip: type === 'all' ? 0 : skip,
          orderBy: { createdAt: 'desc' },
        }).then((groups) => {
          groups.forEach((g) => results.push({
            type: 'group',
            id: g.id,
            title: g.name,
            description: g.description,
            imageUrl: g.imageUrl,
            createdAt: g.createdAt,
          }));
        })
      );
    }

    if (searchTypes.includes('people')) {
      searchPromises.push(
        prisma.user.findMany({
          where: {
            churchId,
            OR: [
              { name: { contains: searchTerm, mode: 'insensitive' } },
              { email: { contains: searchTerm, mode: 'insensitive' } },
            ],
          },
          select: { id: true, name: true, avatarUrl: true, createdAt: true },
          take: type === 'all' ? 5 : limit,
          skip: type === 'all' ? 0 : skip,
          orderBy: { name: 'asc' },
        }).then((users) => {
          users.forEach((u) => results.push({
            type: 'person',
            id: u.id,
            title: u.name,
            description: null,
            imageUrl: u.avatarUrl,
            createdAt: u.createdAt,
          }));
        })
      );
    }

    if (searchTypes.includes('forum')) {
      searchPromises.push(
        prisma.forumThread.findMany({
          where: {
            churchId,
            OR: [
              { title: { contains: searchTerm, mode: 'insensitive' } },
              { content: { contains: searchTerm, mode: 'insensitive' } },
            ],
          },
          select: { id: true, title: true, content: true, createdAt: true },
          take: type === 'all' ? 5 : limit,
          skip: type === 'all' ? 0 : skip,
          orderBy: { createdAt: 'desc' },
        }).then((threads) => {
          threads.forEach((t) => results.push({
            type: 'forum',
            id: t.id,
            title: t.title,
            description: t.content?.substring(0, 200) || null,
            imageUrl: null,
            createdAt: t.createdAt,
          }));
        })
      );
    }

    if (searchTypes.includes('media')) {
      searchPromises.push(
        Promise.all([
          prisma.photoAlbum.findMany({
            where: {
              churchId,
              OR: [
                { title: { contains: searchTerm, mode: 'insensitive' } },
                { description: { contains: searchTerm, mode: 'insensitive' } },
              ],
            },
            select: { id: true, title: true, description: true, coverImageUrl: true, createdAt: true },
            take: type === 'all' ? 3 : Math.ceil(limit / 2),
            orderBy: { createdAt: 'desc' },
          }),
          prisma.podcastEpisode.findMany({
            where: {
              churchId,
              OR: [
                { title: { contains: searchTerm, mode: 'insensitive' } },
                { description: { contains: searchTerm, mode: 'insensitive' } },
              ],
            },
            select: { id: true, title: true, description: true, thumbnailUrl: true, createdAt: true },
            take: type === 'all' ? 3 : Math.ceil(limit / 2),
            orderBy: { publishedAt: 'desc' },
          }),
        ]).then(([albums, podcasts]) => {
          albums.forEach((a) => results.push({
            type: 'album',
            id: a.id,
            title: a.title,
            description: a.description,
            imageUrl: a.coverImageUrl,
            createdAt: a.createdAt,
          }));
          podcasts.forEach((p) => results.push({
            type: 'podcast',
            id: p.id,
            title: p.title,
            description: p.description,
            imageUrl: p.thumbnailUrl,
            createdAt: p.createdAt,
          }));
        })
      );
    }

    await Promise.all(searchPromises);

    // Sort combined results by relevance (exact title match first, then by date)
    results.sort((a, b) => {
      const aExact = a.title.toLowerCase().includes(searchTerm) ? 0 : 1;
      const bExact = b.title.toLowerCase().includes(searchTerm) ? 0 : 1;
      if (aExact !== bExact) return aExact - bExact;
      return b.createdAt.getTime() - a.createdAt.getTime();
    });

    // For 'all' type, we already limited per-type; for single type, apply pagination
    const paginatedResults = type === 'all' ? results : results;
    totalEstimate = paginatedResults.length;

    logger.info(`Search for "${q}" (type=${type}) by church ${churchId}: ${totalEstimate} results`);

    return {
      results: paginatedResults,
      meta: { page, limit, total: totalEstimate, query: q, type },
    };
  },

  async getTrending(churchId: string, limit: number) {
    // Get trending items based on recent activity
    const [recentSermons, upcomingEvents, popularGroups] = await Promise.all([
      // Recent sermons with high play counts
      prisma.sermon.findMany({
        where: { churchId },
        select: { id: true, title: true, thumbnailUrl: true, playCount: true },
        orderBy: { playCount: 'desc' },
        take: Math.ceil(limit / 3),
      }),
      // Upcoming events with most registrations
      prisma.event.findMany({
        where: {
          churchId,
          startDate: { gte: new Date() },
        },
        select: {
          id: true,
          title: true,
          imageUrl: true,
          _count: { select: { registrations: true } },
        },
        orderBy: { startDate: 'asc' },
        take: Math.ceil(limit / 3),
      }),
      // Popular groups by member count
      prisma.connectGroup.findMany({
        where: { churchId },
        select: {
          id: true,
          name: true,
          imageUrl: true,
          _count: { select: { memberships: true } },
        },
        orderBy: { memberCount: 'desc' },
        take: Math.ceil(limit / 3),
      }),
    ]);

    const trending = [
      ...recentSermons.map((s) => ({
        type: 'sermon' as const,
        id: s.id,
        title: s.title,
        imageUrl: s.thumbnailUrl,
        metric: s.playCount,
        metricLabel: 'plays',
      })),
      ...upcomingEvents.map((e) => ({
        type: 'event' as const,
        id: e.id,
        title: e.title,
        imageUrl: e.imageUrl,
        metric: e._count.registrations,
        metricLabel: 'registrations',
      })),
      ...popularGroups.map((g) => ({
        type: 'group' as const,
        id: g.id,
        title: g.name,
        imageUrl: g.imageUrl,
        metric: g._count.memberships,
        metricLabel: 'members',
      })),
    ];

    // Sort by metric descending
    trending.sort((a, b) => b.metric - a.metric);

    return trending.slice(0, limit);
  },
};
