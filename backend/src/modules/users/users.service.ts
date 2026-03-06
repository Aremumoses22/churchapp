import prisma from '../../config/database';
import { uploadService } from '../../services/upload.service';
import { ApiError } from '../../utils/apiError';
import { logger } from '../../utils/logger';
import { attendanceService } from '../attendance/attendance.service';
import { milestonesService } from '../milestones/milestones.service';
import { savedItemsService } from '../saved-items/saved-items.service';
import type {
  UpdateProfileInput,
  UpdateNotificationPrefsInput,
  UpdateFcmTokenInput,
} from './users.validation';

// ── Sanitize user for response ──────────────────────
function sanitizeUser(user: any) {
  const {
    passwordHash,
    verificationToken,
    verificationExpires,
    resetToken,
    resetTokenExpires,
    refreshToken,
    ...safe
  } = user;
  return safe;
}

export const usersService = {
  // ────────────────────────────────────────────────────
  // GET CURRENT USER PROFILE
  // ────────────────────────────────────────────────────
  async getProfile(userId: string) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: {
        church: {
          select: {
            id: true,
            name: true,
            tagline: true,
            code: true,
            logoUrl: true,
          },
        },
      },
    });

    if (!user) {
      throw ApiError.notFound('User not found');
    }

    return sanitizeUser(user);
  },

  // ────────────────────────────────────────────────────
  // UPDATE PROFILE
  // ────────────────────────────────────────────────────
  async updateProfile(userId: string, input: UpdateProfileInput) {
    const user = await prisma.user.update({
      where: { id: userId },
      data: {
        ...(input.name !== undefined && { name: input.name }),
        ...(input.phone !== undefined && { phone: input.phone }),
        ...(input.bio !== undefined && { bio: input.bio }),
        ...(input.department !== undefined && { department: input.department }),
        ...(input.isDirectoryVisible !== undefined && { isDirectoryVisible: input.isDirectoryVisible }),
      },
      include: {
        church: {
          select: { id: true, name: true, tagline: true, code: true, logoUrl: true },
        },
      },
    });

    logger.info(`Profile updated: ${userId}`);
    return sanitizeUser(user);
  },

  // ────────────────────────────────────────────────────
  // UPDATE AVATAR
  // ────────────────────────────────────────────────────
  async updateAvatar(userId: string, fileBuffer: Buffer) {
    // Upload to Cloudinary
    const result = await uploadService.uploadAvatar(fileBuffer, userId);

    // Update user avatar URL
    const user = await prisma.user.update({
      where: { id: userId },
      data: { avatarUrl: result.secureUrl },
    });

    logger.info(`Avatar updated: ${userId}`);
    return { avatarUrl: user.avatarUrl };
  },

  // ────────────────────────────────────────────────────
  // UPDATE NOTIFICATION PREFERENCES
  // ────────────────────────────────────────────────────
  async updateNotificationPrefs(userId: string, input: UpdateNotificationPrefsInput) {
    // Merge with existing prefs
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { notificationPrefs: true },
    });

    const currentPrefs = (user?.notificationPrefs || {}) as Record<string, unknown>;
    const mergedPrefs = { ...currentPrefs, ...input };

    await prisma.user.update({
      where: { id: userId },
      data: { notificationPrefs: mergedPrefs },
    });

    logger.info(`Notification prefs updated: ${userId}`);
    return { notificationPrefs: mergedPrefs };
  },

  // ────────────────────────────────────────────────────
  // UPDATE FCM TOKEN
  // ────────────────────────────────────────────────────
  async updateFcmToken(userId: string, input: UpdateFcmTokenInput) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { fcmTokens: true },
    });

    if (!user) throw ApiError.notFound('User not found');

    // Add token if not already present (max 5 devices)
    const tokens = user.fcmTokens.filter((t) => t !== input.fcmToken);
    tokens.push(input.fcmToken);

    // Keep only the last 5 tokens
    const updatedTokens = tokens.slice(-5);

    await prisma.user.update({
      where: { id: userId },
      data: { fcmTokens: updatedTokens },
    });

    logger.info(`FCM token updated: ${userId}`);
    return { message: 'FCM token registered' };
  },

  // ────────────────────────────────────────────────────
  // GET ATTENDANCE HISTORY
  // ────────────────────────────────────────────────────
  async getAttendance(userId: string) {
    const [history, streak] = await Promise.all([
      attendanceService.getAttendanceHistory(userId, { page: 1, limit: 10 }),
      attendanceService.getAttendanceStreak(userId),
    ]);
    return {
      ...history,
      streak: streak.currentStreak,
      totalAttendances: streak.totalAttendances,
    };
  },

  // ────────────────────────────────────────────────────
  // GET SPIRITUAL MILESTONES
  // ────────────────────────────────────────────────────
  async getMilestones(userId: string) {
    return milestonesService.getMilestoneSummary(userId);
  },

  // ────────────────────────────────────────────────────
  // SAVED ITEMS
  // ────────────────────────────────────────────────────
  async getSavedItems(userId: string) {
    return savedItemsService.listSavedItems(userId, { page: 1, limit: 20 });
  },

  async addSavedItem(userId: string, entityType: string, entityId: string) {
    return savedItemsService.saveItem(userId, { entityType: entityType as any, entityId });
  },

  async removeSavedItem(userId: string, savedItemId: string) {
    return savedItemsService.removeSavedItem(userId, savedItemId);
  },
};
