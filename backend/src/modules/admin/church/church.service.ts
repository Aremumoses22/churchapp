import prisma from '../../../config/database';
import { ApiError } from '../../../utils/apiError';

function requireChurch(churchId: string | null | undefined): string {
  if (!churchId) throw ApiError.badRequest('Church context required');
  return churchId;
}

export const adminChurchService = {
  // ── Church Info ──────────────────────────────────────────────
  async get(churchId: string | null | undefined) {
    const id = requireChurch(churchId);
    const church = await prisma.church.findUnique({
      where: { id },
      include: {
        staffMembers: { orderBy: { sortOrder: 'asc' } },
        campuses: { include: { serviceTimes: true }, orderBy: { isPrimary: 'desc' } },
        faqs: { orderBy: { sortOrder: 'asc' } },
        coreValues: { orderBy: { sortOrder: 'asc' } },
      },
    });
    if (!church) throw ApiError.notFound('Church not found');
    return church;
  },

  async updateInfo(churchId: string | null | undefined, data: {
    name?: string; tagline?: string; mission?: string; vision?: string;
    phone?: string; email?: string; website?: string; address?: string; ein?: string;
    socialLinks?: Record<string, string>;
  }) {
    const id = requireChurch(churchId);
    return prisma.church.update({ where: { id }, data });
  },

  async updateLogo(churchId: string | null | undefined, logoUrl: string) {
    const id = requireChurch(churchId);
    return prisma.church.update({ where: { id }, data: { logoUrl } });
  },

  async updateCoverImage(churchId: string | null | undefined, coverImageUrl: string) {
    const id = requireChurch(churchId);
    return prisma.church.update({ where: { id }, data: { coverImageUrl } });
  },

  // ── Timeline (stored in church.settings JSON) ────────────────
  async updateTimeline(churchId: string | null | undefined, timeline: any[]) {
    const id = requireChurch(churchId);
    const church = await prisma.church.findUnique({ where: { id }, select: { settings: true } });
    if (!church) throw ApiError.notFound('Church not found');
    const settings = (church.settings as any) ?? {};
    return prisma.church.update({ where: { id }, data: { settings: { ...settings, timeline } } });
  },

  // ── Staff ────────────────────────────────────────────────────
  async listStaff(churchId: string | null | undefined) {
    const id = requireChurch(churchId);
    return prisma.staffMember.findMany({ where: { churchId: id }, orderBy: { sortOrder: 'asc' } });
  },

  async createStaff(churchId: string | null | undefined, data: { name: string; title: string; bio?: string; imageUrl?: string; email?: string; phone?: string; sortOrder?: number }) {
    const id = requireChurch(churchId);
    return prisma.staffMember.create({ data: { ...data, churchId: id } });
  },

  async updateStaff(churchId: string | null | undefined, staffId: string, data: { name?: string; title?: string; bio?: string; imageUrl?: string; email?: string; phone?: string; sortOrder?: number }) {
    const id = requireChurch(churchId);
    const existing = await prisma.staffMember.findFirst({ where: { id: staffId, churchId: id } });
    if (!existing) throw ApiError.notFound('Staff member not found');
    return prisma.staffMember.update({ where: { id: staffId }, data });
  },

  async deleteStaff(churchId: string | null | undefined, staffId: string) {
    const id = requireChurch(churchId);
    const existing = await prisma.staffMember.findFirst({ where: { id: staffId, churchId: id } });
    if (!existing) throw ApiError.notFound('Staff member not found');
    await prisma.staffMember.delete({ where: { id: staffId } });
  },

  // ── Campuses ─────────────────────────────────────────────────
  async listCampuses(churchId: string | null | undefined) {
    const id = requireChurch(churchId);
    return prisma.campus.findMany({ where: { churchId: id }, include: { serviceTimes: true }, orderBy: { isPrimary: 'desc' } });
  },

  async createCampus(churchId: string | null | undefined, data: { name: string; address: string; phone?: string; email?: string; imageUrl?: string; isPrimary?: boolean }) {
    const id = requireChurch(churchId);
    return prisma.campus.create({ data: { ...data, churchId: id } });
  },

  async updateCampus(churchId: string | null | undefined, campusId: string, data: { name?: string; address?: string; phone?: string; email?: string; imageUrl?: string; isPrimary?: boolean }) {
    const id = requireChurch(churchId);
    const existing = await prisma.campus.findFirst({ where: { id: campusId, churchId: id } });
    if (!existing) throw ApiError.notFound('Campus not found');
    return prisma.campus.update({ where: { id: campusId }, data, include: { serviceTimes: true } });
  },

  async deleteCampus(churchId: string | null | undefined, campusId: string) {
    const id = requireChurch(churchId);
    const existing = await prisma.campus.findFirst({ where: { id: campusId, churchId: id } });
    if (!existing) throw ApiError.notFound('Campus not found');
    await prisma.campus.delete({ where: { id: campusId } });
  },

  async upsertServiceTimes(campusId: string, churchId: string | null | undefined, times: { dayOfWeek: string; time: string; label?: string }[]) {
    const id = requireChurch(churchId);
    const campus = await prisma.campus.findFirst({ where: { id: campusId, churchId: id } });
    if (!campus) throw ApiError.notFound('Campus not found');
    await prisma.serviceTime.deleteMany({ where: { campusId } });
    const created = await prisma.serviceTime.createMany({ data: times.map((t) => ({ ...t, campusId })) });
    return created;
  },

  // ── FAQs ─────────────────────────────────────────────────────
  async listFaqs(churchId: string | null | undefined) {
    const id = requireChurch(churchId);
    return prisma.fAQ.findMany({ where: { churchId: id }, orderBy: { sortOrder: 'asc' } });
  },

  async createFaq(churchId: string | null | undefined, data: { question: string; answer: string; category?: string; sortOrder?: number }) {
    const id = requireChurch(churchId);
    return prisma.fAQ.create({ data: { ...data, churchId: id } });
  },

  async updateFaq(churchId: string | null | undefined, faqId: string, data: { question?: string; answer?: string; category?: string; sortOrder?: number }) {
    const id = requireChurch(churchId);
    const existing = await prisma.fAQ.findFirst({ where: { id: faqId, churchId: id } });
    if (!existing) throw ApiError.notFound('FAQ not found');
    return prisma.fAQ.update({ where: { id: faqId }, data });
  },

  async deleteFaq(churchId: string | null | undefined, faqId: string) {
    const id = requireChurch(churchId);
    const existing = await prisma.fAQ.findFirst({ where: { id: faqId, churchId: id } });
    if (!existing) throw ApiError.notFound('FAQ not found');
    await prisma.fAQ.delete({ where: { id: faqId } });
  },

  // ── Core Values ──────────────────────────────────────────────
  async listCoreValues(churchId: string | null | undefined) {
    const id = requireChurch(churchId);
    return prisma.coreValue.findMany({ where: { churchId: id }, orderBy: { sortOrder: 'asc' } });
  },

  async createCoreValue(churchId: string | null | undefined, data: { title: string; description: string; iconUrl?: string; sortOrder?: number }) {
    const id = requireChurch(churchId);
    return prisma.coreValue.create({ data: { ...data, churchId: id } });
  },

  async updateCoreValue(churchId: string | null | undefined, valueId: string, data: { title?: string; description?: string; iconUrl?: string; sortOrder?: number }) {
    const id = requireChurch(churchId);
    const existing = await prisma.coreValue.findFirst({ where: { id: valueId, churchId: id } });
    if (!existing) throw ApiError.notFound('Core value not found');
    return prisma.coreValue.update({ where: { id: valueId }, data });
  },

  async deleteCoreValue(churchId: string | null | undefined, valueId: string) {
    const id = requireChurch(churchId);
    const existing = await prisma.coreValue.findFirst({ where: { id: valueId, churchId: id } });
    if (!existing) throw ApiError.notFound('Core value not found');
    await prisma.coreValue.delete({ where: { id: valueId } });
  },
};
