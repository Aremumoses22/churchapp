import prisma from '../../config/database';
import { ApiError } from '../../utils/apiError';
import { logger } from '../../utils/logger';
import QRCode from 'qrcode';
import { notifyKidsCheckIn, notifyKidsCheckOut } from '../../services/notification.triggers';
import type { ListChildrenInput, RegisterChildInput, CheckInInput, CheckOutInput } from './kids.validation';

function generateSecurityCode(): string {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

export const kidsService = {
  async listChildren(userId: string, input: ListChildrenInput) {
    const { page, limit } = input;
    const skip = (page - 1) * limit;

    const [children, total] = await Promise.all([
      prisma.child.findMany({
        where: { parentId: userId },
        include: {
          checkIns: {
            where: { status: 'CHECKED_IN' },
            include: { room: true },
            take: 1,
            orderBy: { checkedInAt: 'desc' },
          },
        },
        orderBy: { firstName: 'asc' },
        skip,
        take: limit,
      }),
      prisma.child.count({ where: { parentId: userId } }),
    ]);

    return {
      children: children.map((c) => ({
        ...c,
        currentCheckIn: c.checkIns[0] || null,
        checkIns: undefined,
      })),
      meta: { page, limit, total, totalPages: Math.ceil(total / limit) },
    };
  },

  async registerChild(userId: string, churchId: string, input: RegisterChildInput) {
    const child = await prisma.child.create({
      data: {
        parentId: userId,
        churchId,
        firstName: input.firstName,
        lastName: input.lastName,
        dateOfBirth: new Date(input.dateOfBirth),
        allergies: input.allergies,
        medicalNotes: input.medicalNotes,
        photoUrl: input.photoUrl,
      },
    });

    logger.info(`Child ${child.id} registered by user ${userId}`);
    return child;
  },

  async checkIn(operatorId: string, input: CheckInInput) {
    const { childId, roomId } = input;

    // Validate child exists
    const child = await prisma.child.findUnique({ where: { id: childId } });
    if (!child) throw ApiError.notFound('Child not found');

    // Validate room exists and has capacity
    const room = await prisma.room.findUnique({ where: { id: roomId } });
    if (!room) throw ApiError.notFound('Room not found');
    if (room.currentCount >= room.capacity) throw ApiError.badRequest('Room is at full capacity');

    // Check if child is already checked in
    const activeCheckIn = await prisma.checkIn.findFirst({
      where: { childId, status: 'CHECKED_IN' },
    });
    if (activeCheckIn) throw ApiError.conflict('Child is already checked in');

    const securityCode = generateSecurityCode();

    // Create check-in and update room count in a transaction
    const checkIn = await prisma.$transaction(async (tx) => {
      const ci = await tx.checkIn.create({
        data: {
          childId,
          roomId,
          parentId: child.parentId,
          checkedInBy: operatorId,
          securityCode,
        },
        include: {
          child: true,
          room: true,
        },
      });

      await tx.room.update({
        where: { id: roomId },
        data: { currentCount: { increment: 1 } },
      });

      return ci;
    });

    // Generate QR code for security code
    const qrCodeDataUrl = await QRCode.toDataURL(securityCode, { width: 300 });

    logger.info(`Child ${childId} checked into room ${roomId} by ${operatorId}, code: ${securityCode}`);

    // Send notification to parent
    notifyKidsCheckIn(child.parentId, `${checkIn.child.firstName} ${checkIn.child.lastName}`, checkIn.room.name, securityCode).catch(() => {});

    return {
      ...checkIn,
      qrCode: qrCodeDataUrl,
    };
  },

  async checkOut(input: CheckOutInput) {
    const { checkInId, securityCode } = input;

    const checkIn = await prisma.checkIn.findUnique({
      where: { id: checkInId },
      include: { child: true, room: true },
    });
    if (!checkIn) throw ApiError.notFound('Check-in record not found');
    if (checkIn.status !== 'CHECKED_IN') throw ApiError.badRequest('Child is not currently checked in');
    if (checkIn.securityCode !== securityCode) throw ApiError.forbidden('Invalid security code');

    const updated = await prisma.$transaction(async (tx) => {
      const ci = await tx.checkIn.update({
        where: { id: checkInId },
        data: { status: 'CHECKED_OUT', checkedOutAt: new Date() },
        include: { child: true, room: true },
      });

      await tx.room.update({
        where: { id: checkIn.roomId },
        data: { currentCount: { decrement: 1 } },
      });

      return ci;
    });

    logger.info(`Child ${checkIn.childId} checked out from room ${checkIn.roomId}`);

    // Send notification to parent
    notifyKidsCheckOut(checkIn.parentId, `${checkIn.child.firstName} ${checkIn.child.lastName}`, checkIn.room.name).catch(() => {});

    return updated;
  },

  async listRooms(churchId: string, page: number, limit: number) {
    const skip = (page - 1) * limit;

    const [rooms, total] = await Promise.all([
      prisma.room.findMany({
        where: { churchId },
        include: {
          _count: { select: { checkIns: true } },
        },
        orderBy: { name: 'asc' },
        skip,
        take: limit,
      }),
      prisma.room.count({ where: { churchId } }),
    ]);

    return {
      rooms: rooms.map((r) => ({
        ...r,
        activeCheckIns: r._count.checkIns,
        _count: undefined,
      })),
      meta: { page, limit, total, totalPages: Math.ceil(total / limit) },
    };
  },
};
