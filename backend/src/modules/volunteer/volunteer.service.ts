import prisma from '../../config/database';
import { ApiError } from '../../utils/apiError';
import { logger } from '../../utils/logger';
import { notifyVolunteerShiftSwap } from '../../services/notification.triggers';
import type { ListOpportunitiesInput, ListRosterInput } from './volunteer.validation';

export const volunteerService = {
  async listOpportunities(churchId: string, input: ListOpportunitiesInput) {
    const { page, limit, department, active } = input;
    const skip = (page - 1) * limit;

    const where: any = { churchId };
    if (active !== undefined) where.isActive = active;
    if (department) where.department = { contains: department, mode: 'insensitive' };

    const [opportunities, total] = await Promise.all([
      prisma.volunteerOpportunity.findMany({
        where,
        include: {
          _count: { select: { signups: true, shifts: true } },
        },
        orderBy: { createdAt: 'desc' },
        skip,
        take: limit,
      }),
      prisma.volunteerOpportunity.count({ where }),
    ]);

    return {
      opportunities: opportunities.map((o) => ({
        ...o,
        signupCount: o._count.signups,
        shiftCount: o._count.shifts,
        _count: undefined,
      })),
      meta: { page, limit, total, totalPages: Math.ceil(total / limit) },
    };
  },

  async signup(userId: string, opportunityId: string) {
    // Check opportunity exists and is active
    const opportunity = await prisma.volunteerOpportunity.findUnique({
      where: { id: opportunityId },
    });
    if (!opportunity) throw ApiError.notFound('Volunteer opportunity not found');
    if (!opportunity.isActive) throw ApiError.badRequest('This opportunity is no longer active');

    // Check if already signed up
    const existing = await prisma.volunteerSignup.findUnique({
      where: { userId_opportunityId: { userId, opportunityId } },
    });
    if (existing) throw ApiError.conflict('You have already signed up for this opportunity');

    const signup = await prisma.volunteerSignup.create({
      data: { userId, opportunityId },
      include: { opportunity: true },
    });

    logger.info(`User ${userId} signed up for volunteer opportunity ${opportunityId}`);
    return signup;
  },

  async listRoster(userId: string, input: ListRosterInput) {
    const { page, limit, upcoming } = input;
    const skip = (page - 1) * limit;

    const where: any = { userId };
    if (upcoming) {
      where.date = { gte: new Date() };
    } else {
      where.date = { lt: new Date() };
    }

    const [shifts, total] = await Promise.all([
      prisma.rosterShift.findMany({
        where,
        include: {
          opportunity: { select: { id: true, title: true, department: true } },
        },
        orderBy: upcoming ? { date: 'asc' } : { date: 'desc' },
        skip,
        take: limit,
      }),
      prisma.rosterShift.count({ where }),
    ]);

    return {
      shifts,
      meta: { page, limit, total, totalPages: Math.ceil(total / limit) },
    };
  },

  async checkin(userId: string, shiftId: string) {
    const shift = await prisma.rosterShift.findUnique({
      where: { id: shiftId },
    });
    if (!shift) throw ApiError.notFound('Shift not found');
    if (shift.userId !== userId) throw ApiError.forbidden('This is not your shift');
    if (shift.status !== 'SCHEDULED') throw ApiError.badRequest('Shift is not in SCHEDULED status');

    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const shiftDate = new Date(shift.date);
    shiftDate.setHours(0, 0, 0, 0);
    if (shiftDate.getTime() !== today.getTime()) {
      throw ApiError.badRequest('You can only check in on the day of the shift');
    }

    const updated = await prisma.rosterShift.update({
      where: { id: shiftId },
      data: { status: 'CHECKED_IN', checkinAt: new Date() },
      include: { opportunity: true },
    });

    logger.info(`User ${userId} checked in for shift ${shiftId}`);
    return updated;
  },

  async swapShift(userId: string, shiftId: string, targetUserId: string) {
    const shift = await prisma.rosterShift.findUnique({
      where: { id: shiftId },
    });
    if (!shift) throw ApiError.notFound('Shift not found');
    if (shift.userId !== userId) throw ApiError.forbidden('This is not your shift');
    if (shift.status !== 'SCHEDULED') throw ApiError.badRequest('Can only swap SCHEDULED shifts');

    // Verify target user exists
    const targetUser = await prisma.user.findUnique({ where: { id: targetUserId } });
    if (!targetUser) throw ApiError.notFound('Target user not found');

    // Swap the shift to the target user
    const updated = await prisma.rosterShift.update({
      where: { id: shiftId },
      data: { userId: targetUserId, status: 'SWAPPED' },
      include: { opportunity: true },
    });

    logger.info(`Shift ${shiftId} swapped from user ${userId} to ${targetUserId}`);

    // Notify target user about the swap
    const fromUser = await prisma.user.findUnique({ where: { id: userId }, select: { name: true } });
    const fromName = fromUser ? fromUser.name : 'A volunteer';
    notifyVolunteerShiftSwap(targetUserId, fromName, updated.opportunity.title, shift.date.toISOString().split('T')[0]).catch(() => {});

    return updated;
  },
};
