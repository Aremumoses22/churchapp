import prisma from '../../../config/database';
import { ApiError } from '../../../utils/apiError';

function cw(churchId: string | null | undefined) { return churchId ? { churchId } : {}; }
function requireChurch(churchId: string | null | undefined): string {
  if (!churchId) throw ApiError.badRequest('Church context required');
  return churchId;
}

export const adminKidsService = {
  // ── Rooms ─────────────────────────────────────────────────
  async listRooms(churchId: string | null | undefined) {
    return prisma.room.findMany({
      where: cw(churchId),
      orderBy: { name: 'asc' },
    });
  },

  async createRoom(churchId: string | null | undefined, data: { name: string; ageGroup: string; capacity: number }) {
    const id = requireChurch(churchId);
    return prisma.room.create({ data: { ...data, churchId: id } });
  },

  async updateRoom(churchId: string | null | undefined, roomId: string, data: any) {
    const cId = requireChurch(churchId);
    const existing = await prisma.room.findFirst({ where: { id: roomId, churchId: cId } });
    if (!existing) throw ApiError.notFound('Room not found');
    return prisma.room.update({ where: { id: roomId }, data });
  },

  async deleteRoom(churchId: string | null | undefined, roomId: string) {
    const cId = requireChurch(churchId);
    const existing = await prisma.room.findFirst({ where: { id: roomId, churchId: cId } });
    if (!existing) throw ApiError.notFound('Room not found');
    await prisma.room.delete({ where: { id: roomId } });
  },

  // ── Children ──────────────────────────────────────────────
  async listChildren(churchId: string | null | undefined, opts: { page: number; limit: number; search?: string }) {
    const where: any = { ...cw(churchId) };
    if (opts.search) {
      where.OR = [
        { firstName: { contains: opts.search, mode: 'insensitive' } },
        { lastName: { contains: opts.search, mode: 'insensitive' } },
      ];
    }
    const skip = (opts.page - 1) * opts.limit;
    const [children, total] = await Promise.all([
      prisma.child.findMany({
        where,
        include: { parent: { select: { id: true, name: true, email: true, phone: true } } },
        orderBy: [{ lastName: 'asc' }, { firstName: 'asc' }],
        skip,
        take: opts.limit,
      }),
      prisma.child.count({ where }),
    ]);
    return { children, total, page: opts.page, limit: opts.limit, totalPages: Math.ceil(total / opts.limit) };
  },

  // ── Check-ins ─────────────────────────────────────────────
  async todayCheckins(churchId: string | null | undefined) {
    const startOfDay = new Date();
    startOfDay.setHours(0, 0, 0, 0);
    return prisma.checkIn.findMany({
      where: {
        child: { ...cw(churchId) },
        checkedInAt: { gte: startOfDay },
      },
      include: {
        child: { select: { id: true, firstName: true, lastName: true } },
        room: { select: { id: true, name: true } },
        parent: { select: { id: true, name: true, phone: true } },
      },
      orderBy: { checkedInAt: 'desc' },
    });
  },

  async listCheckinHistory(churchId: string | null | undefined, opts: { page: number; limit: number; roomId?: string }) {
    const where: any = { child: { ...cw(churchId) } };
    if (opts.roomId) where.roomId = opts.roomId;
    const skip = (opts.page - 1) * opts.limit;
    const [checkins, total] = await Promise.all([
      prisma.checkIn.findMany({
        where,
        include: {
          child: { select: { id: true, firstName: true, lastName: true } },
          room: { select: { id: true, name: true } },
          parent: { select: { id: true, name: true } },
        },
        orderBy: { checkedInAt: 'desc' },
        skip,
        take: opts.limit,
      }),
      prisma.checkIn.count({ where }),
    ]);
    return { checkins, total, page: opts.page, limit: opts.limit, totalPages: Math.ceil(total / opts.limit) };
  },
};
