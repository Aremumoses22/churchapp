import bcrypt from 'bcryptjs';
import prisma from '../../config/database';
import { ApiError } from '../../utils/apiError';
import { emailService } from '../../services/email.service';
import type { CreateChurchInput, UpdateChurchInput, SuspendChurchInput } from './churches.validation';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

const CHURCH_SELECT = {
  id: true,
  name: true,
  tagline: true,
  code: true,
  email: true,
  phone: true,
  address: true,
  website: true,
  logoUrl: true,
  isActive: true,
  suspendedAt: true,
  suspendReason: true,
  createdAt: true,
  updatedAt: true,
  _count: {
    select: { users: true, sermons: true, events: true },
  },
};

/** Generate a unique 6-char alphanumeric uppercase code. */
async function generateUniqueCode(): Promise<string> {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  for (let attempt = 0; attempt < 10; attempt++) {
    let code = '';
    for (let i = 0; i < 6; i++) {
      code += chars[Math.floor(Math.random() * chars.length)];
    }
    const existing = await prisma.church.findUnique({ where: { code }, select: { id: true } });
    if (!existing) return code;
  }
  throw new Error('Could not generate a unique church code after 10 attempts');
}

// ─────────────────────────────────────────────────────────────────────────────
// Service
// ─────────────────────────────────────────────────────────────────────────────

export const superAdminChurchService = {

  // ── List all churches ────────────────────────────────────────────────────
  async list(opts: { page: number; limit: number; search?: string; status?: string }) {
    const where: any = {};
    if (opts.search) {
      where.OR = [
        { name: { contains: opts.search, mode: 'insensitive' } },
        { email: { contains: opts.search, mode: 'insensitive' } },
        { code: { contains: opts.search, mode: 'insensitive' } },
      ];
    }
    if (opts.status === 'active') where.isActive = true;
    if (opts.status === 'suspended') where.isActive = false;

    const skip = (opts.page - 1) * opts.limit;
    const [churches, total] = await Promise.all([
      prisma.church.findMany({
        where,
        select: CHURCH_SELECT,
        orderBy: { createdAt: 'desc' },
        skip,
        take: opts.limit,
      }),
      prisma.church.count({ where }),
    ]);

    return { churches, total, page: opts.page, limit: opts.limit, totalPages: Math.ceil(total / opts.limit) };
  },

  // ── Get one church detail ────────────────────────────────────────────────
  async getById(id: string) {
    const church = await prisma.church.findUnique({
      where: { id },
      select: {
        ...CHURCH_SELECT,
        mission: true,
        vision: true,
        socialLinks: true,
        settings: true,
        users: {
          where: { role: { in: ['ADMIN', 'SUPER_ADMIN'] } },
          select: { id: true, name: true, email: true, role: true, isActive: true, avatarUrl: true, createdAt: true },
          orderBy: { role: 'asc' },
        },
        campuses: { select: { id: true, name: true, address: true, isPrimary: true } },
      },
    });
    if (!church) throw ApiError.notFound('Church not found');
    return church;
  },

  // ── Create church + admin account ────────────────────────────────────────
  async create(input: CreateChurchInput) {
    const code = await generateUniqueCode();

    // Check admin email not already in use
    const existingUser = await prisma.user.findUnique({
      where: { email: input.adminEmail.toLowerCase() },
      select: { id: true },
    });
    if (existingUser) throw ApiError.conflict('An account with that admin email already exists');

    const passwordHash = await bcrypt.hash(input.adminPassword, 12);

    const church = await prisma.$transaction(async (tx) => {
      const newChurch = await tx.church.create({
        data: {
          name: input.name,
          tagline: input.tagline,
          email: input.email,
          phone: input.phone,
          address: input.address,
          website: input.website || undefined,
          code,
        },
      });

      await tx.user.create({
        data: {
          churchId: newChurch.id,
          name: input.adminName,
          email: input.adminEmail.toLowerCase(),
          passwordHash,
          emailVerified: true,
          hasCompletedSetup: true,
          role: 'ADMIN',
        },
      });

      return newChurch;
    });

    // Send welcome email to church admin (fire-and-forget)
    emailService.sendChurchAdminWelcome({
      to: input.adminEmail,
      adminName: input.adminName,
      churchName: input.name,
      churchCode: code,
      adminPassword: input.adminPassword,
    }).catch(() => {});

    return prisma.church.findUnique({ where: { id: church.id }, select: CHURCH_SELECT });
  },

  // ── Update church info ───────────────────────────────────────────────────
  async update(id: string, input: UpdateChurchInput) {
    await prisma.church.findUnique({ where: { id }, select: { id: true } }).then((c) => {
      if (!c) throw ApiError.notFound('Church not found');
    });
    return prisma.church.update({ where: { id }, data: input, select: CHURCH_SELECT });
  },

  // ── Suspend church ───────────────────────────────────────────────────────
  async suspend(id: string, input: SuspendChurchInput) {
    const church = await prisma.church.findUnique({ where: { id }, select: { id: true, isActive: true } });
    if (!church) throw ApiError.notFound('Church not found');
    if (!church.isActive) throw ApiError.badRequest('Church is already suspended');

    return prisma.church.update({
      where: { id },
      data: { isActive: false, suspendedAt: new Date(), suspendReason: input.reason },
      select: CHURCH_SELECT,
    });
  },

  // ── Unsuspend church ─────────────────────────────────────────────────────
  async unsuspend(id: string) {
    const church = await prisma.church.findUnique({ where: { id }, select: { id: true, isActive: true } });
    if (!church) throw ApiError.notFound('Church not found');
    if (church.isActive) throw ApiError.badRequest('Church is not suspended');

    return prisma.church.update({
      where: { id },
      data: { isActive: true, suspendedAt: null, suspendReason: null },
      select: CHURCH_SELECT,
    });
  },

  // ── Regenerate church code ───────────────────────────────────────────────
  async regenerateCode(id: string) {
    const church = await prisma.church.findUnique({ where: { id }, select: { id: true } });
    if (!church) throw ApiError.notFound('Church not found');
    const code = await generateUniqueCode();
    return prisma.church.update({ where: { id }, data: { code }, select: CHURCH_SELECT });
  },

  // ── Delete church ────────────────────────────────────────────────────────
  async delete(id: string) {
    const church = await prisma.church.findUnique({ where: { id }, select: { id: true } });
    if (!church) throw ApiError.notFound('Church not found');
    await prisma.church.delete({ where: { id } });
  },

  // ── List church members (all roles) ─────────────────────────────────────
  async listMembers(id: string, opts: { page: number; limit: number; search?: string; role?: string }) {
    const church = await prisma.church.findUnique({ where: { id }, select: { id: true } });
    if (!church) throw ApiError.notFound('Church not found');

    const where: any = { churchId: id };
    if (opts.search) {
      where.OR = [
        { name: { contains: opts.search, mode: 'insensitive' } },
        { email: { contains: opts.search, mode: 'insensitive' } },
      ];
    }
    if (opts.role) where.role = opts.role;

    const skip = (opts.page - 1) * opts.limit;
    const [members, total] = await Promise.all([
      prisma.user.findMany({
        where,
        select: {
          id: true, name: true, email: true, role: true, isActive: true,
          avatarUrl: true, department: true, createdAt: true,
        },
        orderBy: { createdAt: 'desc' },
        skip,
        take: opts.limit,
      }),
      prisma.user.count({ where }),
    ]);

    return { members, total, page: opts.page, limit: opts.limit, totalPages: Math.ceil(total / opts.limit) };
  },

  // ── Remove a member from a church ───────────────────────────────────────
  async removeMember(churchId: string, userId: string) {
    const user = await prisma.user.findFirst({
      where: { id: userId, churchId },
      select: { id: true, role: true },
    });
    if (!user) throw ApiError.notFound('Member not found in this church');
    if (user.role === 'SUPER_ADMIN') throw ApiError.forbidden('Cannot remove a super admin');

    await prisma.user.update({ where: { id: userId }, data: { churchId: null } });
  },

  // ── Platform-wide stats (for super admin overview) ───────────────────────
  async platformStats() {
    const [totalChurches, activeChurches, suspendedChurches, totalUsers, newChurchesThisMonth] =
      await Promise.all([
        prisma.church.count(),
        prisma.church.count({ where: { isActive: true } }),
        prisma.church.count({ where: { isActive: false } }),
        prisma.user.count(),
        prisma.church.count({
          where: { createdAt: { gte: new Date(new Date().getFullYear(), new Date().getMonth(), 1) } },
        }),
      ]);

    return { totalChurches, activeChurches, suspendedChurches, totalUsers, newChurchesThisMonth };
  },
};
