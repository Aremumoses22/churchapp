import prisma from '../../../config/database';
import { ApiError } from '../../../utils/apiError';
import { DonationStatus } from '../../../generated/prisma/client';

function cw(churchId: string | null | undefined) { return churchId ? { churchId } : {}; }
function requireChurch(churchId: string | null | undefined): string {
  if (!churchId) throw ApiError.badRequest('Church context required');
  return churchId;
}

export const adminGivingService = {
  // ── Donations ──────────────────────────────────────────────
  async listDonations(churchId: string | null | undefined, opts: { page: number; limit: number; search?: string; status?: string; categoryId?: string; campaignId?: string }) {
    const where: any = { ...cw(churchId) };
    if (opts.search) where.OR = [{ transactionRef: { contains: opts.search, mode: 'insensitive' } }, { user: { name: { contains: opts.search, mode: 'insensitive' } } }];
    if (opts.status) where.status = opts.status as DonationStatus;
    if (opts.categoryId) where.categoryId = opts.categoryId;
    if (opts.campaignId) where.campaignId = opts.campaignId;
    const skip = (opts.page - 1) * opts.limit;
    const [donations, total] = await Promise.all([
      prisma.donation.findMany({
        where,
        include: {
          user: { select: { id: true, name: true, email: true, avatarUrl: true } },
          category: { select: { id: true, name: true } },
          campaign: { select: { id: true, title: true } },
        },
        orderBy: { createdAt: 'desc' },
        skip,
        take: opts.limit,
      }),
      prisma.donation.count({ where }),
    ]);
    return { donations, total, page: opts.page, limit: opts.limit, totalPages: Math.ceil(total / opts.limit) };
  },

  async getDonationSummary(churchId: string | null | undefined) {
    const cId = churchId;
    const where = cId ? { churchId: cId } : {};
    const successWhere = { ...where, status: DonationStatus.SUCCESS };
    const [totalRaised, totalCount, thisMonth, pendingCount] = await Promise.all([
      prisma.donation.aggregate({ where: successWhere, _sum: { amount: true } }),
      prisma.donation.count({ where: successWhere }),
      prisma.donation.aggregate({
        where: { ...successWhere, createdAt: { gte: new Date(new Date().getFullYear(), new Date().getMonth(), 1) } },
        _sum: { amount: true },
      }),
      prisma.donation.count({ where: { ...where, status: 'PENDING' } }),
    ]);
    return {
      totalRaised: totalRaised._sum?.amount ?? 0,
      totalCount,
      thisMonth: thisMonth._sum?.amount ?? 0,
      pendingCount,
    };
  },

  // ── Giving Categories ──────────────────────────────────────
  async listCategories(churchId: string | null | undefined) {
    return prisma.givingCategory.findMany({ where: cw(churchId), orderBy: { sortOrder: 'asc' } });
  },

  async createCategory(churchId: string | null | undefined, data: { name: string; description?: string; sortOrder?: number }) {
    const id = requireChurch(churchId);
    return prisma.givingCategory.create({ data: { ...data, churchId: id } });
  },

  async updateCategory(churchId: string | null | undefined, catId: string, data: any) {
    const cId = requireChurch(churchId);
    const existing = await prisma.givingCategory.findFirst({ where: { id: catId, churchId: cId } });
    if (!existing) throw ApiError.notFound('Category not found');
    return prisma.givingCategory.update({ where: { id: catId }, data });
  },

  async deleteCategory(churchId: string | null | undefined, catId: string) {
    const cId = requireChurch(churchId);
    const existing = await prisma.givingCategory.findFirst({ where: { id: catId, churchId: cId } });
    if (!existing) throw ApiError.notFound('Category not found');
    await prisma.givingCategory.delete({ where: { id: catId } });
  },

  // ── Giving Campaigns ───────────────────────────────────────
  async listCampaigns(churchId: string | null | undefined) {
    return prisma.givingCampaign.findMany({ where: cw(churchId), orderBy: { startDate: 'desc' }, include: { _count: { select: { donations: true } } } });
  },

  async createCampaign(churchId: string | null | undefined, data: { title: string; description?: string; goalAmount: number; startDate: string; endDate?: string; imageUrl?: string }) {
    const id = requireChurch(churchId);
    return prisma.givingCampaign.create({
      data: { ...data, churchId: id, startDate: new Date(data.startDate), endDate: data.endDate ? new Date(data.endDate) : null },
    });
  },

  async updateCampaign(churchId: string | null | undefined, campaignId: string, data: any) {
    const cId = requireChurch(churchId);
    const existing = await prisma.givingCampaign.findFirst({ where: { id: campaignId, churchId: cId } });
    if (!existing) throw ApiError.notFound('Campaign not found');
    if (data.startDate) data.startDate = new Date(data.startDate);
    if (data.endDate) data.endDate = new Date(data.endDate);
    return prisma.givingCampaign.update({ where: { id: campaignId }, data });
  },

  async deleteCampaign(churchId: string | null | undefined, campaignId: string) {
    const cId = requireChurch(churchId);
    const existing = await prisma.givingCampaign.findFirst({ where: { id: campaignId, churchId: cId } });
    if (!existing) throw ApiError.notFound('Campaign not found');
    await prisma.givingCampaign.delete({ where: { id: campaignId } });
  },
};
