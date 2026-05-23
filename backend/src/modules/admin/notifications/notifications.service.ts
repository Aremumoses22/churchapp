import prisma from '../../../config/database';
import { ApiError } from '../../../utils/apiError';
import { NotificationType } from '../../../generated/prisma/client';

function cw(churchId: string | null | undefined) { return churchId ? { churchId } : {}; }

export const adminNotificationsService = {
  async list(churchId: string | null | undefined, opts: { page: number; limit: number }) {
    const where: any = churchId
      ? { user: { churchId } }
      : {};
    const skip = (opts.page - 1) * opts.limit;
    const [notifications, total] = await Promise.all([
      prisma.notification.findMany({
        where,
        include: { user: { select: { id: true, name: true, email: true } } },
        orderBy: { createdAt: 'desc' },
        skip,
        take: opts.limit,
      }),
      prisma.notification.count({ where }),
    ]);
    return { notifications, total, page: opts.page, limit: opts.limit, totalPages: Math.ceil(total / opts.limit) };
  },

  async sendToAll(churchId: string | null | undefined, data: { type: NotificationType; title: string; body: string; entityId?: string; entityType?: string }) {
    if (!churchId) throw ApiError.badRequest('Church context required');
    const members = await prisma.user.findMany({ where: { churchId, isActive: true }, select: { id: true } });
    if (members.length === 0) return { sent: 0 };
    const notifData = members.map(m => ({
      userId: m.id,
      type: data.type,
      title: data.title,
      body: data.body,
      data: { entityId: data.entityId ?? '', entityType: data.entityType ?? '' },
    }));
    const result = await prisma.notification.createMany({ data: notifData });
    return { sent: result.count };
  },

  async deleteNotification(id: string) {
    const existing = await prisma.notification.findUnique({ where: { id } });
    if (!existing) throw ApiError.notFound('Notification not found');
    await prisma.notification.delete({ where: { id } });
  },
};
