import bcrypt from 'bcryptjs';
import prisma from '../../../config/database';
import { tokenService } from '../../../services/token.service';
import { ApiError } from '../../../utils/apiError';
import type { AdminLoginInput } from './admin-auth.validation';

const ADMIN_ROLES = new Set(['ADMIN', 'SUPER_ADMIN']);

function sanitizeUser(user: any) {
  const { passwordHash, verificationToken, verificationExpires, resetToken, resetTokenExpires, refreshToken, ...safe } = user;
  return safe;
}

export const adminAuthService = {
  async login(input: AdminLoginInput) {
    const user = await prisma.user.findUnique({
      where: { email: input.email.toLowerCase() },
      include: { church: { select: { id: true, name: true, code: true } } },
    });

    if (!user || !ADMIN_ROLES.has(user.role)) {
      throw ApiError.unauthorized('Invalid credentials or insufficient permissions');
    }

    if (!user.isActive) {
      throw ApiError.unauthorized('Account is deactivated');
    }

    const valid = await bcrypt.compare(input.password, user.passwordHash);
    if (!valid) {
      throw ApiError.unauthorized('Invalid credentials or insufficient permissions');
    }

    const payload = { sub: user.id, email: user.email, role: user.role, churchId: user.churchId };
    const { accessToken, refreshToken } = tokenService.generateTokenPair(payload);

    await prisma.user.update({ where: { id: user.id }, data: { refreshToken } });

    return { user: sanitizeUser(user), accessToken, refreshToken };
  },

  async refresh(refreshToken: string) {
    let decoded: any;
    try {
      decoded = tokenService.verifyRefreshToken(refreshToken);
    } catch {
      throw ApiError.unauthorized('Invalid or expired refresh token');
    }

    const user = await prisma.user.findUnique({
      where: { id: decoded.sub },
      select: { id: true, email: true, role: true, churchId: true, isActive: true, refreshToken: true },
    });

    if (!user || !user.isActive || user.refreshToken !== refreshToken || !ADMIN_ROLES.has(user.role)) {
      throw ApiError.unauthorized('Invalid refresh token');
    }

    const payload = { sub: user.id, email: user.email, role: user.role, churchId: user.churchId };
    const accessToken = tokenService.generateAccessToken(payload);

    return { accessToken };
  },

  async logout(userId: string) {
    await prisma.user.update({ where: { id: userId }, data: { refreshToken: null } });
  },

  async me(userId: string) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        name: true,
        email: true,
        role: true,
        avatarUrl: true,
        churchId: true,
        church: { select: { id: true, name: true, code: true } },
        createdAt: true,
      },
    });

    if (!user || !ADMIN_ROLES.has(user.role)) {
      throw ApiError.forbidden('Admin access required');
    }

    return user;
  },
};
