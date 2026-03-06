import prisma from '../../config/database';
import { ApiError } from '../../utils/apiError';
import type { BibleSearchInput, AddHighlightInput } from './bible.validation';

export const bibleService = {
  // ────────────────────────────────────────────────────
  // GET ALL BOOKS
  // ────────────────────────────────────────────────────
  async getBooks() {
    const books = await prisma.bibleBook.findMany({
      orderBy: { bookOrder: 'asc' },
      select: {
        id: true,
        name: true,
        abbreviation: true,
        testament: true,
        bookOrder: true,
        chapterCount: true,
      },
    });

    return books;
  },

  // ────────────────────────────────────────────────────
  // GET CHAPTER VERSES
  // ────────────────────────────────────────────────────
  async getChapter(bookId: string, chapter: number, userId?: string) {
    // Verify book exists
    const book = await prisma.bibleBook.findUnique({ where: { id: bookId } });
    if (!book) throw ApiError.notFound('Book not found');

    if (chapter < 1 || chapter > book.chapterCount) {
      throw ApiError.badRequest(`Chapter must be between 1 and ${book.chapterCount}`);
    }

    const verses = await prisma.bibleVerse.findMany({
      where: { bookId, chapter },
      orderBy: { verse: 'asc' },
      select: { id: true, verse: true, text: true },
    });

    // Get user highlights for this chapter if authenticated
    let highlights: Record<string, { color: string; note: string | null }> = {};
    if (userId && verses.length > 0) {
      const verseIds = verses.map((v) => v.id);
      const userHighlights = await prisma.userVerseHighlight.findMany({
        where: { userId, verseId: { in: verseIds } },
      });
      highlights = Object.fromEntries(
        userHighlights.map((h) => [h.verseId, { color: h.color, note: h.note }]),
      );
    }

    return {
      book: { id: book.id, name: book.name, abbreviation: book.abbreviation },
      chapter,
      verses: verses.map((v) => ({
        ...v,
        highlight: highlights[v.id] || null,
      })),
    };
  },

  // ────────────────────────────────────────────────────
  // SEARCH VERSES
  // ────────────────────────────────────────────────────
  async searchVerses(input: BibleSearchInput) {
    const { q, limit } = input;

    // Use Prisma contains for basic search
    // (Upgrade to tsvector full-text in Phase 7)
    const verses = await prisma.bibleVerse.findMany({
      where: {
        text: { contains: q, mode: 'insensitive' },
      },
      take: limit,
      include: {
        book: { select: { name: true, abbreviation: true } },
      },
    });

    return verses.map((v) => ({
      id: v.id,
      reference: `${v.book.name} ${v.chapter}:${v.verse}`,
      abbreviation: `${v.book.abbreviation} ${v.chapter}:${v.verse}`,
      text: v.text,
    }));
  },

  // ────────────────────────────────────────────────────
  // GET USER HIGHLIGHTS
  // ────────────────────────────────────────────────────
  async getHighlights(userId: string) {
    const highlights = await prisma.userVerseHighlight.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
      include: {
        verse: {
          include: {
            book: { select: { name: true, abbreviation: true } },
          },
        },
      },
    });

    return highlights.map((h) => ({
      id: h.id,
      color: h.color,
      note: h.note,
      reference: `${h.verse.book.name} ${h.verse.chapter}:${h.verse.verse}`,
      text: h.verse.text,
      createdAt: h.createdAt,
    }));
  },

  // ────────────────────────────────────────────────────
  // ADD HIGHLIGHT
  // ────────────────────────────────────────────────────
  async addHighlight(userId: string, input: AddHighlightInput) {
    // Verify verse exists
    const verse = await prisma.bibleVerse.findUnique({ where: { id: input.verseId } });
    if (!verse) throw ApiError.notFound('Verse not found');

    const highlight = await prisma.userVerseHighlight.upsert({
      where: { userId_verseId: { userId, verseId: input.verseId } },
      update: { color: input.color, note: input.note },
      create: {
        userId,
        verseId: input.verseId,
        color: input.color,
        note: input.note,
      },
    });

    return highlight;
  },

  // ────────────────────────────────────────────────────
  // REMOVE HIGHLIGHT
  // ────────────────────────────────────────────────────
  async removeHighlight(userId: string, highlightId: string) {
    const highlight = await prisma.userVerseHighlight.findUnique({
      where: { id: highlightId },
    });

    if (!highlight || highlight.userId !== userId) {
      throw ApiError.notFound('Highlight not found');
    }

    await prisma.userVerseHighlight.delete({ where: { id: highlightId } });

    return { message: 'Highlight removed' };
  },
};
