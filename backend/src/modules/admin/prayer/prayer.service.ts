import prisma from '../../../config/database';
import { ApiError } from '../../../utils/apiError';
import { PrayerRequestStatus } from '../../../generated/prisma/client';

function cw(churchId: string | null | undefined) { return churchId ? { churchId } : {}; }
function requireChurch(churchId: string | null | undefined): string {
  if (!churchId) throw ApiError.badRequest('Church context required');
  return churchId;
}

export const adminPrayerService = {
  async list(churchId: string | null | undefined, opts: { page: number; limit: number; search?: string; status?: string; isUrgent?: boolean }) {
    const where: any = { ...cw(churchId) };
    if (opts.search) where.OR = [{ title: { contains: opts.search, mode: 'insensitive' } }, { content: { contains: opts.search, mode: 'insensitive' } }];
    if (opts.status) where.status = opts.status as PrayerRequestStatus;
    if (opts.isUrgent) where.isUrgent = true;
    const skip = (opts.page - 1) * opts.limit;
    const [requests, total] = await Promise.all([
      prisma.prayerRequest.findMany({
        where,
        include: { user: { select: { id: true, name: true, avatarUrl: true } } },
        orderBy: [{ isUrgent: 'desc' }, { createdAt: 'desc' }],
        skip,
        take: opts.limit,
      }),
      prisma.prayerRequest.count({ where }),
    ]);
    return { requests, total, page: opts.page, limit: opts.limit, totalPages: Math.ceil(total / opts.limit) };
  },

  async updateStatus(churchId: string | null | undefined, id: string, status: PrayerRequestStatus) {
    requireChurch(churchId);
    const existing = await prisma.prayerRequest.findFirst({ where: { id, ...cw(churchId) } });
    if (!existing) throw ApiError.notFound('Prayer request not found');
    return prisma.prayerRequest.update({ where: { id }, data: { status } });
  },

  async delete(churchId: string | null | undefined, id: string) {
    requireChurch(churchId);
    const existing = await prisma.prayerRequest.findFirst({ where: { id, ...cw(churchId) } });
    if (!existing) throw ApiError.notFound('Prayer request not found');
    await prisma.prayerRequest.delete({ where: { id } });
  },
};
