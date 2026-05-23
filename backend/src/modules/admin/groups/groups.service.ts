import prisma from '../../../config/database';
import { ApiError } from '../../../utils/apiError';
import { GroupCategory } from '../../../generated/prisma/client';

function cw(churchId: string | null | undefined) { return churchId ? { churchId } : {}; }
function requireChurch(churchId: string | null | undefined): string {
  if (!churchId) throw ApiError.badRequest('Church context required');
  return churchId;
}

export const adminGroupsService = {
  async list(churchId: string | null | undefined, opts: { page: number; limit: number; search?: string; category?: string }) {
    const where: any = { ...cw(churchId) };
    if (opts.search) where.OR = [{ name: { contains: opts.search, mode: 'insensitive' } }, { description: { contains: opts.search, mode: 'insensitive' } }];
    if (opts.category) where.category = opts.category;
    const skip = (opts.page - 1) * opts.limit;
    const [groups, total] = await Promise.all([
      prisma.connectGroup.findMany({
        where,
        include: {
          leader: { select: { id: true, name: true, email: true, avatarUrl: true } },
          _count: { select: { memberships: true } },
        },
        orderBy: { name: 'asc' },
        skip,
        take: opts.limit,
      }),
      prisma.connectGroup.count({ where }),
    ]);
    return { groups, total, page: opts.page, limit: opts.limit, totalPages: Math.ceil(total / opts.limit) };
  },

  async getById(churchId: string | null | undefined, id: string) {
    const group = await prisma.connectGroup.findFirst({
      where: { id, ...cw(churchId) },
      include: {
        leader: { select: { id: true, name: true, email: true, avatarUrl: true } },
        memberships: { include: { user: { select: { id: true, name: true, email: true, avatarUrl: true } } }, take: 50 },
        _count: { select: { memberships: true } },
      },
    });
    if (!group) throw ApiError.notFound('Group not found');
    return group;
  },

  async create(churchId: string | null | undefined, data: { name: string; description?: string; category: string; meetingDay?: string; meetingTime?: string; location?: string; leaderId?: string; maxMembers?: number; imageUrl?: string }) {
    const id = requireChurch(churchId);
    return prisma.connectGroup.create({ data: { ...data, churchId: id, category: data.category as GroupCategory } });
  },

  async update(churchId: string | null | undefined, groupId: string, data: any) {
    const cId = requireChurch(churchId);
    const existing = await prisma.connectGroup.findFirst({ where: { id: groupId, churchId: cId } });
    if (!existing) throw ApiError.notFound('Group not found');
    return prisma.connectGroup.update({ where: { id: groupId }, data });
  },

  async delete(churchId: string | null | undefined, groupId: string) {
    const cId = requireChurch(churchId);
    const existing = await prisma.connectGroup.findFirst({ where: { id: groupId, churchId: cId } });
    if (!existing) throw ApiError.notFound('Group not found');
    await prisma.connectGroup.delete({ where: { id: groupId } });
  },

  async removeMember(churchId: string | null | undefined, groupId: string, userId: string) {
    const cId = requireChurch(churchId);
    const group = await prisma.connectGroup.findFirst({ where: { id: groupId, churchId: cId } });
    if (!group) throw ApiError.notFound('Group not found');
    await prisma.groupMembership.deleteMany({ where: { groupId, userId } });
    await prisma.connectGroup.update({ where: { id: groupId }, data: { memberCount: { decrement: 1 } } });
  },
};
