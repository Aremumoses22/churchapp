import { z } from 'zod';

export const chatValidation = {
  listConversations: z.object({
    query: z.object({
      page: z.coerce.number().int().positive().optional().default(1),
      limit: z.coerce.number().int().min(1).max(50).optional().default(20),
    }),
  }),

  createConversation: z.object({
    body: z.object({
      type: z.enum(['DIRECT', 'GROUP']),
      name: z.string().min(1).max(255).optional(), // Required for GROUP
      memberIds: z.array(z.string().uuid()).min(1),
    }),
  }),

  getMessages: z.object({
    params: z.object({
      id: z.string().uuid(),
    }),
    query: z.object({
      page: z.coerce.number().int().positive().optional().default(1),
      limit: z.coerce.number().int().min(1).max(50).optional().default(30),
      before: z.string().datetime().optional(), // Cursor-based: get messages before this timestamp
    }),
  }),

  sendMessage: z.object({
    params: z.object({
      id: z.string().uuid(),
    }),
    body: z.object({
      content: z.string().min(1).max(5000),
      type: z.enum(['TEXT', 'IMAGE', 'AUDIO', 'VIDEO']).optional().default('TEXT'),
      mediaUrl: z.string().url().optional(),
      replyToId: z.string().uuid().optional(),
    }),
  }),

  conversationId: z.object({
    params: z.object({
      id: z.string().uuid(),
    }),
  }),
};
