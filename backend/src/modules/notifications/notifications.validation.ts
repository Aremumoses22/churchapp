import { z } from 'zod';

export const notificationsValidation = {
  list: z.object({
    query: z.object({
      page: z.coerce.number().int().positive().optional().default(1),
      limit: z.coerce.number().int().min(1).max(50).optional().default(20),
      type: z.enum([
        'SERMON', 'EVENT', 'CHAT', 'GIVING', 'PRAYER',
        'ANNOUNCEMENT', 'GROUP', 'FORUM', 'VOLUNTEER',
        'DEVOTIONAL', 'PERSONAL', 'SECURITY', 'SYSTEM',
      ]).optional(),
      unreadOnly: z.coerce.boolean().optional().default(false),
    }),
  }),

  markRead: z.object({
    params: z.object({
      id: z.string().uuid(),
    }),
  }),

  delete: z.object({
    params: z.object({
      id: z.string().uuid(),
    }),
  }),
};
