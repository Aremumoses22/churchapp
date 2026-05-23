import prisma from '../../../config/database';
import { ApiError } from '../../../utils/apiError';
import { LiveServiceStatus } from '../../../generated/prisma/client';

function cw(churchId: string | null | undefined) { return churchId ? { churchId } : {}; }
function requireChurch(churchId: string | null | undefined): string {
  if (!churchId) throw ApiError.badRequest('Church context required');
  return churchId;
}

export const adminLiveService = {
  async list(churchId: string | null | undefined, opts: { page: number; limit: number; status?: string }) {
    const where: any = { ...cw(churchId) };
    if (opts.status) where.status = opts.status as LiveServiceStatus;
    const skip = (opts.page - 1) * opts.limit;
    const [services, total] = await Promise.all([
      prisma.liveService.findMany({ where, orderBy: { scheduledAt: 'desc' }, skip, take: opts.limit }),
      prisma.liveService.count({ where }),
    ]);
    return { services, total, page: opts.page, limit: opts.limit, totalPages: Math.ceil(total / opts.limit) };
  },

  async create(churchId: string | null | undefined, data: { title: string; description?: string; streamUrl?: string; scheduledAt: string }) {
    const id = requireChurch(churchId);
    return prisma.liveService.create({ data: { ...data, churchId: id, scheduledAt: new Date(data.scheduledAt) } });
  },

  async update(churchId: string | null | undefined, serviceId: string, data: any) {
    const cId = requireChurch(churchId);
    const existing = await prisma.liveService.findFirst({ where: { id: serviceId, churchId: cId } });
    if (!existing) throw ApiError.notFound('Live service not found');
    if (data.scheduledAt) data.scheduledAt = new Date(data.scheduledAt);
    return prisma.liveService.update({ where: { id: serviceId }, data });
  },

  async delete(churchId: string | null | undefined, serviceId: string) {
    const cId = requireChurch(churchId);
    const existing = await prisma.liveService.findFirst({ where: { id: serviceId, churchId: cId } });
    if (!existing) throw ApiError.notFound('Live service not found');
    await prisma.liveService.delete({ where: { id: serviceId } });
  },

  async goLive(churchId: string | null | undefined, serviceId: string) {
    const cId = requireChurch(churchId);
    const existing = await prisma.liveService.findFirst({ where: { id: serviceId, churchId: cId } });
    if (!existing) throw ApiError.notFound('Live service not found');
    return prisma.liveService.update({ where: { id: serviceId }, data: { status: LiveServiceStatus.LIVE, startedAt: new Date() } });
  },

  async endService(churchId: string | null | undefined, serviceId: string) {
    const cId = requireChurch(churchId);
    const existing = await prisma.liveService.findFirst({ where: { id: serviceId, churchId: cId } });
    if (!existing) throw ApiError.notFound('Live service not found');
    return prisma.liveService.update({ where: { id: serviceId }, data: { status: LiveServiceStatus.ENDED, endedAt: new Date() } });
  },
};
