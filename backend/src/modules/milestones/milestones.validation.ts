import { z } from 'zod';

// ── List Milestones (query params) ──────────────────
export const listMilestonesSchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  type: z.enum([
    'SALVATION', 'BAPTISM', 'FIRST_SERVE', 'SMALL_GROUP',
    'MINISTRY_LEADER', 'FIRST_GIVE', 'ONE_YEAR', 'INVITE_FRIEND',
  ]).optional(),
});

// ── Create Milestone (admin) ────────────────────────
export const createMilestoneSchema = z.object({
  userId: z.string().uuid(),
  type: z.enum([
    'SALVATION', 'BAPTISM', 'FIRST_SERVE', 'SMALL_GROUP',
    'MINISTRY_LEADER', 'FIRST_GIVE', 'ONE_YEAR', 'INVITE_FRIEND',
  ]),
  title: z.string().min(2).max(255),
  description: z.string().max(1000).optional(),
  achievedAt: z.coerce.date().optional(),
});

export type ListMilestonesInput = z.infer<typeof listMilestonesSchema>;
export type CreateMilestoneInput = z.infer<typeof createMilestoneSchema>;
