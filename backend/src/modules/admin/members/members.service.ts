import prisma from '../../../config/database';
import { DonationStatus } from '../../../generated/prisma/client';
import { ApiError } from '../../../utils/apiError';
import { emailService } from '../../../services/email.service';
import { generateToken, hashToken, getExpiryDate } from '../../../utils/helpers';
import bcrypt from 'bcryptjs';

const SAFE_SELECT = {
  id: true,
  name: true,
  email: true,
  role: true,
  avatarUrl: true,
  phone: true,
  bio: true,
  department: true,
  isActive: true,
  emailVerified: true,
  churchId: true,
  createdAt: true,
  updatedAt: true,
  church: { select: { id: true, name: true } },
};

function churchWhere(churchId: string | null | undefined) {
  return churchId ? { churchId } : {};
}

const ELEVATED_ROLES = new Set(['ADMIN', 'SUPER_ADMIN']);

export const membersService = {
  async list(churchId: string | null | undefined, opts: {
    page: number; limit: number; search?: string; role?: string; status?: string;
  }) {
    const where: any = { ...churchWhere(churchId) };

    if (opts.search) {
      where.OR = [
        { name: { contains: opts.search, mode: 'insensitive' } },
        { email: { contains: opts.search, mode: 'insensitive' } },
      ];
    }
    if (opts.role) where.role = opts.role;
    if (opts.status === 'active') where.isActive = true;
    if (opts.status === 'inactive') where.isActive = false;

    const skip = (opts.page - 1) * opts.limit;
    const [members, total] = await Promise.all([
      prisma.user.findMany({ where, select: SAFE_SELECT, orderBy: { createdAt: 'desc' }, skip, take: opts.limit }),
      prisma.user.count({ where }),
    ]);

    return { members, total, page: opts.page, limit: opts.limit, totalPages: Math.ceil(total / opts.limit) };
  },

  async getById(churchId: string | null | undefined, id: string) {
    const member = await prisma.user.findFirst({
      where: { id, ...churchWhere(churchId) },
      select: { ...SAFE_SELECT, _count: { select: { donations: true, eventRegistrations: true, groupMemberships: true } } },
    });
    if (!member) throw ApiError.notFound('Member not found');
    return member;
  },

  async update(churchId: string | null | undefined, id: string, data: { name?: string; phone?: string; bio?: string; department?: string }) {
    const member = await prisma.user.findFirst({ where: { id, ...churchWhere(churchId) } });
    if (!member) throw ApiError.notFound('Member not found');

    return prisma.user.update({ where: { id }, data, select: SAFE_SELECT });
  },

  async changeRole(callerRole: string, churchId: string | null | undefined, id: string, role: string) {
    const member = await prisma.user.findFirst({ where: { id, ...churchWhere(churchId) } });
    if (!member) throw ApiError.notFound('Member not found');

    // Only SUPER_ADMIN can promote to ADMIN or SUPER_ADMIN
    if (ELEVATED_ROLES.has(role) && callerRole !== 'SUPER_ADMIN') {
      throw ApiError.forbidden('Only SUPER_ADMIN can assign ADMIN or SUPER_ADMIN roles');
    }
    // Prevent demoting a SUPER_ADMIN unless caller is also SUPER_ADMIN
    if (member.role === 'SUPER_ADMIN' && callerRole !== 'SUPER_ADMIN') {
      throw ApiError.forbidden('Cannot modify a SUPER_ADMIN account');
    }

    return prisma.user.update({ where: { id }, data: { role: role as any }, select: SAFE_SELECT });
  },

  async setStatus(churchId: string | null | undefined, id: string, isActive: boolean) {
    const member = await prisma.user.findFirst({ where: { id, ...churchWhere(churchId) } });
    if (!member) throw ApiError.notFound('Member not found');
    return prisma.user.update({ where: { id }, data: { isActive }, select: SAFE_SELECT });
  },

  async delete(callerRole: string, churchId: string | null | undefined, id: string) {
    const member = await prisma.user.findFirst({ where: { id, ...churchWhere(churchId) } });
    if (!member) throw ApiError.notFound('Member not found');
    if (member.role === 'SUPER_ADMIN' && callerRole !== 'SUPER_ADMIN') {
      throw ApiError.forbidden('Cannot delete a SUPER_ADMIN account');
    }
    await prisma.user.delete({ where: { id } });
  },

  async givingHistory(churchId: string | null | undefined, id: string) {
    const member = await prisma.user.findFirst({ where: { id, ...churchWhere(churchId) } });
    if (!member) throw ApiError.notFound('Member not found');

    const donations = await prisma.donation.findMany({
      where: { userId: id, ...churchWhere(churchId) },
      orderBy: { createdAt: 'desc' },
      take: 50,
      select: {
        id: true, amount: true, currency: true, status: true, paymentMethod: true,
        createdAt: true, transactionRef: true,
        category: { select: { name: true } },
      },
    });

    const total = await prisma.donation.aggregate({
      where: { userId: id, ...churchWhere(churchId), status: DonationStatus.SUCCESS },
      _sum: { amount: true },
    });

    return { donations, totalGiven: total._sum?.amount ?? 0 };
  },

  async invite(churchId: string | null | undefined, input: { email: string; name: string; role: string }) {
    if (!churchId) throw ApiError.badRequest('Church context required to invite members');

    const existing = await prisma.user.findUnique({ where: { email: input.email.toLowerCase() } });
    if (existing) throw ApiError.conflict('A user with this email already exists');

    const rawToken = generateToken();
    const verificationToken = hashToken(rawToken);
    const tempPassword = generateToken().slice(0, 12);
    const passwordHash = await bcrypt.hash(tempPassword, 12);

    const user = await prisma.user.create({
      data: {
        name: input.name,
        email: input.email.toLowerCase(),
        passwordHash,
        role: input.role as any,
        churchId,
        verificationToken,
        verificationExpires: getExpiryDate('7d'),
      },
    });

    emailService.sendVerificationEmail(input.email, input.name, rawToken).catch(() => {});

    return { id: user.id, name: user.name, email: user.email, role: user.role };
  },

  async exportCsv(churchId: string | null | undefined) {
    const members = await prisma.user.findMany({
      where: churchWhere(churchId),
      select: { id: true, name: true, email: true, role: true, department: true, phone: true, isActive: true, emailVerified: true, createdAt: true },
      orderBy: { name: 'asc' },
    });

    const header = 'ID,Name,Email,Role,Department,Phone,Active,Verified,Joined';
    const rows = members.map((m) =>
      [m.id, `"${m.name}"`, m.email, m.role, m.department ?? '', m.phone ?? '', m.isActive, m.emailVerified, m.createdAt.toISOString()].join(','),
    );
    return [header, ...rows].join('\n');
  },
};
