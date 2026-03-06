import { z } from 'zod/v4';

export const idParamSchema = z.object({
  params: z.object({ id: z.string().uuid() }),
});

export const listPrayerRequestsSchema = z.object({
  query: z.object({
    page: z.string().default('1').transform(Number),
    limit: z.string().default('20').transform(Number),
    status: z.enum(['ACTIVE', 'ANSWERED', 'CLOSED']).optional(),
  }),
});

export const createPrayerRequestSchema = z.object({
  body: z.object({
    title: z.string().min(3).max(255),
    content: z.string().min(10),
    isAnonymous: z.boolean().default(false),
    isUrgent: z.boolean().default(false),
  }),
});

export const updateStatusSchema = z.object({
  params: z.object({ id: z.string().uuid() }),
  body: z.object({
    status: z.enum(['ANSWERED', 'CLOSED']),
  }),
});
