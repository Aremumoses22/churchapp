import prisma from '../../../config/database';
import { notifyNewAnnouncement } from '../../../services/notification.triggers';

export const adminAnnouncementsService = {
  async list(churchId: string, opts: { page: number; limit: number }) {
    const skip = (opts.page - 1) * opts.limit;
    const [announcements, total] = await Promise.all([
      prisma.announcement.findMany({
        where: { churchId },
        include: { author: { select: { id: true, name: true } } },
        orderBy: [{ isPinned: 'desc' }, { publishedAt: 'desc' }],
        skip,
        take: opts.limit,
      }),
      prisma.announcement.count({ where: { churchId } }),
    ]);
    return { announcements, total, page: opts.page, limit: opts.limit, totalPages: Math.ceil(total / opts.limit) };
  },

  async create(
    churchId: string,
    authorId: string,
    data: {
      title: string;
      content: string;
      imageUrl?: string;
      category?: string;
      isUrgent?: boolean;
      isPinned?: boolean;
      publishedAt?: Date;
      expiresAt?: Date;
    },
  ) {
    const announcement = await prisma.announcement.create({
      data: {
        churchId,
        authorId,
        title: data.title,
        content: data.content,
        imageUrl: data.imageUrl,
        category: data.category,
        isUrgent: data.isUrgent ?? false,
        isPinned: data.isPinned ?? false,
        publishedAt: data.publishedAt ?? new Date(),
        expiresAt: data.expiresAt,
      },
    });

    // Fire push notification to all church members (non-blocking)
    notifyNewAnnouncement(churchId, announcement.id, announcement.title, announcement.isUrgent).catch(() => {});

    return announcement;
  },

  async update(
    id: string,
    churchId: string,
    data: Partial<{
      title: string;
      content: string;
      imageUrl: string;
      category: string;
      isUrgent: boolean;
      isPinned: boolean;
      publishedAt: Date;
      expiresAt: Date;
    }>,
  ) {
    return prisma.announcement.update({
      where: { id, churchId },
      data,
    });
  },

  async delete(id: string, churchId: string) {
    await prisma.announcement.delete({ where: { id, churchId } });
  },
};
