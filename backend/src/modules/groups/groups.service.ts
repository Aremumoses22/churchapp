import prisma from '../../config/database';
import { ApiError } from '../../utils/apiError';
import type { GroupCategory, GroupRole } from '../../generated/prisma/client';
import { notifyGroupJoin, notifyGroupLeave } from '../../services/notification.triggers';

// ── List Groups ─────────────────────────────────────
async function listGroups(
  churchId: string,
  userId: string,
  opts: { page: number; limit: number; category?: string; search?: string },
) {
  const { page, limit, category, search } = opts;

  const where: any = { churchId, isActive: true };
  if (category) where.category = category as GroupCategory;
  if (search) {
    where.OR = [
      { name: { contains: search, mode: 'insensitive' } },
      { description: { contains: search, mode: 'insensitive' } },
    ];
  }

  const [groups, total] = await Promise.all([
    prisma.connectGroup.findMany({
      where,
      include: {
        leader: { select: { id: true, name: true, avatarUrl: true } },
        memberships: {
          where: { userId },
          select: { id: true, role: true },
        },
      },
      orderBy: [{ memberCount: 'desc' }, { name: 'asc' }],
      skip: (page - 1) * limit,
      take: limit,
    }),
    prisma.connectGroup.count({ where }),
  ]);

  return {
    data: groups.map((g) => ({
      id: g.id,
      name: g.name,
      description: g.description,
      imageUrl: g.imageUrl,
      category: g.category,
      meetingDay: g.meetingDay,
      meetingTime: g.meetingTime,
      location: g.location,
      leader: g.leader,
      maxMembers: g.maxMembers,
      memberCount: g.memberCount,
      isMember: g.memberships.length > 0,
      memberRole: g.memberships[0]?.role || null,
      isOpen: !g.maxMembers || g.memberCount < g.maxMembers,
    })),
    meta: { page, limit, total, totalPages: Math.ceil(total / limit) },
  };
}

// ── Group Detail ────────────────────────────────────
async function getGroupById(groupId: string, userId: string) {
  const group = await prisma.connectGroup.findUnique({
    where: { id: groupId },
    include: {
      leader: { select: { id: true, name: true, avatarUrl: true, department: true } },
      memberships: {
        include: {
          user: { select: { id: true, name: true, avatarUrl: true, department: true } },
        },
        orderBy: [{ role: 'asc' }, { joinedAt: 'asc' }],
        take: 50,
      },
    },
  });

  if (!group || !group.isActive) throw ApiError.notFound('Group not found');

  const membership = group.memberships.find((m) => m.userId === userId);

  return {
    id: group.id,
    name: group.name,
    description: group.description,
    imageUrl: group.imageUrl,
    category: group.category,
    meetingDay: group.meetingDay,
    meetingTime: group.meetingTime,
    location: group.location,
    leader: group.leader,
    maxMembers: group.maxMembers,
    memberCount: group.memberCount,
    isMember: !!membership,
    memberRole: membership?.role || null,
    isOpen: !group.maxMembers || group.memberCount < group.maxMembers,
    members: group.memberships.map((m) => ({
      id: m.user.id,
      name: m.user.name,
      avatarUrl: m.user.avatarUrl,
      department: m.user.department,
      role: m.role,
      joinedAt: m.joinedAt,
    })),
  };
}

// ── Join Group ──────────────────────────────────────
async function joinGroup(groupId: string, userId: string) {
  const group = await prisma.connectGroup.findUnique({ where: { id: groupId } });
  if (!group || !group.isActive) throw ApiError.notFound('Group not found');

  // Check capacity
  if (group.maxMembers && group.memberCount >= group.maxMembers) {
    throw ApiError.badRequest('Group is full');
  }

  // Check if already a member
  const existing = await prisma.groupMembership.findUnique({
    where: { userId_groupId: { userId, groupId } },
  });
  if (existing) throw ApiError.conflict('Already a member of this group');

  // Create membership + increment count
  const [membership] = await prisma.$transaction([
    prisma.groupMembership.create({
      data: { userId, groupId, role: 'MEMBER' },
    }),
    prisma.connectGroup.update({
      where: { id: groupId },
      data: { memberCount: { increment: 1 } },
    }),
  ]);

  // Fire notification trigger (non-blocking)
  notifyGroupJoin(groupId, userId).catch(() => {});

  return { joined: true, membership };
}

// ── Leave Group ─────────────────────────────────────
async function leaveGroup(groupId: string, userId: string) {
  const membership = await prisma.groupMembership.findUnique({
    where: { userId_groupId: { userId, groupId } },
  });
  if (!membership) throw ApiError.notFound('Not a member of this group');

  if (membership.role === 'LEADER') {
    throw ApiError.badRequest('Group leader cannot leave. Transfer leadership first.');
  }

  await prisma.$transaction([
    prisma.groupMembership.delete({
      where: { userId_groupId: { userId, groupId } },
    }),
    prisma.connectGroup.update({
      where: { id: groupId },
      data: { memberCount: { decrement: 1 } },
    }),
  ]);

  // Fire notification trigger (non-blocking)
  notifyGroupLeave(groupId, userId).catch(() => {});

  return { left: true };
}

export const groupsService = {
  listGroups,
  getGroupById,
  joinGroup,
  leaveGroup,
};
