import { z } from 'zod';

// ── List Events Query ───────────────────────────────
export const listEventsSchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(50).default(20),
  category: z.string().max(100).optional(),
  upcoming: z.string().optional().default('true').transform((v) => v === 'true'),
  search: z.string().max(255).optional(),
});

// ── ID Param ────────────────────────────────────────
export const idParamSchema = z.object({
  id: z.string().uuid('Invalid ID format'),
});

// ── Types ───────────────────────────────────────────
export type ListEventsInput = z.infer<typeof listEventsSchema>;
