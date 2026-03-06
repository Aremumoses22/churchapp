import { z } from 'zod';

// ── Register ────────────────────────────────────────
export const registerSchema = z.object({
  name: z.string().min(2, 'Name must be at least 2 characters').max(255),
  email: z.string().email('Invalid email address').max(255),
  password: z
    .string()
    .min(8, 'Password must be at least 8 characters')
    .max(128)
    .regex(
      /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/,
      'Password must contain at least one uppercase letter, one lowercase letter, and one number',
    ),
});

// ── Login ───────────────────────────────────────────
export const loginSchema = z.object({
  email: z.string().email('Invalid email address'),
  password: z.string().min(1, 'Password is required'),
});

// ── Forgot Password ─────────────────────────────────
export const forgotPasswordSchema = z.object({
  email: z.string().email('Invalid email address'),
});

// ── Reset Password ──────────────────────────────────
export const resetPasswordSchema = z.object({
  token: z.string().min(1, 'Token is required'),
  password: z
    .string()
    .min(8, 'Password must be at least 8 characters')
    .max(128)
    .regex(
      /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/,
      'Password must contain at least one uppercase letter, one lowercase letter, and one number',
    ),
});

// ── Verify Church Code ──────────────────────────────
export const verifyChurchCodeSchema = z.object({
  code: z
    .string()
    .min(4, 'Church code must be at least 4 characters')
    .max(10, 'Church code must be at most 10 characters'),
});

// ── Complete Setup ──────────────────────────────────
export const completeSetupSchema = z.object({
  displayName: z.string().min(2).max(255).optional(),
  bio: z.string().max(1000).optional(),
  department: z.string().max(100).optional(),
});

// ── Refresh Token ───────────────────────────────────
export const refreshTokenSchema = z.object({
  refreshToken: z.string().min(1, 'Refresh token is required'),
});

// ── Types (inferred from schemas) ───────────────────
export type RegisterInput = z.infer<typeof registerSchema>;
export type LoginInput = z.infer<typeof loginSchema>;
export type ForgotPasswordInput = z.infer<typeof forgotPasswordSchema>;
export type ResetPasswordInput = z.infer<typeof resetPasswordSchema>;
export type VerifyChurchCodeInput = z.infer<typeof verifyChurchCodeSchema>;
export type CompleteSetupInput = z.infer<typeof completeSetupSchema>;
export type RefreshTokenInput = z.infer<typeof refreshTokenSchema>;
