import prisma from '../../../config/database';
import { ApiError } from '../../../utils/apiError';

function cw(churchId: string | null | undefined) {
  return churchId ? { churchId } : {};
}

export const adminSermonsService = {
  // ── Series ───────────────────────────────────────────────────
  async listSeries(churchId: string | null | undefined) {
    return prisma.sermonSeries.findMany({
      where: cw(churchId),
      include: { _count: { select: { sermons: true } } },
      orderBy: { startDate: 'desc' },
    });
  },

  async createSeries(churchId: string | null | undefined, data: { title: string; description?: string; artworkUrl?: string; startDate?: string; endDate?: string }) {
    if (!churchId) throw ApiError.badRequest('Church context required');
    return prisma.sermonSeries.create({ data: { ...data, churchId, startDate: data.startDate ? new Date(data.startDate) : null, endDate: data.endDate ? new Date(data.endDate) : null } as any });
  },

  async updateSeries(churchId: string | null | undefined, id: string, data: any) {
    const existing = await prisma.sermonSeries.findFirst({ where: { id, ...cw(churchId) } });
    if (!existing) throw ApiError.notFound('Series not found');
    return prisma.sermonSeries.update({ where: { id }, data });
  },

  async deleteSeries(churchId: string | null | undefined, id: string) {
    const existing = await prisma.sermonSeries.findFirst({ where: { id, ...cw(churchId) } });
    if (!existing) throw ApiError.notFound('Series not found');
    await prisma.sermonSeries.delete({ where: { id } });
  },

  // ── Sermons ──────────────────────────────────────────────────
  async list(churchId: string | null | undefined, opts: { page: number; limit: number; search?: string; seriesId?: string; featured?: boolean }) {
    const where: any = { ...cw(churchId) };
    if (opts.search) where.OR = [{ title: { contains: opts.search, mode: 'insensitive' } }, { speaker: { contains: opts.search, mode: 'insensitive' } }];
    if (opts.seriesId) where.seriesId = opts.seriesId;
    if (opts.featured !== undefined) where.isFeatured = opts.featured;

    const skip = (opts.page - 1) * opts.limit;
    const [sermons, total] = await Promise.all([
      prisma.sermon.findMany({ where, include: { series: { select: { id: true, title: true } } }, orderBy: { date: 'desc' }, skip, take: opts.limit }),
      prisma.sermon.count({ where }),
    ]);
    return { sermons, total, page: opts.page, limit: opts.limit, totalPages: Math.ceil(total / opts.limit) };
  },

  async getById(churchId: string | null | undefined, id: string) {
    const sermon = await prisma.sermon.findFirst({ where: { id, ...cw(churchId) }, include: { series: true } });
    if (!sermon) throw ApiError.notFound('Sermon not found');
    return sermon;
  },

  async create(churchId: string | null | undefined, data: {
    title: string; speaker: string; description?: string; date: string;
    audioUrl?: string; videoUrl?: string; thumbnailUrl?: string; scriptureRef?: string;
    seriesId?: string; tags?: string[];
  }) {
    if (!churchId) throw ApiError.badRequest('Church context required');
    return prisma.sermon.create({ data: { ...data, churchId, date: new Date(data.date) } });
  },

  async update(churchId: string | null | undefined, id: string, data: any) {
    const existing = await prisma.sermon.findFirst({ where: { id, ...cw(churchId) } });
    if (!existing) throw ApiError.notFound('Sermon not found');
    if (data.date) data.date = new Date(data.date);
    return prisma.sermon.update({ where: { id }, data });
  },

  async delete(churchId: string | null | undefined, id: string) {
    const existing = await prisma.sermon.findFirst({ where: { id, ...cw(churchId) } });
    if (!existing) throw ApiError.notFound('Sermon not found');
    await prisma.sermon.delete({ where: { id } });
  },

  async toggleFeatured(churchId: string | null | undefined, id: string) {
    const existing = await prisma.sermon.findFirst({ where: { id, ...cw(churchId) } });
    if (!existing) throw ApiError.notFound('Sermon not found');
    return prisma.sermon.update({ where: { id }, data: { isFeatured: !existing.isFeatured } });
  },
};
