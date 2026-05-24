import prisma from '../../../config/database';
import { ApiError } from '../../../utils/apiError';
import { NotificationType } from '../../../generated/prisma/client';
import { notificationService } from '../../../services/notification.service';

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
    // Use the real notification service: creates DB records + Socket.io emit + FCM push
    await notificationService.sendToChurch(churchId, {
      type: data.type,
      title: data.title,
      body: data.body,
      data: {
        entityId: data.entityId ?? '',
        entityType: data.entityType ?? '',
      },
    });
    const count = await prisma.user.count({ where: { churchId, isActive: true } });
    return { sent: count };
  },

  async deleteNotification(id: string) {
    const existing = await prisma.notification.findUnique({ where: { id } });
    if (!existing) throw ApiError.notFound('Notification not found');
    await prisma.notification.delete({ where: { id } });
  },
};
