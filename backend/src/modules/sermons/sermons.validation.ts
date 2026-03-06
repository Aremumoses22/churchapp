import { z } from 'zod';

// ── List Sermons Query ──────────────────────────────
export const listSermonsSchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(50).default(20),
  seriesId: z.string().uuid().optional(),
  speaker: z.string().max(255).optional(),
  search: z.string().max(255).optional(),
  tag: z.string().max(50).optional(),
  startDate: z.string().optional(),
  endDate: z.string().optional(),
});

// ── Save Progress ───────────────────────────────────
export const saveProgressSchema = z.object({
  position: z.number().int().min(0),
  completed: z.boolean().optional(),
});

// ── Save / Update Notes ─────────────────────────────
export const saveNotesSchema = z.object({
  content: z.string().min(1, 'Notes content is required').max(50000),
});

// ── ID Param ────────────────────────────────────────
export const idParamSchema = z.object({
  id: z.string().uuid('Invalid ID format'),
});

// ── Types ───────────────────────────────────────────
export type ListSermonsInput = z.infer<typeof listSermonsSchema>;
export type SaveProgressInput = z.infer<typeof saveProgressSchema>;
export type SaveNotesInput = z.infer<typeof saveNotesSchema>;
