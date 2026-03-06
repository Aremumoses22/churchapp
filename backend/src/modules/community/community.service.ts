import prisma from '../../config/database';
import { ApiError } from '../../utils/apiError';
import type { TestimonyStatus, ReactionType } from '../../generated/prisma/client';
import crypto from 'crypto';
import { notifyTestimonyReaction } from '../../services/notification.triggers';

// ═══════════════════════════════════════════════════════
// ANNOUNCEMENTS
// ═══════════════════════════════════════════════════════

async function getAnnouncements(
  churchId: string,
  userId: string,
  opts: { page: number; limit: number; category?: string },
) {
  const { page, limit, category } = opts;

  const where: any = {
    churchId,
    publishedAt: { lte: new Date() },
    OR: [
      { expiresAt: null },
      { expiresAt: { gt: new Date() } },
    ],
  };
  if (category) where.category = category;

  const [announcements, total] = await Promise.all([
    prisma.announcement.findMany({
      where,
      include: {
        author: { select: { id: true, name: true, avatarUrl: true } },
        reads: {
          where: { userId },
          select: { id: true },
        },
      },
      orderBy: [{ isPinned: 'desc' }, { isUrgent: 'desc' }, { publishedAt: 'desc' }],
      skip: (page - 1) * limit,
      take: limit,
    }),
    prisma.announcement.count({ where }),
  ]);

  return {
    data: announcements.map((a) => ({
      id: a.id,
      title: a.title,
      content: a.content,
      imageUrl: a.imageUrl,
      category: a.category,
      isUrgent: a.isUrgent,
      isPinned: a.isPinned,
      publishedAt: a.publishedAt,
      expiresAt: a.expiresAt,
      author: a.author,
      isRead: a.reads.length > 0,
    })),
    meta: { page, limit, total, totalPages: Math.ceil(total / limit) },
  };
}

async function getAnnouncementById(announcementId: string, userId: string) {
  const announcement = await prisma.announcement.findUnique({
    where: { id: announcementId },
    include: {
      author: { select: { id: true, name: true, avatarUrl: true } },
      reads: {
        where: { userId },
        select: { id: true },
      },
    },
  });

  if (!announcement) throw ApiError.notFound('Announcement not found');

  return {
    id: announcement.id,
    title: announcement.title,
    content: announcement.content,
    imageUrl: announcement.imageUrl,
    category: announcement.category,
    isUrgent: announcement.isUrgent,
    isPinned: announcement.isPinned,
    publishedAt: announcement.publishedAt,
    expiresAt: announcement.expiresAt,
    author: announcement.author,
    isRead: announcement.reads.length > 0,
  };
}

async function markAnnouncementRead(announcementId: string, userId: string) {
  const announcement = await prisma.announcement.findUnique({ where: { id: announcementId } });
  if (!announcement) throw ApiError.notFound('Announcement not found');

  await prisma.announcementRead.upsert({
    where: { userId_announcementId: { userId, announcementId } },
    update: { readAt: new Date() },
    create: { userId, announcementId },
  });

  return { read: true };
}

// ═══════════════════════════════════════════════════════
// TESTIMONIES
// ═══════════════════════════════════════════════════════

async function getTestimonies(
  churchId: string,
  userId: string,
  opts: { page: number; limit: number },
) {
  const { page, limit } = opts;

  const where = { churchId, status: 'APPROVED' as TestimonyStatus };

  const [testimonies, total] = await Promise.all([
    prisma.testimony.findMany({
      where,
      include: {
        user: { select: { id: true, name: true, avatarUrl: true } },
        reactions: {
          where: { userId },
          select: { type: true },
        },
      },
      orderBy: { createdAt: 'desc' },
      skip: (page - 1) * limit,
      take: limit,
    }),
    prisma.testimony.count({ where }),
  ]);

  return {
    data: testimonies.map((t) => ({
      id: t.id,
      title: t.title,
      content: t.content,
      isAnonymous: t.isAnonymous,
      author: t.isAnonymous ? null : { id: t.user.id, name: t.user.name, avatarUrl: t.user.avatarUrl },
      likeCount: t.likeCount,
      prayerCount: t.prayerCount,
      userReaction: t.reactions[0]?.type || null,
      createdAt: t.createdAt,
    })),
    meta: { page, limit, total, totalPages: Math.ceil(total / limit) },
  };
}

async function submitTestimony(
  userId: string,
  churchId: string,
  data: { title: string; content: string; isAnonymous?: boolean },
) {
  const testimony = await prisma.testimony.create({
    data: {
      userId,
      churchId,
      title: data.title,
      content: data.content,
      isAnonymous: data.isAnonymous || false,
      status: 'PENDING',
    },
  });

  return testimony;
}

async function reactToTestimony(testimonyId: string, userId: string, type: ReactionType) {
  const testimony = await prisma.testimony.findUnique({ where: { id: testimonyId } });
  if (!testimony || testimony.status !== 'APPROVED') {
    throw ApiError.notFound('Testimony not found');
  }

  // Check if already reacted
  const existing = await prisma.testimonyReaction.findUnique({
    where: { userId_testimonyId: { userId, testimonyId } },
  });

  if (existing) {
    if (existing.type === type) {
      // Remove reaction (toggle off)
      await prisma.$transaction([
        prisma.testimonyReaction.delete({
          where: { userId_testimonyId: { userId, testimonyId } },
        }),
        prisma.testimony.update({
          where: { id: testimonyId },
          data: {
            likeCount: type === 'LIKE' ? { decrement: 1 } : undefined,
            prayerCount: type === 'PRAY' ? { decrement: 1 } : undefined,
          },
        }),
      ]);
      return { reacted: false, type };
    } else {
      // Switch reaction type
      const oldType = existing.type;
      await prisma.$transaction([
        prisma.testimonyReaction.update({
          where: { userId_testimonyId: { userId, testimonyId } },
          data: { type },
        }),
        prisma.testimony.update({
          where: { id: testimonyId },
          data: {
            likeCount: type === 'LIKE' ? { increment: 1 } : oldType === 'LIKE' ? { decrement: 1 } : undefined,
            prayerCount: type === 'PRAY' ? { increment: 1 } : oldType === 'PRAY' ? { decrement: 1 } : undefined,
          },
        }),
      ]);
      return { reacted: true, type };
    }
  }

  // Create new reaction
  await prisma.$transaction([
    prisma.testimonyReaction.create({
      data: { userId, testimonyId, type },
    }),
    prisma.testimony.update({
      where: { id: testimonyId },
      data: {
        likeCount: type === 'LIKE' ? { increment: 1 } : undefined,
        prayerCount: type === 'PRAY' ? { increment: 1 } : undefined,
      },
    }),
  ]);

  // Fire notification trigger (non-blocking)
  notifyTestimonyReaction(testimonyId, userId, type).catch(() => {});

  return { reacted: true, type };
}

// ═══════════════════════════════════════════════════════
// CHURCH DIRECTORY
// ═══════════════════════════════════════════════════════

async function getDirectory(
  churchId: string,
  opts: { page: number; limit: number; search?: string },
) {
  const { page, limit, search } = opts;

  const where: any = {
    churchId,
    isActive: true,
    isDirectoryVisible: true,
  };
  if (search) {
    where.OR = [
      { name: { contains: search, mode: 'insensitive' } },
      { department: { contains: search, mode: 'insensitive' } },
    ];
  }

  const [members, total] = await Promise.all([
    prisma.user.findMany({
      where,
      select: {
        id: true,
        name: true,
        avatarUrl: true,
        department: true,
        bio: true,
        phone: true,
        email: true,
      },
      orderBy: { name: 'asc' },
      skip: (page - 1) * limit,
      take: limit,
    }),
    prisma.user.count({ where }),
  ]);

  return {
    data: members,
    meta: { page, limit, total, totalPages: Math.ceil(total / limit) },
  };
}

// ═══════════════════════════════════════════════════════
// INVITE LINKS
// ═══════════════════════════════════════════════════════

function generateInviteCode(): string {
  return crypto.randomBytes(5).toString('hex').toUpperCase(); // 10-char hex
}

async function generateInviteLink(userId: string, churchId: string) {
  const code = generateInviteCode();
  const expiresAt = new Date();
  expiresAt.setDate(expiresAt.getDate() + 30); // 30 days

  const invite = await prisma.inviteLink.create({
    data: {
      userId,
      churchId,
      code,
      expiresAt,
    },
  });

  return {
    id: invite.id,
    code: invite.code,
    inviteUrl: `${process.env.APP_URL || 'https://churchapp.com'}/invite/${invite.code}`,
    expiresAt: invite.expiresAt,
    usedCount: invite.usedCount,
  };
}

async function validateInviteLink(code: string) {
  const invite = await prisma.inviteLink.findUnique({
    where: { code },
    include: {
      church: { select: { id: true, name: true, logoUrl: true } },
      user: { select: { name: true } },
    },
  });

  if (!invite) throw ApiError.notFound('Invalid invite link');
  if (invite.expiresAt < new Date()) throw ApiError.badRequest('Invite link has expired');
  if (invite.maxUses && invite.usedCount >= invite.maxUses) {
    throw ApiError.badRequest('Invite link has reached max uses');
  }

  return {
    valid: true,
    church: invite.church,
    invitedBy: invite.user.name,
    expiresAt: invite.expiresAt,
  };
}

async function getUserInviteStats(userId: string) {
  const invites = await prisma.inviteLink.findMany({
    where: { userId },
    select: { usedCount: true, code: true, expiresAt: true, createdAt: true },
    orderBy: { createdAt: 'desc' },
  });

  return {
    totalInvitesSent: invites.length,
    totalJoined: invites.reduce((sum, i) => sum + i.usedCount, 0),
    invites,
  };
}

export const communityService = {
  // Announcements
  getAnnouncements,
  getAnnouncementById,
  markAnnouncementRead,
  // Testimonies
  getTestimonies,
  submitTestimony,
  reactToTestimony,
  // Directory
  getDirectory,
  // Invites
  generateInviteLink,
  validateInviteLink,
  getUserInviteStats,
};
