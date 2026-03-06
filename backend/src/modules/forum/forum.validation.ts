import { z } from 'zod/v4';

export const idParamSchema = z.object({
  params: z.object({ id: z.string().uuid() }),
});

export const listThreadsSchema = z.object({
  query: z.object({
    page: z.string().default('1').transform(Number),
    limit: z.string().default('20').transform(Number),
    sort: z.enum(['recent', 'popular', 'unanswered']).default('recent'),
  }),
});

export const categoryThreadsSchema = z.object({
  params: z.object({ id: z.string().uuid() }),
  query: z.object({
    page: z.string().default('1').transform(Number),
    limit: z.string().default('20').transform(Number),
    sort: z.enum(['recent', 'popular', 'unanswered']).default('recent'),
  }),
});

export const createThreadSchema = z.object({
  body: z.object({
    categoryId: z.string().uuid(),
    title: z.string().min(3).max(500),
    content: z.string().min(10),
  }),
});

export const createReplySchema = z.object({
  params: z.object({ id: z.string().uuid() }),
  body: z.object({
    content: z.string().min(1),
  }),
});

export const threadDetailSchema = z.object({
  params: z.object({ id: z.string().uuid() }),
  query: z.object({
    page: z.string().default('1').transform(Number),
    limit: z.string().default('20').transform(Number),
  }),
});
