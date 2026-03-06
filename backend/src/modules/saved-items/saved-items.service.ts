import prisma from '../../config/database';
import { ApiError } from '../../utils/apiError';
import { logger } from '../../utils/logger';
import type { SaveItemInput, ListSavedItemsInput } from './saved-items.validation';

// Entity type to Prisma model mapping
const entityResolvers: Record<string, (id: string) => Promise<any>> = {
  SERMON: (id) => prisma.sermon.findUnique({ where: { id }, select: { id: true, title: true, thumbnailUrl: true, date: true } }),
  EVENT: (id) => prisma.event.findUnique({ where: { id }, select: { id: true, title: true, imageUrl: true, startDate: true } }),
  DEVOTIONAL: (id) => prisma.devotional.findUnique({ where: { id }, select: { id: true, title: true, date: true } }),
  VERSE: (id) => prisma.bibleVerse.findUnique({ where: { id }, select: { id: true, text: true, chapter: true, verse: true } }),
  THREAD: (id) => prisma.forumThread.findUnique({ where: { id }, select: { id: true, title: true, createdAt: true } }),
  SONG: (id) => prisma.worshipSong.findUnique({ where: { id }, select: { id: true, title: true, artist: true } }),
};

export const savedItemsService = {
  // ────────────────────────────────────────────────────
  // SAVE AN ITEM
  // ────────────────────────────────────────────────────
  async saveItem(userId: string, input: SaveItemInput) {
    // Verify entity exists
    const resolver = entityResolvers[input.entityType];
    if (!resolver) {
      throw ApiError.badRequest(`Invalid entity type: ${input.entityType}`);
    }

    const entity = await resolver(input.entityId);
    if (!entity) {
      throw ApiError.notFound(`${input.entityType} not found`);
    }

    // Check for duplicate
    const existing = await prisma.savedItem.findUnique({
      where: {
        userId_entityType_entityId: {
          userId,
          entityType: input.entityType,
          entityId: input.entityId,
        },
      },
    });

    if (existing) {
      throw ApiError.conflict('Item already saved');
    }

    const savedItem = await prisma.savedItem.create({
      data: {
        userId,
        entityType: input.entityType,
        entityId: input.entityId,
      },
    });

    logger.info(`Item saved: ${input.entityType}/${input.entityId} by user ${userId}`);
    return savedItem;
  },

  // ────────────────────────────────────────────────────
  // REMOVE A SAVED ITEM
  // ────────────────────────────────────────────────────
  async removeSavedItem(userId: string, savedItemId: string) {
    const item = await prisma.savedItem.findFirst({
      where: { id: savedItemId, userId },
    });

    if (!item) {
      throw ApiError.notFound('Saved item not found');
    }

    await prisma.savedItem.delete({ where: { id: savedItemId } });

    logger.info(`Saved item removed: ${savedItemId} by user ${userId}`);
    return { message: 'Item removed from saved' };
  },

  // ────────────────────────────────────────────────────
  // LIST SAVED ITEMS
  // ────────────────────────────────────────────────────
  async listSavedItems(userId: string, query: ListSavedItemsInput) {
    const { page, limit, entityType } = query;

    const where: any = { userId };
    if (entityType) where.entityType = entityType;

    const [items, total] = await Promise.all([
      prisma.savedItem.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * limit,
        take: limit,
      }),
      prisma.savedItem.count({ where }),
    ]);

    // Resolve entity details for each saved item
    const enriched = await Promise.all(
      items.map(async (item) => {
        const resolver = entityResolvers[item.entityType];
        const entity = resolver ? await resolver(item.entityId) : null;
        return {
          ...item,
          entity,
        };
      }),
    );

    return {
      items: enriched,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit),
      },
    };
  },

  // ────────────────────────────────────────────────────
  // CHECK IF ITEM IS SAVED
  // ────────────────────────────────────────────────────
  async isItemSaved(userId: string, entityType: string, entityId: string) {
    const item = await prisma.savedItem.findUnique({
      where: {
        userId_entityType_entityId: {
          userId,
          entityType: entityType as any,
          entityId,
        },
      },
    });

    return { saved: !!item };
  },
};
