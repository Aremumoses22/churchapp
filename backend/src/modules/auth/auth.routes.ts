import { Router } from 'express';
import { authController } from './auth.controller';
import { authenticate } from '../../middleware/auth';
import { validate } from '../../middleware/validate';
import { authLimiter } from '../../middleware/rateLimiter';
import {
  registerSchema,
  loginSchema,
  forgotPasswordSchema,
  resetPasswordSchema,
  verifyChurchCodeSchema,
  completeSetupSchema,
  refreshTokenSchema,
} from './auth.validation';

const router = Router();

// ── Public routes (rate-limited) ────────────────────

router.post(
  '/register',
  authLimiter,
  validate(registerSchema),
  authController.register,
);

router.post(
  '/login',
  authLimiter,
  validate(loginSchema),
  authController.login,
);

router.get(
  '/verify-email/:token',
  authController.verifyEmail,
);

router.post(
  '/resend-verification',
  authLimiter,
  validate(forgotPasswordSchema), // Same shape (just email)
  authController.resendVerification,
);

router.post(
  '/forgot-password',
  authLimiter,
  validate(forgotPasswordSchema),
  authController.forgotPassword,
);

router.post(
  '/reset-password',
  authLimiter,
  validate(resetPasswordSchema),
  authController.resetPassword,
);

router.post(
  '/refresh-token',
  validate(refreshTokenSchema),
  authController.refreshToken,
);

// ── Protected routes (require JWT) ──────────────────

router.post(
  '/verify-church-code',
  authenticate,
  validate(verifyChurchCodeSchema),
  authController.verifyChurchCode,
);

router.post(
  '/complete-setup',
  authenticate,
  validate(completeSetupSchema),
  authController.completeSetup,
);

router.post(
  '/logout',
  authenticate,
  authController.logout,
);

router.delete(
  '/account',
  authenticate,
  authController.deleteAccount,
);

export default router;
