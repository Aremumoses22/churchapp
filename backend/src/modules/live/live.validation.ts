import { z } from 'zod';

export const liveValidation = {
  list: z.object({
    query: z.object({
      status: z.enum(['SCHEDULED', 'LIVE', 'ENDED']).optional(),
      page: z.coerce.number().int().positive().optional().default(1),
      limit: z.coerce.number().int().min(1).max(50).optional().default(10),
    }),
  }),

  getById: z.object({
    params: z.object({
      id: z.string().uuid(),
    }),
  }),

  getChatMessages: z.object({
    params: z.object({
      id: z.string().uuid(),
    }),
    query: z.object({
      page: z.coerce.number().int().positive().optional().default(1),
      limit: z.coerce.number().int().min(1).max(100).optional().default(50),
    }),
  }),
};
