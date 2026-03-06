import { z } from 'zod';

export const volunteerValidation = {
  listOpportunities: z.object({
    query: z.object({
      page: z.coerce.number().int().positive().optional().default(1),
      limit: z.coerce.number().int().min(1).max(50).optional().default(20),
      department: z.string().optional(),
      active: z.coerce.boolean().optional(),
    }),
  }),

  signup: z.object({
    body: z.object({
      opportunityId: z.string().uuid(),
    }),
  }),

  listRoster: z.object({
    query: z.object({
      page: z.coerce.number().int().positive().optional().default(1),
      limit: z.coerce.number().int().min(1).max(50).optional().default(20),
      upcoming: z.coerce.boolean().optional().default(true),
    }),
  }),

  shiftId: z.object({
    params: z.object({ id: z.string().uuid() }),
  }),

  swapShift: z.object({
    params: z.object({ id: z.string().uuid() }),
    body: z.object({
      targetUserId: z.string().uuid(),
    }),
  }),
};

export type ListOpportunitiesInput = z.infer<typeof volunteerValidation.listOpportunities>['query'];
export type SignupInput = z.infer<typeof volunteerValidation.signup>['body'];
export type ListRosterInput = z.infer<typeof volunteerValidation.listRoster>['query'];
