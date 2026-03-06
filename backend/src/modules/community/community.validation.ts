import { z } from 'zod/v4';

export const idParamSchema = z.object({
  params: z.object({ id: z.string().uuid() }),
});

export const listAnnouncementsSchema = z.object({
  query: z.object({
    page: z.string().default('1').transform(Number),
    limit: z.string().default('20').transform(Number),
    category: z.string().optional(),
  }),
});
