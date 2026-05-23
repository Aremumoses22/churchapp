import prisma from '../../../config/database';
import { ApiError } from '../../../utils/apiError';

function cw(churchId: string | null | undefined) { return churchId ? { churchId } : {}; }
function requireChurch(churchId: string | null | undefined): string {
  if (!churchId) throw ApiError.badRequest('Church context required');
  return churchId;
}

export const adminForumService = {
  // ── Categories ─────────────────────────────────────────────
  async listCategories(churchId: string | null | undefined) {
    return prisma.forumCategory.findMany({
      where: cw(churchId),
      orderBy: { sortOrder: 'asc' },
      include: { _count: { select: { threads: true } } },
    });
  },

  async createCategory(churchId: string | null | undefined, data: { name: string; description?: string; iconUrl?: string; sortOrder?: number }) {
    const id = requireChurch(churchId);
    return prisma.forumCategory.create({ data: { ...data, churchId: id } });
  },

  async updateCategory(churchId: string | null | undefined, catId: string, data: any) {
    const cId = requireChurch(churchId);
    const existing = await prisma.forumCategory.findFirst({ where: { id: catId, churchId: cId } });
    if (!existing) throw ApiError.notFound('Category not found');
    return prisma.forumCategory.update({ where: { id: catId }, data });
  },

  async deleteCategory(churchId: string | null | undefined, catId: string) {
    const cId = requireChurch(churchId);
    const existing = await prisma.forumCategory.findFirst({ where: { id: catId, churchId: cId } });
    if (!existing) throw ApiError.notFound('Category not found');
    await prisma.forumCategory.delete({ where: { id: catId } });
  },

  // ── Threads ────────────────────────────────────────────────
  async listThreads(churchId: string | null | undefined, opts: { page: number; limit: number; search?: string; categoryId?: string }) {
    const where: any = { ...cw(churchId) };
    if (opts.search) where.OR = [{ title: { contains: opts.search, mode: 'insensitive' } }];
    if (opts.categoryId) where.categoryId = opts.categoryId;
    const skip = (opts.page - 1) * opts.limit;
    const [threads, total] = await Promise.all([
      prisma.forumThread.findMany({
        where,
        include: {
          author: { select: { id: true, name: true, avatarUrl: true } },
          category: { select: { id: true, name: true } },
        },
        orderBy: [{ isPinned: 'desc' }, { lastActivityAt: 'desc' }],
        skip,
        take: opts.limit,
      }),
      prisma.forumThread.count({ where }),
    ]);
    return { threads, total, page: opts.page, limit: opts.limit, totalPages: Math.ceil(total / opts.limit) };
  },

  async pinThread(churchId: string | null | undefined, threadId: string) {
    requireChurch(churchId);
    const thread = await prisma.forumThread.findFirst({ where: { id: threadId, ...cw(churchId) } });
    if (!thread) throw ApiError.notFound('Thread not found');
    return prisma.forumThread.update({ where: { id: threadId }, data: { isPinned: !thread.isPinned } });
  },

  async lockThread(churchId: string | null | undefined, threadId: string) {
    requireChurch(churchId);
    const thread = await prisma.forumThread.findFirst({ where: { id: threadId, ...cw(churchId) } });
    if (!thread) throw ApiError.notFound('Thread not found');
    return prisma.forumThread.update({ where: { id: threadId }, data: { isLocked: !thread.isLocked } });
  },

  async deleteThread(churchId: string | null | undefined, threadId: string) {
    requireChurch(churchId);
    const thread = await prisma.forumThread.findFirst({ where: { id: threadId, ...cw(churchId) } });
    if (!thread) throw ApiError.notFound('Thread not found');
    await prisma.forumThread.delete({ where: { id: threadId } });
  },
};
