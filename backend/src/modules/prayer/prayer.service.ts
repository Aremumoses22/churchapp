import prisma from '../../config/database';
import { ApiError } from '../../utils/apiError';
import type { PrayerRequestStatus } from '../../generated/prisma/client';
import { notifyPrayerInteraction, notifyPrayerAnswered } from '../../services/notification.triggers';

// ── List Public Prayer Requests ─────────────────────
async function listPrayerRequests(
  churchId: string,
  userId: string,
  opts: { page: number; limit: number; status?: string },
) {
  const { page, limit, status } = opts;

  const where: any = { churchId };
  if (status) {
    where.status = status as PrayerRequestStatus;
  } else {
    where.status = 'ACTIVE';
  }

  const [requests, total] = await Promise.all([
    prisma.prayerRequest.findMany({
      where,
      include: {
        user: { select: { id: true, name: true, avatarUrl: true } },
        interactions: {
          where: { userId },
          select: { id: true },
        },
      },
      orderBy: [{ isUrgent: 'desc' }, { createdAt: 'desc' }],
      skip: (page - 1) * limit,
      take: limit,
    }),
    prisma.prayerRequest.count({ where }),
  ]);

  return {
    data: requests.map((r) => ({
      id: r.id,
      title: r.title,
      content: r.content,
      isAnonymous: r.isAnonymous,
      isUrgent: r.isUrgent,
      status: r.status,
      prayerCount: r.prayerCount,
      hasPrayed: r.interactions.length > 0,
      author: r.isAnonymous ? null : { id: r.user.id, name: r.user.name, avatarUrl: r.user.avatarUrl },
      createdAt: r.createdAt,
    })),
    meta: { page, limit, total, totalPages: Math.ceil(total / limit) },
  };
}

// ── User's Own Requests ─────────────────────────────
async function getMyRequests(
  userId: string,
  opts: { page: number; limit: number },
) {
  const { page, limit } = opts;

  const [requests, total] = await Promise.all([
    prisma.prayerRequest.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
      skip: (page - 1) * limit,
      take: limit,
    }),
    prisma.prayerRequest.count({ where: { userId } }),
  ]);

  return {
    data: requests,
    meta: { page, limit, total, totalPages: Math.ceil(total / limit) },
  };
}

// ── Submit Prayer Request ───────────────────────────
async function createPrayerRequest(
  userId: string,
  churchId: string,
  data: { title: string; content: string; isAnonymous?: boolean; isUrgent?: boolean },
) {
  const request = await prisma.prayerRequest.create({
    data: {
      userId,
      churchId,
      title: data.title,
      content: data.content,
      isAnonymous: data.isAnonymous || false,
      isUrgent: data.isUrgent || false,
    },
  });

  return request;
}

// ── "I Prayed For This" ─────────────────────────────
async function prayForRequest(prayerRequestId: string, userId: string) {
  const request = await prisma.prayerRequest.findUnique({ where: { id: prayerRequestId } });
  if (!request) throw ApiError.notFound('Prayer request not found');
  if (request.status !== 'ACTIVE') throw ApiError.badRequest('Prayer request is no longer active');

  const existing = await prisma.prayerInteraction.findUnique({
    where: { userId_prayerRequestId: { userId, prayerRequestId } },
  });

  if (existing) {
    // Toggle off
    await prisma.$transaction([
      prisma.prayerInteraction.delete({
        where: { userId_prayerRequestId: { userId, prayerRequestId } },
      }),
      prisma.prayerRequest.update({
        where: { id: prayerRequestId },
        data: { prayerCount: { decrement: 1 } },
      }),
    ]);
    return { prayed: false };
  }

  await prisma.$transaction([
    prisma.prayerInteraction.create({
      data: { userId, prayerRequestId },
    }),
    prisma.prayerRequest.update({
      where: { id: prayerRequestId },
      data: { prayerCount: { increment: 1 } },
    }),
  ]);

  // Fire notification trigger (non-blocking)
  notifyPrayerInteraction(prayerRequestId, userId).catch(() => {});

  return { prayed: true };
}

// ── Update Status (owner only) ──────────────────────
async function updateStatus(
  prayerRequestId: string,
  userId: string,
  status: PrayerRequestStatus,
) {
  const request = await prisma.prayerRequest.findUnique({ where: { id: prayerRequestId } });
  if (!request) throw ApiError.notFound('Prayer request not found');
  if (request.userId !== userId) throw ApiError.forbidden('Only the author can update status');

  const updated = await prisma.prayerRequest.update({
    where: { id: prayerRequestId },
    data: { status },
  });

  // Notify those who prayed if status is ANSWERED
  if (status === 'ANSWERED') {
    notifyPrayerAnswered(prayerRequestId).catch(() => {});
  }

  return updated;
}

export const prayerService = {
  listPrayerRequests,
  getMyRequests,
  createPrayerRequest,
  prayForRequest,
  updateStatus,
};
