import bcrypt from 'bcryptjs';
import prisma from '../../config/database';
import { tokenService } from '../../services/token.service';
import { emailService } from '../../services/email.service';
import { ApiError } from '../../utils/apiError';
import { generateToken, hashToken, getExpiryDate } from '../../utils/helpers';
import { logger } from '../../utils/logger';
import type {
  RegisterInput,
  LoginInput,
  ForgotPasswordInput,
  ResetPasswordInput,
  VerifyChurchCodeInput,
  CompleteSetupInput,
  RefreshTokenInput,
} from './auth.validation';

const SALT_ROUNDS = 12;

// ── Sanitize user object for API responses ──────────
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

export const authService = {
  // ────────────────────────────────────────────────────
  // REGISTER
  // ────────────────────────────────────────────────────
  async register(input: RegisterInput) {
    const { name, email, password } = input;

    // Check if email already exists
    const existingUser = await prisma.user.findUnique({ where: { email } });
    if (existingUser) {
      throw ApiError.conflict('An account with this email already exists');
    }

    // Hash password
    const passwordHash = await bcrypt.hash(password, SALT_ROUNDS);

    // Generate email verification token
    const rawToken = generateToken();
    const verificationToken = hashToken(rawToken);
    const verificationExpires = getExpiryDate('24h');

    // Create user
    const user = await prisma.user.create({
      data: {
        name,
        email: email.toLowerCase(),
        passwordHash,
        verificationToken,
        verificationExpires,
      },
    });

    // Send verification email (async, don't block response)
    emailService.sendVerificationEmail(email, name, rawToken).catch((err) => {
      logger.error('Failed to send verification email:', err);
    });

    logger.info(`New user registered: ${email}`);

    return {
      user: sanitizeUser(user),
      message: 'Account created. Please check your email to verify your account.',
    };
  },

  // ────────────────────────────────────────────────────
  // LOGIN
  // ────────────────────────────────────────────────────
  async login(input: LoginInput) {
    const { email, password } = input;

    // Find user
    const user = await prisma.user.findUnique({
      where: { email: email.toLowerCase() },
      include: { church: { select: { id: true, name: true, code: true } } },
    });

    if (!user) {
      throw ApiError.unauthorized('Invalid email or password');
    }

    if (!user.isActive) {
      throw ApiError.unauthorized('Account is deactivated. Contact your church admin.');
    }

    // Verify password
    const isPasswordValid = await bcrypt.compare(password, user.passwordHash);
    if (!isPasswordValid) {
      throw ApiError.unauthorized('Invalid email or password');
    }

    // Check if email is verified
    if (!user.emailVerified) {
      throw ApiError.forbidden('Please verify your email before logging in. Check your inbox.');
    }

    // Generate token pair
    const tokenPayload = {
      sub: user.id,
      email: user.email,
      role: user.role,
      churchId: user.churchId,
    };
    const tokens = tokenService.generateTokenPair(tokenPayload);

    // Store refresh token hash in DB
    await prisma.user.update({
      where: { id: user.id },
      data: { refreshToken: hashToken(tokens.refreshToken) },
    });

    logger.info(`User logged in: ${email}`);

    return {
      user: sanitizeUser(user),
      ...tokens,
    };
  },

  // ────────────────────────────────────────────────────
  // VERIFY EMAIL
  // ────────────────────────────────────────────────────
  async verifyEmail(token: string) {
    const hashedToken = hashToken(token);

    const user = await prisma.user.findFirst({
      where: {
        verificationToken: hashedToken,
        verificationExpires: { gt: new Date() },
      },
    });

    if (!user) {
      throw ApiError.badRequest('Invalid or expired verification token');
    }

    await prisma.user.update({
      where: { id: user.id },
      data: {
        emailVerified: true,
        verificationToken: null,
        verificationExpires: null,
      },
    });

    logger.info(`Email verified: ${user.email}`);
    return { message: 'Email verified successfully. You can now log in.' };
  },

  // ────────────────────────────────────────────────────
  // RESEND VERIFICATION EMAIL
  // ────────────────────────────────────────────────────
  async resendVerification(email: string) {
    const user = await prisma.user.findUnique({
      where: { email: email.toLowerCase() },
    });

    if (!user) {
      // Don't reveal if email exists — return success regardless
      return { message: 'If an account exists with that email, a verification link has been sent.' };
    }

    if (user.emailVerified) {
      throw ApiError.badRequest('Email is already verified');
    }

    // Generate new verification token
    const rawToken = generateToken();
    const verificationToken = hashToken(rawToken);
    const verificationExpires = getExpiryDate('24h');

    await prisma.user.update({
      where: { id: user.id },
      data: { verificationToken, verificationExpires },
    });

    await emailService.sendVerificationEmail(user.email, user.name, rawToken);

    return { message: 'If an account exists with that email, a verification link has been sent.' };
  },

  // ────────────────────────────────────────────────────
  // FORGOT PASSWORD
  // ────────────────────────────────────────────────────
  async forgotPassword(input: ForgotPasswordInput) {
    const user = await prisma.user.findUnique({
      where: { email: input.email.toLowerCase() },
    });

    // Always return success (don't reveal if email exists)
    if (!user) {
      return { message: 'If an account exists with that email, a reset link has been sent.' };
    }

    // Generate reset token
    const rawToken = generateToken();
    const resetToken = hashToken(rawToken);
    const resetTokenExpires = getExpiryDate('1h');

    await prisma.user.update({
      where: { id: user.id },
      data: { resetToken, resetTokenExpires },
    });

    await emailService.sendPasswordResetEmail(user.email, user.name, rawToken);

    logger.info(`Password reset requested: ${user.email}`);
    return { message: 'If an account exists with that email, a reset link has been sent.' };
  },

  // ────────────────────────────────────────────────────
  // RESET PASSWORD
  // ────────────────────────────────────────────────────
  async resetPassword(input: ResetPasswordInput) {
    const hashedToken = hashToken(input.token);

    const user = await prisma.user.findFirst({
      where: {
        resetToken: hashedToken,
        resetTokenExpires: { gt: new Date() },
      },
    });

    if (!user) {
      throw ApiError.badRequest('Invalid or expired reset token');
    }

    const passwordHash = await bcrypt.hash(input.password, SALT_ROUNDS);

    await prisma.user.update({
      where: { id: user.id },
      data: {
        passwordHash,
        resetToken: null,
        resetTokenExpires: null,
        refreshToken: null, // Invalidate all sessions
      },
    });

    logger.info(`Password reset completed: ${user.email}`);
    return { message: 'Password reset successfully. You can now log in with your new password.' };
  },

  // ────────────────────────────────────────────────────
  // VERIFY CHURCH CODE
  // ────────────────────────────────────────────────────
  async verifyChurchCode(userId: string, input: VerifyChurchCodeInput) {
    const church = await prisma.church.findUnique({
      where: { code: input.code.toUpperCase() },
      select: { id: true, name: true, code: true, logoUrl: true },
    });

    if (!church) {
      throw ApiError.badRequest('Invalid church code. Please check and try again.');
    }

    // Link user to church
    await prisma.user.update({
      where: { id: userId },
      data: { churchId: church.id },
    });

    logger.info(`User ${userId} joined church: ${church.name}`);
    return { church };
  },

  // ────────────────────────────────────────────────────
  // COMPLETE SETUP
  // ────────────────────────────────────────────────────
  async completeSetup(userId: string, input: CompleteSetupInput) {
    const user = await prisma.user.update({
      where: { id: userId },
      data: {
        ...(input.displayName && { name: input.displayName }),
        ...(input.bio && { bio: input.bio }),
        ...(input.department && { department: input.department }),
        hasCompletedSetup: true,
      },
      include: { church: { select: { id: true, name: true } } },
    });

    // Send welcome email if church is linked
    if (user.church) {
      emailService.sendWelcomeEmail(user.email, user.name, user.church.name).catch((err) => {
        logger.error('Failed to send welcome email:', err);
      });
    }

    logger.info(`Profile setup completed: ${user.email}`);
    return { user: sanitizeUser(user) };
  },

  // ────────────────────────────────────────────────────
  // REFRESH TOKEN
  // ────────────────────────────────────────────────────
  async refreshToken(input: RefreshTokenInput) {
    try {
      const decoded = tokenService.verifyRefreshToken(input.refreshToken);
      const hashedToken = hashToken(input.refreshToken);

      // Verify refresh token matches the stored one
      const user = await prisma.user.findFirst({
        where: {
          id: decoded.sub,
          refreshToken: hashedToken,
          isActive: true,
        },
      });

      if (!user) {
        throw ApiError.unauthorized('Invalid refresh token');
      }

      // Generate new token pair
      const tokenPayload = {
        sub: user.id,
        email: user.email,
        role: user.role,
        churchId: user.churchId,
      };
      const tokens = tokenService.generateTokenPair(tokenPayload);

      // Update stored refresh token
      await prisma.user.update({
        where: { id: user.id },
        data: { refreshToken: hashToken(tokens.refreshToken) },
      });

      return tokens;
    } catch (error) {
      if (error instanceof ApiError) throw error;
      throw ApiError.unauthorized('Invalid or expired refresh token');
    }
  },

  // ────────────────────────────────────────────────────
  // LOGOUT
  // ────────────────────────────────────────────────────
  async logout(userId: string, fcmToken?: string) {
    const updateData: any = { refreshToken: null };

    // Remove specific FCM token if provided
    if (fcmToken) {
      const user = await prisma.user.findUnique({
        where: { id: userId },
        select: { fcmTokens: true },
      });

      if (user) {
        updateData.fcmTokens = user.fcmTokens.filter((t) => t !== fcmToken);
      }
    }

    await prisma.user.update({
      where: { id: userId },
      data: updateData,
    });

    logger.info(`User logged out: ${userId}`);
    return { message: 'Logged out successfully' };
  },

  // ────────────────────────────────────────────────────
  // DELETE ACCOUNT
  // ────────────────────────────────────────────────────
  async deleteAccount(userId: string) {
    // Cascade delete all user data (GDPR-compliant)
    await prisma.user.delete({ where: { id: userId } });

    logger.info(`Account deleted: ${userId}`);
    return { message: 'Account and all associated data have been deleted.' };
  },
};
