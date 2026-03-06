import prisma from '../../config/database';
import { ApiError } from '../../utils/apiError';

export const liveService = {
  /**
   * List live services (scheduled, live, ended)
   */
  async list(churchId: string, options: { status?: string; page: number; limit: number }) {
    const { status, page, limit } = options;
    const skip = (page - 1) * limit;

    const where: any = { churchId };
    if (status) where.status = status;

    const [services, total] = await Promise.all([
      prisma.liveService.findMany({
        where,
        orderBy: { scheduledAt: 'desc' },
        skip,
        take: limit,
      }),
      prisma.liveService.count({ where }),
    ]);

    return {
      services,
      meta: { page, limit, total, totalPages: Math.ceil(total / limit) },
    };
  },

  /**
   * Get a live service by ID with chat message count
   */
  async getById(serviceId: string) {
    const service = await prisma.liveService.findUnique({
      where: { id: serviceId },
      include: {
        _count: { select: { chatMessages: true } },
      },
    });

    if (!service) throw ApiError.notFound('Live service not found');

    return service;
  },

  /**
   * Get current live service (if any)
   */
  async getCurrentLive(churchId: string) {
    return prisma.liveService.findFirst({
      where: { churchId, status: 'LIVE' },
      orderBy: { startedAt: 'desc' },
    });
  },

  /**
   * Get upcoming scheduled services
   */
  async getUpcoming(churchId: string) {
    return prisma.liveService.findMany({
      where: {
        churchId,
        status: 'SCHEDULED',
        scheduledAt: { gte: new Date() },
      },
      orderBy: { scheduledAt: 'asc' },
      take: 5,
    });
  },

  /**
   * Get chat messages for a live service
   */
  async getChatMessages(
    serviceId: string,
    page: number,
    limit: number,
  ) {
    const skip = (page - 1) * limit;

    const [messages, total] = await Promise.all([
      prisma.liveChatMessage.findMany({
        where: { liveServiceId: serviceId },
        orderBy: { createdAt: 'desc' },
        skip,
        take: limit,
        include: {
          user: {
            select: { id: true, name: true, avatarUrl: true },
          },
        },
      }),
      prisma.liveChatMessage.count({
        where: { liveServiceId: serviceId },
      }),
    ]);

    return {
      messages: messages.reverse(),
      meta: { page, limit, total, totalPages: Math.ceil(total / limit) },
    };
  },
};
