import { z } from 'zod/v4';

export const searchValidation = {
  search: z.object({
    query: z.object({
      q: z.string().min(1).max(200),
      type: z.enum(['all', 'sermons', 'events', 'groups', 'people', 'forum', 'media']).default('all').optional(),
      page: z.coerce.number().int().positive().default(1).optional(),
      limit: z.coerce.number().int().positive().max(50).default(20).optional(),
    }),
  }),

  trending: z.object({
    query: z.object({
      limit: z.coerce.number().int().positive().max(20).default(10).optional(),
    }),
  }),
};

export type SearchInput = {
  q: string;
  type: string;
  page: number;
  limit: number;
};
