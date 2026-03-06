import { z } from 'zod';

// ── Save Item ───────────────────────────────────────
export const saveItemSchema = z.object({
  entityType: z.enum(['SERMON', 'EVENT', 'DEVOTIONAL', 'VERSE', 'THREAD', 'SONG']),
  entityId: z.string().uuid(),
});

// ── List Saved Items (query params) ─────────────────
export const listSavedItemsSchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  entityType: z.enum(['SERMON', 'EVENT', 'DEVOTIONAL', 'VERSE', 'THREAD', 'SONG']).optional(),
});

export type SaveItemInput = z.infer<typeof saveItemSchema>;
export type ListSavedItemsInput = z.infer<typeof listSavedItemsSchema>;
