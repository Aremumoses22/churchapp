// ═══════════════════════════════════════════════════════════════
// Milestones Job Processors
// Phase 7: Background Job Processing
// ═══════════════════════════════════════════════════════════════

import type { Job } from 'bullmq';
import prisma from '../../config/database';
import { logger } from '../../utils/logger';
import type { MilestoneType } from '../../generated/prisma/client';

interface MilestoneCheck {
  type: MilestoneType;
  title: string;
  description: string;
  check: (userId: string, churchId: string) => Promise<boolean>;
}

/**
 * Generate milestones for all active users.
 * Checks various conditions and awards milestones automatically.
 */
export async function generateMilestones(job: Job): Promise<void> {
  logger.info('[Job] Generating spiritual milestones...');

  const users = await prisma.user.findMany({
    where: { isActive: true, churchId: { not: null } },
    select: { id: true, churchId: true, createdAt: true },
  });

  const milestoneChecks: MilestoneCheck[] = [
    {
      type: 'FIRST_SERVE',
      title: 'First Serve',
      description: 'You signed up to volunteer for the first time!',
      check: async (userId) => {
        const count = await prisma.volunteerSignup.count({
          where: { userId, status: 'APPROVED' },
        });
        return count >= 1;
      },
    },
    {
      type: 'SMALL_GROUP',
      title: 'Connected',
      description: 'You joined your first connect group!',
      check: async (userId) => {
        const count = await prisma.groupMembership.count({
          where: { userId },
        });
        return count >= 1;
      },
    },
    {
      type: 'FIRST_GIVE',
      title: 'First Gift',
      description: 'You made your first donation!',
      check: async (userId) => {
        const count = await prisma.donation.count({
          where: { userId, status: 'SUCCESS' },
        });
        return count >= 1;
      },
    },
    {
      type: 'ONE_YEAR',
      title: 'One Year Anniversary',
      description: 'You have been a member for one year!',
      check: async (userId) => {
        const user = await prisma.user.findUnique({
          where: { id: userId },
          select: { createdAt: true },
        });
        if (!user) return false;
        const oneYearAgo = new Date();
        oneYearAgo.setFullYear(oneYearAgo.getFullYear() - 1);
        return user.createdAt <= oneYearAgo;
      },
    },
    {
      type: 'INVITE_FRIEND',
      title: 'Inviter',
      description: 'You invited a friend to the church!',
      check: async (userId) => {
        const count = await prisma.inviteLink.count({
          where: { userId, usedCount: { gt: 0 } },
        });
        return count >= 1;
      },
    },
    {
      type: 'MINISTRY_LEADER',
      title: 'Ministry Leader',
      description: 'You became a leader of a connect group!',
      check: async (userId) => {
        const count = await prisma.connectGroup.count({
          where: { leaderId: userId },
        });
        return count >= 1;
      },
    },
  ];

  let totalGenerated = 0;

  for (const user of users) {
    if (!user.churchId) continue;

    // Get existing milestones for this user
    const existingMilestones = await prisma.spiritualMilestone.findMany({
      where: { userId: user.id },
      select: { type: true },
    });
    const existingTypes = new Set(existingMilestones.map((m) => m.type));

    for (const milestone of milestoneChecks) {
      if (existingTypes.has(milestone.type)) continue; // Already earned

      try {
        const earned = await milestone.check(user.id, user.churchId);
        if (earned) {
          await prisma.spiritualMilestone.create({
            data: {
              userId: user.id,
              churchId: user.churchId,
              type: milestone.type,
              title: milestone.title,
              description: milestone.description,
            },
          });
          totalGenerated++;
          logger.info(`[Job] Milestone "${milestone.title}" awarded to user ${user.id}`);
        }
      } catch (error) {
        logger.error(`[Job] Failed milestone check ${milestone.type} for user ${user.id}:`, error);
      }
    }
  }

  logger.info(`[Job] Milestones generated: ${totalGenerated} new milestones`);
}
