import prisma from '../../config/database';
import { ApiError } from '../../utils/apiError';
import { notifyForumReply, notifyForumThreadLike, notifyForumReplyLike } from '../../services/notification.triggers';

// ── Categories ──────────────────────────────────────
async function getCategories(churchId: string) {
  const categories = await prisma.forumCategory.findMany({
    where: { churchId },
    orderBy: { sortOrder: 'asc' },
  });
  return categories;
}

// ── Trending Threads ────────────────────────────────
async function getTrending(churchId: string, userId: string) {
  const sevenDaysAgo = new Date();
  sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

  const threads = await prisma.forumThread.findMany({
    where: {
      churchId,
      lastActivityAt: { gte: sevenDaysAgo },
    },
    include: {
      category: { select: { id: true, name: true } },
      author: { select: { id: true, name: true, avatarUrl: true } },
      likes: { where: { userId }, select: { id: true } },
      bookmarks: { where: { userId }, select: { id: true } },
    },
    orderBy: [{ likeCount: 'desc' }, { replyCount: 'desc' }],
    take: 10,
  });

  return threads.map(formatThread);
}

// ── Recent Threads ──────────────────────────────────
async function getRecent(
  churchId: string,
  userId: string,
  opts: { page: number; limit: number; sort: string },
) {
  const { page, limit, sort } = opts;

  const orderBy = getOrderBy(sort);

  const [threads, total] = await Promise.all([
    prisma.forumThread.findMany({
      where: { churchId },
      include: {
        category: { select: { id: true, name: true } },
        author: { select: { id: true, name: true, avatarUrl: true } },
        likes: { where: { userId }, select: { id: true } },
        bookmarks: { where: { userId }, select: { id: true } },
      },
      orderBy,
      skip: (page - 1) * limit,
      take: limit,
    }),
    prisma.forumThread.count({ where: { churchId } }),
  ]);

  return {
    data: threads.map(formatThread),
    meta: { page, limit, total, totalPages: Math.ceil(total / limit) },
  };
}

// ── Category Threads ────────────────────────────────
async function getCategoryThreads(
  categoryId: string,
  userId: string,
  opts: { page: number; limit: number; sort: string },
) {
  const { page, limit, sort } = opts;
  const orderBy = getOrderBy(sort);

  const category = await prisma.forumCategory.findUnique({ where: { id: categoryId } });
  if (!category) throw ApiError.notFound('Forum category not found');

  const [threads, total] = await Promise.all([
    prisma.forumThread.findMany({
      where: { categoryId },
      include: {
        category: { select: { id: true, name: true } },
        author: { select: { id: true, name: true, avatarUrl: true } },
        likes: { where: { userId }, select: { id: true } },
        bookmarks: { where: { userId }, select: { id: true } },
      },
      orderBy: [{ isPinned: 'desc' }, ...orderBy],
      skip: (page - 1) * limit,
      take: limit,
    }),
    prisma.forumThread.count({ where: { categoryId } }),
  ]);

  return {
    data: threads.map(formatThread),
    meta: { page, limit, total, totalPages: Math.ceil(total / limit) },
    category: { id: category.id, name: category.name, description: category.description },
  };
}

// ── Thread Detail ───────────────────────────────────
async function getThreadDetail(
  threadId: string,
  userId: string,
  opts: { page: number; limit: number },
) {
  const { page, limit } = opts;

  const thread = await prisma.forumThread.findUnique({
    where: { id: threadId },
    include: {
      category: { select: { id: true, name: true } },
      author: { select: { id: true, name: true, avatarUrl: true } },
      likes: { where: { userId }, select: { id: true } },
      bookmarks: { where: { userId }, select: { id: true } },
    },
  });

  if (!thread) throw ApiError.notFound('Thread not found');

  // Increment view count
  await prisma.forumThread.update({
    where: { id: threadId },
    data: { viewCount: { increment: 1 } },
  });

  // Get replies
  const [replies, totalReplies] = await Promise.all([
    prisma.forumReply.findMany({
      where: { threadId },
      include: {
        author: { select: { id: true, name: true, avatarUrl: true } },
        likes: { where: { userId }, select: { id: true } },
      },
      orderBy: { createdAt: 'asc' },
      skip: (page - 1) * limit,
      take: limit,
    }),
    prisma.forumReply.count({ where: { threadId } }),
  ]);

  return {
    thread: formatThread(thread),
    replies: {
      data: replies.map((r) => ({
        id: r.id,
        content: r.content,
        author: r.author,
        likeCount: r.likeCount,
        isLiked: r.likes.length > 0,
        createdAt: r.createdAt,
      })),
      meta: { page, limit, total: totalReplies, totalPages: Math.ceil(totalReplies / limit) },
    },
  };
}

// ── Create Thread ───────────────────────────────────
async function createThread(
  userId: string,
  churchId: string,
  data: { categoryId: string; title: string; content: string },
) {
  const category = await prisma.forumCategory.findUnique({ where: { id: data.categoryId } });
  if (!category) throw ApiError.notFound('Forum category not found');

  const [thread] = await prisma.$transaction([
    prisma.forumThread.create({
      data: {
        categoryId: data.categoryId,
        churchId,
        authorId: userId,
        title: data.title,
        content: data.content,
      },
      include: {
        category: { select: { id: true, name: true } },
        author: { select: { id: true, name: true, avatarUrl: true } },
      },
    }),
    prisma.forumCategory.update({
      where: { id: data.categoryId },
      data: { threadCount: { increment: 1 } },
    }),
  ]);

  return {
    ...thread,
    isLiked: false,
    isBookmarked: false,
  };
}

// ── Create Reply ────────────────────────────────────
async function createReply(
  threadId: string,
  userId: string,
  content: string,
) {
  const thread = await prisma.forumThread.findUnique({ where: { id: threadId } });
  if (!thread) throw ApiError.notFound('Thread not found');
  if (thread.isLocked) throw ApiError.badRequest('Thread is locked');

  const [reply] = await prisma.$transaction([
    prisma.forumReply.create({
      data: {
        threadId,
        authorId: userId,
        content,
      },
      include: {
        author: { select: { id: true, name: true, avatarUrl: true } },
      },
    }),
    prisma.forumThread.update({
      where: { id: threadId },
      data: {
        replyCount: { increment: 1 },
        lastActivityAt: new Date(),
      },
    }),
  ]);

  // Fire notification trigger (non-blocking)
  notifyForumReply(threadId, userId).catch(() => {});

  return {
    id: reply.id,
    content: reply.content,
    author: reply.author,
    likeCount: 0,
    isLiked: false,
    createdAt: reply.createdAt,
  };
}

// ── Toggle Like (Thread) ────────────────────────────
async function toggleThreadLike(threadId: string, userId: string) {
  const thread = await prisma.forumThread.findUnique({ where: { id: threadId } });
  if (!thread) throw ApiError.notFound('Thread not found');

  const existing = await prisma.forumLike.findUnique({
    where: { userId_threadId: { userId, threadId } },
  });

  if (existing) {
    await prisma.$transaction([
      prisma.forumLike.delete({ where: { userId_threadId: { userId, threadId } } }),
      prisma.forumThread.update({
        where: { id: threadId },
        data: { likeCount: { decrement: 1 } },
      }),
    ]);
    return { liked: false };
  }

  await prisma.$transaction([
    prisma.forumLike.create({ data: { userId, threadId } }),
    prisma.forumThread.update({
      where: { id: threadId },
      data: { likeCount: { increment: 1 } },
    }),
  ]);

  // Fire notification trigger (non-blocking)
  notifyForumThreadLike(threadId, userId).catch(() => {});

  return { liked: true };
}

// ── Toggle Bookmark ─────────────────────────────────
async function toggleBookmark(threadId: string, userId: string) {
  const thread = await prisma.forumThread.findUnique({ where: { id: threadId } });
  if (!thread) throw ApiError.notFound('Thread not found');

  const existing = await prisma.forumBookmark.findUnique({
    where: { userId_threadId: { userId, threadId } },
  });

  if (existing) {
    await prisma.forumBookmark.delete({ where: { userId_threadId: { userId, threadId } } });
    return { bookmarked: false };
  }

  await prisma.forumBookmark.create({ data: { userId, threadId } });
  return { bookmarked: true };
}

// ── Toggle Like (Reply) ────────────────────────────
async function toggleReplyLike(replyId: string, userId: string) {
  const reply = await prisma.forumReply.findUnique({ where: { id: replyId } });
  if (!reply) throw ApiError.notFound('Reply not found');

  const existing = await prisma.forumLike.findUnique({
    where: { userId_replyId: { userId, replyId } },
  });

  if (existing) {
    await prisma.$transaction([
      prisma.forumLike.delete({ where: { userId_replyId: { userId, replyId } } }),
      prisma.forumReply.update({
        where: { id: replyId },
        data: { likeCount: { decrement: 1 } },
      }),
    ]);
    return { liked: false };
  }

  await prisma.$transaction([
    prisma.forumLike.create({ data: { userId, replyId } }),
    prisma.forumReply.update({
      where: { id: replyId },
      data: { likeCount: { increment: 1 } },
    }),
  ]);

  // Fire notification trigger (non-blocking)
  notifyForumReplyLike(replyId, userId).catch(() => {});

  return { liked: true };
}

// ── Helpers ─────────────────────────────────────────
function getOrderBy(sort: string): any[] {
  switch (sort) {
    case 'popular':
      return [{ likeCount: 'desc' as const }, { replyCount: 'desc' as const }];
    case 'unanswered':
      return [{ replyCount: 'asc' as const }, { createdAt: 'desc' as const }];
    case 'recent':
    default:
      return [{ lastActivityAt: 'desc' as const }];
  }
}

function formatThread(t: any) {
  return {
    id: t.id,
    title: t.title,
    content: t.content,
    category: t.category,
    author: t.author,
    isPinned: t.isPinned,
    isLocked: t.isLocked,
    viewCount: t.viewCount,
    likeCount: t.likeCount,
    replyCount: t.replyCount,
    isLiked: (t.likes?.length || 0) > 0,
    isBookmarked: (t.bookmarks?.length || 0) > 0,
    lastActivityAt: t.lastActivityAt,
    createdAt: t.createdAt,
  };
}

export const forumService = {
  getCategories,
  getTrending,
  getRecent,
  getCategoryThreads,
  getThreadDetail,
  createThread,
  createReply,
  toggleThreadLike,
  toggleBookmark,
  toggleReplyLike,
};
