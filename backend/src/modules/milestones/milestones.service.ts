import prisma from '../../config/database';
import { ApiError } from '../../utils/apiError';
import { logger } from '../../utils/logger';
import type { ListMilestonesInput, CreateMilestoneInput } from './milestones.validation';

export const milestonesService = {
  // ────────────────────────────────────────────────────
  // GET USER MILESTONES
  // ────────────────────────────────────────────────────
  async getUserMilestones(userId: string, query: ListMilestonesInput) {
    const { page, limit, type } = query;

    const where: any = { userId };
    if (type) where.type = type;

    const [milestones, total] = await Promise.all([
      prisma.spiritualMilestone.findMany({
        where,
        orderBy: { achievedAt: 'desc' },
        skip: (page - 1) * limit,
        take: limit,
      }),
      prisma.spiritualMilestone.count({ where }),
    ]);

    return {
      milestones,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit),
      },
    };
  },

  // ────────────────────────────────────────────────────
  // CREATE MILESTONE (admin or system)
  // ────────────────────────────────────────────────────
  async createMilestone(churchId: string, input: CreateMilestoneInput) {
    // Verify user exists and belongs to church
    const user = await prisma.user.findFirst({
      where: { id: input.userId, churchId },
    });

    if (!user) {
      throw ApiError.notFound('User not found in this church');
    }

    // Check for duplicate milestone type
    const existing = await prisma.spiritualMilestone.findFirst({
      where: { userId: input.userId, type: input.type },
    });

    if (existing) {
      throw ApiError.conflict('User already has this milestone');
    }

    const milestone = await prisma.spiritualMilestone.create({
      data: {
        userId: input.userId,
        churchId,
        type: input.type,
        title: input.title,
        description: input.description,
        achievedAt: input.achievedAt || new Date(),
      },
    });

    logger.info(`Milestone created: ${input.type} for user ${input.userId}`);
    return milestone;
  },

  // ────────────────────────────────────────────────────
  // DELETE MILESTONE (admin)
  // ────────────────────────────────────────────────────
  async deleteMilestone(churchId: string, milestoneId: string) {
    const milestone = await prisma.spiritualMilestone.findFirst({
      where: { id: milestoneId, churchId },
    });

    if (!milestone) {
      throw ApiError.notFound('Milestone not found');
    }

    await prisma.spiritualMilestone.delete({ where: { id: milestoneId } });

    logger.info(`Milestone deleted: ${milestoneId}`);
    return { message: 'Milestone deleted' };
  },

  // ────────────────────────────────────────────────────
  // GET MILESTONE SUMMARY
  // ────────────────────────────────────────────────────
  async getMilestoneSummary(userId: string) {
    const milestones = await prisma.spiritualMilestone.findMany({
      where: { userId },
      orderBy: { achievedAt: 'asc' },
    });

    const allTypes = [
      'SALVATION', 'BAPTISM', 'FIRST_SERVE', 'SMALL_GROUP',
      'MINISTRY_LEADER', 'FIRST_GIVE', 'ONE_YEAR', 'INVITE_FRIEND',
    ];

    const earnedTypes = new Set(milestones.map((m) => m.type));

    return {
      earned: milestones.length,
      total: allTypes.length,
      milestones: allTypes.map((type) => ({
        type,
        earned: earnedTypes.has(type as any),
        milestone: milestones.find((m) => m.type === type) || null,
      })),
    };
  },
};
