import prisma from '../../config/database';
import { ApiError } from '../../utils/apiError';
import { logger } from '../../utils/logger';
import type { MarkDayCompleteInput } from './bible.validation';

export const readingPlansService = {
  // ────────────────────────────────────────────────────
  // BROWSE READING PLANS
  // ────────────────────────────────────────────────────
  async browse(churchId: string, category?: string) {
    const where: any = { churchId };
    if (category) where.category = category;

    const plans = await prisma.readingPlan.findMany({
      where,
      orderBy: { createdAt: 'desc' },
      include: {
        _count: { select: { days: true } },
      },
    });

    return plans.map((p) => ({
      ...p,
      dayCount: p._count.days,
      _count: undefined,
    }));
  },

  // ────────────────────────────────────────────────────
  // GET PLAN BY ID
  // ────────────────────────────────────────────────────
  async getById(planId: string, userId?: string) {
    const plan = await prisma.readingPlan.findUnique({
      where: { id: planId },
      include: {
        days: { orderBy: { dayNumber: 'asc' } },
      },
    });

    if (!plan) throw ApiError.notFound('Reading plan not found');

    let enrollment = null;
    let completedDays: number[] = [];

    if (userId) {
      enrollment = await prisma.userReadingPlan.findUnique({
        where: { userId_planId: { userId, planId } },
        include: {
          progress: {
            select: { dayNumber: true, completedAt: true },
          },
        },
      });

      if (enrollment) {
        completedDays = enrollment.progress.map((p) => p.dayNumber);
      }
    }

    return {
      ...plan,
      isEnrolled: !!enrollment,
      currentDay: enrollment?.currentDay || null,
      completedDays,
    };
  },

  // ────────────────────────────────────────────────────
  // ENROLL IN PLAN
  // ────────────────────────────────────────────────────
  async enroll(userId: string, planId: string) {
    const plan = await prisma.readingPlan.findUnique({ where: { id: planId } });
    if (!plan) throw ApiError.notFound('Reading plan not found');

    const existing = await prisma.userReadingPlan.findUnique({
      where: { userId_planId: { userId, planId } },
    });

    if (existing) throw ApiError.conflict('Already enrolled in this plan');

    const enrollment = await prisma.userReadingPlan.create({
      data: { userId, planId, currentDay: 1 },
    });

    // Increment enrolled count
    await prisma.readingPlan.update({
      where: { id: planId },
      data: { enrolledCount: { increment: 1 } },
    });

    logger.info(`User ${userId} enrolled in plan ${planId}`);
    return enrollment;
  },

  // ────────────────────────────────────────────────────
  // MARK DAY COMPLETE
  // ────────────────────────────────────────────────────
  async markDayComplete(userId: string, planId: string, input: MarkDayCompleteInput) {
    const enrollment = await prisma.userReadingPlan.findUnique({
      where: { userId_planId: { userId, planId } },
    });

    if (!enrollment) throw ApiError.notFound('Not enrolled in this plan');

    const plan = await prisma.readingPlan.findUnique({
      where: { id: planId },
      select: { durationDays: true },
    });

    if (input.dayNumber > (plan?.durationDays || 0)) {
      throw ApiError.badRequest('Day number exceeds plan duration');
    }

    // Find the ReadingPlanDay to link
    const planDay = await prisma.readingPlanDay.findUnique({
      where: { planId_dayNumber: { planId, dayNumber: input.dayNumber } },
    });

    // Mark day as complete (upsert to avoid duplicates)
    await prisma.userReadingPlanProgress.upsert({
      where: {
        userReadingPlanId_dayNumber: {
          userReadingPlanId: enrollment.id,
          dayNumber: input.dayNumber,
        },
      },
      update: { completedAt: new Date() },
      create: {
        userReadingPlanId: enrollment.id,
        dayNumber: input.dayNumber,
        readingPlanDayId: planDay?.id || null,
      },
    });

    // Update current day
    const nextDay = Math.min(input.dayNumber + 1, plan?.durationDays || input.dayNumber);
    const isComplete = input.dayNumber >= (plan?.durationDays || 0);

    await prisma.userReadingPlan.update({
      where: { userId_planId: { userId, planId } },
      data: {
        currentDay: nextDay,
        ...(isComplete && { completedAt: new Date() }),
      },
    });

    return {
      dayNumber: input.dayNumber,
      completed: true,
      planComplete: isComplete,
      nextDay: isComplete ? null : nextDay,
    };
  },

  // ────────────────────────────────────────────────────
  // GET MY PLANS
  // ────────────────────────────────────────────────────
  async getMyPlans(userId: string) {
    const enrollments = await prisma.userReadingPlan.findMany({
      where: { userId },
      orderBy: { startedAt: 'desc' },
      include: {
        plan: {
          select: {
            id: true, title: true, description: true, imageUrl: true,
            durationDays: true, category: true,
          },
        },
        progress: {
          select: { dayNumber: true },
        },
      },
    });

    return enrollments.map((e) => ({
      ...e.plan,
      startedAt: e.startedAt,
      completedAt: e.completedAt,
      currentDay: e.currentDay,
      daysCompleted: e.progress.length,
      progressPercent: Math.round((e.progress.length / e.plan.durationDays) * 100),
    }));
  },
};
