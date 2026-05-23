import prisma from '../../../config/database';
import { ApiError } from '../../../utils/apiError';

function cw(churchId: string | null | undefined) { return churchId ? { churchId } : {}; }
function requireChurch(churchId: string | null | undefined): string {
  if (!churchId) throw ApiError.badRequest('Church context required');
  return churchId;
}

export const adminEventsService = {
  async list(churchId: string | null | undefined, opts: { page: number; limit: number; search?: string; category?: string; upcoming?: boolean }) {
    const where: any = { ...cw(churchId) };
    if (opts.search) where.OR = [{ title: { contains: opts.search, mode: 'insensitive' } }, { location: { contains: opts.search, mode: 'insensitive' } }];
    if (opts.category) where.category = opts.category;
    if (opts.upcoming) where.startDate = { gte: new Date() };
    const skip = (opts.page - 1) * opts.limit;
    const [events, total] = await Promise.all([
      prisma.event.findMany({ where, orderBy: { startDate: 'asc' }, skip, take: opts.limit, include: { _count: { select: { registrations: true } } } }),
      prisma.event.count({ where }),
    ]);
    return { events, total, page: opts.page, limit: opts.limit, totalPages: Math.ceil(total / opts.limit) };
  },

  async getById(churchId: string | null | undefined, id: string) {
    const event = await prisma.event.findFirst({ where: { id, ...cw(churchId) }, include: { _count: { select: { registrations: true } } } });
    if (!event) throw ApiError.notFound('Event not found');
    return event;
  },

  async create(churchId: string | null | undefined, data: {
    title: string; description?: string; category: string; imageUrl?: string;
    location?: string; startDate: string; endDate?: string;
    registrationRequired?: boolean; maxCapacity?: number; isFeatured?: boolean; tags?: string[];
  }) {
    const id = requireChurch(churchId);
    return prisma.event.create({
      data: {
        ...data,
        churchId: id,
        startDate: new Date(data.startDate),
        endDate: data.endDate ? new Date(data.endDate) : null,
      },
    });
  },

  async update(churchId: string | null | undefined, eventId: string, data: any) {
    const cId = requireChurch(churchId);
    const existing = await prisma.event.findFirst({ where: { id: eventId, churchId: cId } });
    if (!existing) throw ApiError.notFound('Event not found');
    if (data.startDate) data.startDate = new Date(data.startDate);
    if (data.endDate) data.endDate = new Date(data.endDate);
    return prisma.event.update({ where: { id: eventId }, data });
  },

  async delete(churchId: string | null | undefined, eventId: string) {
    const cId = requireChurch(churchId);
    const existing = await prisma.event.findFirst({ where: { id: eventId, churchId: cId } });
    if (!existing) throw ApiError.notFound('Event not found');
    await prisma.event.delete({ where: { id: eventId } });
  },

  async toggleFeatured(churchId: string | null | undefined, eventId: string) {
    const cId = requireChurch(churchId);
    const existing = await prisma.event.findFirst({ where: { id: eventId, churchId: cId } });
    if (!existing) throw ApiError.notFound('Event not found');
    return prisma.event.update({ where: { id: eventId }, data: { isFeatured: !existing.isFeatured } });
  },

  async listRegistrations(churchId: string | null | undefined, eventId: string, opts: { page: number; limit: number }) {
    const cId = requireChurch(churchId);
    const event = await prisma.event.findFirst({ where: { id: eventId, churchId: cId } });
    if (!event) throw ApiError.notFound('Event not found');
    const skip = (opts.page - 1) * opts.limit;
    const [registrations, total] = await Promise.all([
      prisma.eventRegistration.findMany({
        where: { eventId },
        include: { user: { select: { id: true, name: true, email: true, avatarUrl: true } } },
        orderBy: { registeredAt: 'desc' },
        skip,
        take: opts.limit,
      }),
      prisma.eventRegistration.count({ where: { eventId } }),
    ]);
    return { registrations, total, page: opts.page, limit: opts.limit, totalPages: Math.ceil(total / opts.limit) };
  },
};
