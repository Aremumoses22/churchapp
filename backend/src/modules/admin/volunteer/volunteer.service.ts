import prisma from '../../../config/database';
import { ApiError } from '../../../utils/apiError';

function cw(churchId: string | null | undefined) { return churchId ? { churchId } : {}; }
function requireChurch(churchId: string | null | undefined): string {
  if (!churchId) throw ApiError.badRequest('Church context required');
  return churchId;
}

export const adminVolunteerService = {
  // ── Opportunities ─────────────────────────────────────────
  async listOpportunities(churchId: string | null | undefined, opts: { page: number; limit: number; search?: string; department?: string }) {
    const where: any = { ...cw(churchId) };
    if (opts.search) where.OR = [{ title: { contains: opts.search, mode: 'insensitive' } }, { description: { contains: opts.search, mode: 'insensitive' } }];
    if (opts.department) where.department = opts.department;
    const skip = (opts.page - 1) * opts.limit;
    const [opportunities, total] = await Promise.all([
      prisma.volunteerOpportunity.findMany({
        where,
        include: { _count: { select: { signups: true } } },
        orderBy: { createdAt: 'desc' },
        skip,
        take: opts.limit,
      }),
      prisma.volunteerOpportunity.count({ where }),
    ]);
    return { opportunities, total, page: opts.page, limit: opts.limit, totalPages: Math.ceil(total / opts.limit) };
  },

  async createOpportunity(churchId: string | null | undefined, data: { title: string; description?: string; department: string; requirements?: string; imageUrl?: string; isActive?: boolean }) {
    const id = requireChurch(churchId);
    return prisma.volunteerOpportunity.create({ data: { ...data, churchId: id } });
  },

  async updateOpportunity(churchId: string | null | undefined, oppId: string, data: any) {
    const cId = requireChurch(churchId);
    const existing = await prisma.volunteerOpportunity.findFirst({ where: { id: oppId, churchId: cId } });
    if (!existing) throw ApiError.notFound('Opportunity not found');
    return prisma.volunteerOpportunity.update({ where: { id: oppId }, data });
  },

  async deleteOpportunity(churchId: string | null | undefined, oppId: string) {
    const cId = requireChurch(churchId);
    const existing = await prisma.volunteerOpportunity.findFirst({ where: { id: oppId, churchId: cId } });
    if (!existing) throw ApiError.notFound('Opportunity not found');
    await prisma.volunteerOpportunity.delete({ where: { id: oppId } });
  },

  async toggleOpportunityActive(churchId: string | null | undefined, oppId: string) {
    const cId = requireChurch(churchId);
    const existing = await prisma.volunteerOpportunity.findFirst({ where: { id: oppId, churchId: cId } });
    if (!existing) throw ApiError.notFound('Opportunity not found');
    return prisma.volunteerOpportunity.update({ where: { id: oppId }, data: { isActive: !existing.isActive } });
  },

  // ── Signups ───────────────────────────────────────────────
  async listSignups(churchId: string | null | undefined, oppId: string) {
    const cId = requireChurch(churchId);
    const opp = await prisma.volunteerOpportunity.findFirst({ where: { id: oppId, churchId: cId } });
    if (!opp) throw ApiError.notFound('Opportunity not found');
    return prisma.volunteerSignup.findMany({
      where: { opportunityId: oppId },
      include: { user: { select: { id: true, name: true, email: true, avatarUrl: true, phone: true } } },
      orderBy: { appliedAt: 'desc' },
    });
  },

  async updateSignupStatus(signupId: string, status: string) {
    const existing = await prisma.volunteerSignup.findUnique({ where: { id: signupId } });
    if (!existing) throw ApiError.notFound('Signup not found');
    return prisma.volunteerSignup.update({ where: { id: signupId }, data: { status: status as any } });
  },
};
