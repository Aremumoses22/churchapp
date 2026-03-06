import { z } from 'zod';

// ────────────────────────────────────────────────────
// Giving Validation Schemas
// ────────────────────────────────────────────────────

// ── Common ──────────────────────────────────────────
export const idParamSchema = z.object({
  id: z.string().uuid(),
});

// ── Donate ──────────────────────────────────────────
export const donateSchema = z.object({
  amount: z.number().positive('Amount must be positive'),
  currency: z.string().min(3).max(10).default('NGN'),
  categoryId: z.string().uuid().optional(),
  campaignId: z.string().uuid().optional(),
  paymentMethod: z.enum(['CARD', 'BANK', 'MOBILE', 'WALLET']),
  paymentProvider: z.enum(['PAYSTACK', 'STRIPE', 'MANUAL']).default('PAYSTACK'),
  isAnonymous: z.boolean().default(false),
  note: z.string().max(500).optional(),
  // For Paystack — optional, server generates if not provided
  callbackUrl: z.string().url().optional(),
});

// ── Campaign Donate ─────────────────────────────────
export const campaignDonateSchema = z.object({
  amount: z.number().positive('Amount must be positive'),
  currency: z.string().min(3).max(10).default('NGN'),
  paymentMethod: z.enum(['CARD', 'BANK', 'MOBILE', 'WALLET']),
  paymentProvider: z.enum(['PAYSTACK', 'STRIPE', 'MANUAL']).default('PAYSTACK'),
  isAnonymous: z.boolean().default(false),
  note: z.string().max(500).optional(),
  callbackUrl: z.string().url().optional(),
});

// ── Donation History ────────────────────────────────
export const donationHistorySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  status: z.enum(['PENDING', 'SUCCESS', 'FAILED', 'REFUNDED']).optional(),
  startDate: z.string().optional(),
  endDate: z.string().optional(),
  categoryId: z.string().uuid().optional(),
  campaignId: z.string().uuid().optional(),
});

// ── Payment Method ──────────────────────────────────
export const addPaymentMethodSchema = z.object({
  type: z.enum(['CARD', 'BANK']),
  provider: z.enum(['PAYSTACK', 'STRIPE']),
  last4: z.string().length(4),
  brand: z.string().max(20).optional(),
  expiryMonth: z.number().int().min(1).max(12).optional(),
  expiryYear: z.number().int().min(2024).optional(),
  bankName: z.string().max(100).optional(),
  isDefault: z.boolean().default(false),
  providerToken: z.string().min(1),
});

// ── Pledges ─────────────────────────────────────────
export const createPledgeSchema = z.object({
  campaignId: z.string().uuid().optional(),
  title: z.string().min(1).max(255),
  totalAmount: z.number().positive('Total amount must be positive'),
  frequency: z.enum(['ONE_TIME', 'WEEKLY', 'BIWEEKLY', 'MONTHLY', 'QUARTERLY', 'ANNUALLY']),
  startDate: z.string().refine(
    (val) => !isNaN(Date.parse(val)),
    'Invalid start date',
  ),
  endDate: z.string().optional().refine(
    (val) => !val || !isNaN(Date.parse(val)),
    'Invalid end date',
  ),
  totalPayments: z.number().int().positive().optional(),
});

export const pledgePaymentSchema = z.object({
  amount: z.number().positive('Amount must be positive'),
});

export const listPledgesSchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  status: z.enum(['ACTIVE', 'COMPLETED', 'CANCELLED']).optional(),
});

// ── Recurring Donations ─────────────────────────────
export const createRecurringSchema = z.object({
  categoryId: z.string().uuid(),
  paymentMethodId: z.string().uuid(),
  amount: z.number().positive('Amount must be positive'),
  currency: z.string().min(3).max(10).default('NGN'),
  frequency: z.enum(['WEEKLY', 'BIWEEKLY', 'MONTHLY', 'QUARTERLY', 'ANNUALLY']),
});

export const updateRecurringSchema = z.object({
  amount: z.number().positive().optional(),
  frequency: z.enum(['WEEKLY', 'BIWEEKLY', 'MONTHLY', 'QUARTERLY', 'ANNUALLY']).optional(),
  status: z.enum(['ACTIVE', 'PAUSED']).optional(),
  paymentMethodId: z.string().uuid().optional(),
});

// ── Verify Transaction ──────────────────────────────
export const verifyTransactionSchema = z.object({
  reference: z.string().min(1),
  provider: z.enum(['PAYSTACK', 'STRIPE']).default('PAYSTACK'),
});

// ── Campaign List ───────────────────────────────────
export const listCampaignsSchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  active: z.string().optional().default('true').transform((v) => v === 'true'),
});
