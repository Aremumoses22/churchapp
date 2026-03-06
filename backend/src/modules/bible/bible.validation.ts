import { z } from 'zod';

// ── Book / Chapter Params ───────────────────────────
export const chapterParamsSchema = z.object({
  bookId: z.string().uuid('Invalid book ID'),
  chapter: z.coerce.number().int().min(1),
});

// ── Bible Search ────────────────────────────────────
export const bibleSearchSchema = z.object({
  q: z.string().min(2, 'Search query must be at least 2 characters').max(255),
  limit: z.coerce.number().int().min(1).max(100).default(20),
});

// ── Add Highlight ───────────────────────────────────
export const addHighlightSchema = z.object({
  verseId: z.string().uuid('Invalid verse ID'),
  color: z.enum(['yellow', 'blue', 'green', 'pink', 'orange']).default('yellow'),
  note: z.string().max(2000).optional(),
});

// ── ID Param ────────────────────────────────────────
export const idParamSchema = z.object({
  id: z.string().uuid('Invalid ID format'),
});

// ── Devotional Date Param ───────────────────────────
export const dateParamSchema = z.object({
  date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'Date must be YYYY-MM-DD format'),
});

// ── Reading Plan List ───────────────────────────────
export const listReadingPlansSchema = z.object({
  category: z.string().max(100).optional(),
});

// ── Mark Day Complete ───────────────────────────────
export const markDayCompleteSchema = z.object({
  dayNumber: z.number().int().min(1),
});

// ── Types ───────────────────────────────────────────
export type ChapterParamsInput = z.infer<typeof chapterParamsSchema>;
export type BibleSearchInput = z.infer<typeof bibleSearchSchema>;
export type AddHighlightInput = z.infer<typeof addHighlightSchema>;
export type MarkDayCompleteInput = z.infer<typeof markDayCompleteSchema>;
