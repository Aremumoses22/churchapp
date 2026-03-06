import { z } from 'zod/v4';

// ── Shared ──────────────────────────────────────────
export const idParamSchema = z.object({
  params: z.object({ id: z.string().uuid() }),
});

export const paginationSchema = z.object({
  query: z.object({
    page: z.string().default('1').transform(Number),
    limit: z.string().default('20').transform(Number),
  }),
});

// ── Groups ──────────────────────────────────────────
export const listGroupsSchema = z.object({
  query: z.object({
    page: z.string().default('1').transform(Number),
    limit: z.string().default('20').transform(Number),
    category: z.string().optional(),
    search: z.string().optional(),
  }),
});
