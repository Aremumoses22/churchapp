import prisma from '../../config/database';
import { ApiError } from '../../utils/apiError';
import { paystackService } from '../../services/paystack.service';
import { stripeService } from '../../services/stripe.service';
import { receiptService } from '../../services/receipt.service';
import { emailService } from '../../services/email.service';
import { logger } from '../../utils/logger';
import { v4 as uuidv4 } from 'uuid';
import type {
  DonationStatus,
  PaymentMethod,
  PaymentProvider,
  GivingFrequency,
  RecurringStatus,
} from '../../generated/prisma/client';
import {
  notifyDonationSuccess,
  notifyDonationFailed,
  notifyPledgeCreated,
  notifyPledgePayment,
  notifyRecurringSetup,
  notifyRecurringCancelled,
} from '../../services/notification.triggers';

// ────────────────────────────────────────────────────
// Giving Service
// Handles donations, categories, campaigns, pledges,
// recurring giving, payment methods, receipts
// ────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────
// CATEGORIES
// ─────────────────────────────────────────────────────

async function getCategories(churchId: string) {
  return prisma.givingCategory.findMany({
    where: { churchId, isActive: true },
    orderBy: { sortOrder: 'asc' },
    select: {
      id: true,
      name: true,
      description: true,
      sortOrder: true,
    },
  });
}

// ─────────────────────────────────────────────────────
// DONATIONS
// ─────────────────────────────────────────────────────

function generateReceiptNumber(): string {
  const date = new Date();
  const y = date.getFullYear();
  const m = String(date.getMonth() + 1).padStart(2, '0');
  const d = String(date.getDate()).padStart(2, '0');
  const rand = Math.random().toString(36).substring(2, 8).toUpperCase();
  return `RCP-${y}${m}${d}-${rand}`;
}

function generateTransactionRef(provider: string): string {
  const prefix = provider === 'PAYSTACK' ? 'PSK' : provider === 'STRIPE' ? 'STR' : 'MAN';
  return `${prefix}-${Date.now()}-${uuidv4().substring(0, 8)}`;
}

interface DonateParams {
  userId: string;
  churchId: string;
  amount: number;
  currency: string;
  categoryId?: string;
  campaignId?: string;
  paymentMethod: PaymentMethod;
  paymentProvider: PaymentProvider;
  isAnonymous: boolean;
  note?: string;
  callbackUrl?: string;
  email: string;
}

/**
 * Process a one-time donation
 * 1. Creates a PENDING donation record
 * 2. Initializes payment with provider
 * 3. Returns authorization URL (for Paystack) or client secret (for Stripe)
 */
async function donate(params: DonateParams) {
  const {
    userId, churchId, amount, currency, categoryId, campaignId,
    paymentMethod, paymentProvider, isAnonymous, note, callbackUrl, email,
  } = params;

  // Validate category exists if provided
  if (categoryId) {
    const category = await prisma.givingCategory.findFirst({
      where: { id: categoryId, churchId, isActive: true },
    });
    if (!category) throw ApiError.notFound('Giving category not found');
  }

  // Validate campaign exists if provided
  if (campaignId) {
    const campaign = await prisma.givingCampaign.findFirst({
      where: { id: campaignId, churchId, isActive: true },
    });
    if (!campaign) throw ApiError.notFound('Campaign not found');
  }

  const transactionRef = generateTransactionRef(paymentProvider);

  // Create pending donation
  const donation = await prisma.donation.create({
    data: {
      userId,
      churchId,
      categoryId: categoryId || null,
      campaignId: campaignId || null,
      amount,
      currency,
      paymentMethod,
      paymentProvider,
      transactionRef,
      status: 'PENDING',
      isAnonymous,
      note: note || null,
    },
    include: {
      category: { select: { name: true } },
      campaign: { select: { title: true } },
    },
  });

  // Initialize payment with provider
  let paymentData: any = null;

  if (paymentProvider === 'PAYSTACK') {
    // Paystack amounts are in kobo (smallest unit)
    const amountInKobo = Math.round(amount * 100);
    paymentData = await paystackService.initializeTransaction({
      email,
      amount: amountInKobo,
      reference: transactionRef,
      callbackUrl,
      metadata: {
        donationId: donation.id,
        userId,
        churchId,
        category: donation.category?.name || 'General',
      },
    });
  } else if (paymentProvider === 'STRIPE') {
    // Stripe amounts are in cents (smallest unit)
    const amountInCents = Math.round(amount * 100);
    paymentData = await stripeService.createPaymentIntent({
      amount: amountInCents,
      currency: currency.toLowerCase(),
      customerEmail: email,
      metadata: {
        donationId: donation.id,
        userId,
        churchId,
      },
    });
  } else if (paymentProvider === 'MANUAL') {
    // Manual/cash donations are auto-confirmed
    await completeDonation(transactionRef, 'SUCCESS');
    paymentData = { status: 'completed' };
  }

  return {
    donation: {
      id: donation.id,
      amount: donation.amount,
      currency: donation.currency,
      transactionRef: donation.transactionRef,
      status: donation.status,
      category: donation.category?.name || null,
      campaign: donation.campaign?.title || null,
    },
    payment: paymentData,
  };
}

/**
 * Verify and complete a transaction (called after payment callback)
 */
async function verifyAndComplete(reference: string, provider: string) {
  const donation = await prisma.donation.findUnique({
    where: { transactionRef: reference },
    include: {
      user: { select: { id: true, name: true, email: true } },
      church: { select: { name: true, address: true, ein: true } },
      category: { select: { name: true } },
      campaign: { select: { id: true, title: true } },
    },
  });

  if (!donation) throw ApiError.notFound('Donation not found');
  if (donation.status === 'SUCCESS') {
    return { donation, alreadyProcessed: true };
  }

  let verifiedStatus: DonationStatus = 'FAILED';
  let providerRef: string | null = null;
  let authCode: string | null = null;

  if (provider === 'PAYSTACK') {
    const result = await paystackService.verifyTransaction(reference);
    if (result && result.status === 'success') {
      verifiedStatus = 'SUCCESS';
      providerRef = String(result.id);
      authCode = result.authorization?.authorization_code || null;
    }
  } else if (provider === 'STRIPE') {
    const result = await stripeService.confirmPaymentIntent(reference);
    if (result && result.status === 'succeeded') {
      verifiedStatus = 'SUCCESS';
      providerRef = result.id;
    }
  }

  // Update donation
  const updated = await completeDonation(reference, verifiedStatus, providerRef);

  // If successful, save payment method for reuse (Paystack auth code)
  if (verifiedStatus === 'SUCCESS' && authCode && donation.user) {
    try {
      const existingMethod = await prisma.userPaymentMethod.findFirst({
        where: { userId: donation.userId, providerToken: authCode },
      });

      if (!existingMethod) {
        const paystackResult = await paystackService.verifyTransaction(reference);
        if (paystackResult?.authorization) {
          const auth = paystackResult.authorization;
          await prisma.userPaymentMethod.create({
            data: {
              userId: donation.userId,
              type: auth.channel === 'card' ? 'CARD' : 'BANK',
              provider: 'PAYSTACK',
              last4: auth.last4,
              brand: auth.brand || auth.card_type,
              expiryMonth: parseInt(auth.exp_month) || null,
              expiryYear: parseInt(auth.exp_year) || null,
              isDefault: false,
              providerToken: auth.authorization_code,
            },
          });
        }
      }
    } catch (err) {
      logger.warn('Failed to save payment method after donation:', err);
    }
  }

  return { donation: updated, alreadyProcessed: false };
}

/**
 * Complete a donation — set status, generate receipt, update campaign totals
 */
async function completeDonation(
  transactionRef: string,
  status: DonationStatus,
  providerRef?: string | null,
) {
  const receiptNumber = status === 'SUCCESS' ? generateReceiptNumber() : null;

  const donation = await prisma.donation.update({
    where: { transactionRef },
    data: {
      status,
      providerRef: providerRef || undefined,
      receiptNumber,
    },
    include: {
      user: { select: { id: true, name: true, email: true } },
      church: { select: { name: true, address: true, ein: true } },
      category: { select: { name: true } },
      campaign: { select: { id: true, title: true } },
    },
  });

  if (status === 'SUCCESS') {
    // Update campaign totals if campaign donation
    if (donation.campaignId) {
      await updateCampaignTotals(donation.campaignId);
    }

    // Generate receipt asynchronously (non-blocking)
    generateReceiptAsync(donation).catch((err) =>
      logger.error('Async receipt generation failed:', err),
    );

    // Send receipt email asynchronously
    if (donation.user) {
      sendDonationReceiptEmail(donation).catch((err) =>
        logger.error('Receipt email failed:', err),
      );
    }

    // Fire notification trigger (non-blocking)
    notifyDonationSuccess(
      donation.userId,
      donation.amount,
      donation.currency,
      donation.category?.name || undefined,
      donation.id,
    ).catch(() => {});
  } else if (status === 'FAILED') {
    notifyDonationFailed(donation.userId, donation.amount, donation.currency).catch(() => {});
  }

  return donation;
}

/**
 * Update campaign raised amount and donor count
 */
async function updateCampaignTotals(campaignId: string) {
  const totals = await prisma.donation.aggregate({
    where: { campaignId, status: 'SUCCESS' },
    _sum: { amount: true },
    _count: { _all: true },
  });

  // Count distinct donors
  const uniqueDonors = await prisma.donation.findMany({
    where: { campaignId, status: 'SUCCESS', isAnonymous: false },
    select: { userId: true },
    distinct: ['userId'],
  });

  await prisma.givingCampaign.update({
    where: { id: campaignId },
    data: {
      raisedAmount: totals._sum.amount || 0,
      donorCount: uniqueDonors.length,
    },
  });
}

/**
 * Generate a receipt PDF asynchronously
 */
async function generateReceiptAsync(donation: any) {
  if (!donation.receiptNumber) return;

  const paymentMethodLabel =
    donation.paymentMethod === 'CARD' ? 'Card' :
    donation.paymentMethod === 'BANK' ? 'Bank Transfer' :
    donation.paymentMethod === 'MOBILE' ? 'Mobile Money' : 'Wallet';

  const receiptUrl = await receiptService.generateAndUploadReceipt({
    receiptNumber: donation.receiptNumber,
    donorName: donation.user?.name || 'Anonymous',
    donorEmail: donation.user?.email || '',
    churchName: donation.church?.name || 'Church',
    churchAddress: donation.church?.address || undefined,
    churchEin: donation.church?.ein || undefined,
    amount: donation.amount,
    currency: donation.currency,
    category: donation.category?.name || undefined,
    campaign: donation.campaign?.title || undefined,
    paymentMethod: paymentMethodLabel,
    transactionRef: donation.transactionRef,
    date: donation.createdAt,
  });

  if (receiptUrl) {
    await prisma.donation.update({
      where: { id: donation.id },
      data: { receiptUrl },
    });
  }
}

/**
 * Send donation receipt email
 */
async function sendDonationReceiptEmail(donation: any) {
  if (!donation.user?.email) return;

  const formatted = receiptService.formatCurrency(donation.amount, donation.currency);

  await emailService.sendEmail({
    to: donation.user.email,
    subject: `Donation Receipt — ${formatted}`,
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h2>Thank you for your donation! 🙏</h2>
        <p>Hi ${donation.user.name},</p>
        <p>We received your donation of <strong>${formatted}</strong>.</p>
        <table style="width: 100%; border-collapse: collapse; margin: 16px 0;">
          <tr style="background: #f8f9fa;">
            <td style="padding: 8px; font-weight: bold;">Receipt #</td>
            <td style="padding: 8px;">${donation.receiptNumber}</td>
          </tr>
          <tr>
            <td style="padding: 8px; font-weight: bold;">Amount</td>
            <td style="padding: 8px;">${formatted}</td>
          </tr>
          <tr style="background: #f8f9fa;">
            <td style="padding: 8px; font-weight: bold;">Category</td>
            <td style="padding: 8px;">${donation.category?.name || 'General'}</td>
          </tr>
          ${donation.campaign ? `
          <tr>
            <td style="padding: 8px; font-weight: bold;">Campaign</td>
            <td style="padding: 8px;">${donation.campaign.title}</td>
          </tr>` : ''}
          <tr style="background: #f8f9fa;">
            <td style="padding: 8px; font-weight: bold;">Date</td>
            <td style="padding: 8px;">${new Date(donation.createdAt).toLocaleDateString()}</td>
          </tr>
          <tr>
            <td style="padding: 8px; font-weight: bold;">Reference</td>
            <td style="padding: 8px;">${donation.transactionRef}</td>
          </tr>
        </table>
        <p style="color: #666;">A PDF receipt has been generated for your records.</p>
        <p>God bless you!</p>
        <p style="color: #999; font-size: 12px;">— ${donation.church?.name || 'Church App'}</p>
      </div>
    `,
  });
}

// ─────────────────────────────────────────────────────
// DONATION HISTORY
// ─────────────────────────────────────────────────────

interface HistoryParams {
  userId: string;
  churchId: string;
  page: number;
  limit: number;
  status?: DonationStatus;
  startDate?: string;
  endDate?: string;
  categoryId?: string;
  campaignId?: string;
}

async function getDonationHistory(params: HistoryParams) {
  const { userId, churchId, page, limit, status, startDate, endDate, categoryId, campaignId } = params;

  const where: any = { userId, churchId };
  if (status) where.status = status;
  if (categoryId) where.categoryId = categoryId;
  if (campaignId) where.campaignId = campaignId;

  if (startDate || endDate) {
    where.createdAt = {};
    if (startDate) where.createdAt.gte = new Date(startDate);
    if (endDate) where.createdAt.lte = new Date(endDate + 'T23:59:59.999Z');
  }

  const [donations, total] = await Promise.all([
    prisma.donation.findMany({
      where,
      include: {
        category: { select: { name: true } },
        campaign: { select: { title: true } },
      },
      orderBy: { createdAt: 'desc' },
      skip: (page - 1) * limit,
      take: limit,
    }),
    prisma.donation.count({ where }),
  ]);

  return {
    data: donations.map((d) => ({
      id: d.id,
      amount: d.amount,
      currency: d.currency,
      status: d.status,
      paymentMethod: d.paymentMethod,
      category: d.category?.name || null,
      campaign: d.campaign?.title || null,
      receiptNumber: d.receiptNumber,
      transactionRef: d.transactionRef,
      isAnonymous: d.isAnonymous,
      note: d.note,
      createdAt: d.createdAt,
    })),
    total,
  };
}

// ─────────────────────────────────────────────────────
// RECEIPT DETAIL
// ─────────────────────────────────────────────────────

async function getReceipt(userId: string, donationId: string) {
  const donation = await prisma.donation.findFirst({
    where: { id: donationId, userId },
    include: {
      user: { select: { name: true, email: true } },
      church: { select: { name: true, address: true, ein: true } },
      category: { select: { name: true } },
      campaign: { select: { title: true } },
    },
  });

  if (!donation) throw ApiError.notFound('Donation not found');

  return {
    id: donation.id,
    receiptNumber: donation.receiptNumber,
    donorName: donation.user.name,
    donorEmail: donation.user.email,
    churchName: donation.church.name,
    churchAddress: donation.church.address,
    churchEin: donation.church.ein,
    amount: donation.amount,
    currency: donation.currency,
    category: donation.category?.name || null,
    campaign: donation.campaign?.title || null,
    paymentMethod: donation.paymentMethod,
    transactionRef: donation.transactionRef,
    providerRef: donation.providerRef,
    status: donation.status,
    receiptUrl: donation.receiptUrl,
    isAnonymous: donation.isAnonymous,
    note: donation.note,
    createdAt: donation.createdAt,
  };
}

/**
 * Download/generate receipt PDF on demand
 */
async function downloadReceipt(userId: string, donationId: string) {
  const donation = await prisma.donation.findFirst({
    where: { id: donationId, userId, status: 'SUCCESS' },
    include: {
      user: { select: { name: true, email: true } },
      church: { select: { name: true, address: true, ein: true } },
      category: { select: { name: true } },
      campaign: { select: { title: true } },
    },
  });

  if (!donation) throw ApiError.notFound('Donation not found');
  if (!donation.receiptNumber) throw ApiError.badRequest('Receipt not available for this donation');

  const paymentMethodLabel =
    donation.paymentMethod === 'CARD' ? 'Card' :
    donation.paymentMethod === 'BANK' ? 'Bank Transfer' :
    donation.paymentMethod === 'MOBILE' ? 'Mobile Money' : 'Wallet';

  const pdfBuffer = await receiptService.generateReceiptPdf({
    receiptNumber: donation.receiptNumber,
    donorName: donation.user.name,
    donorEmail: donation.user.email,
    churchName: donation.church.name,
    churchAddress: donation.church.address || undefined,
    churchEin: donation.church.ein || undefined,
    amount: donation.amount,
    currency: donation.currency,
    category: donation.category?.name || undefined,
    campaign: donation.campaign?.title || undefined,
    paymentMethod: paymentMethodLabel,
    transactionRef: donation.transactionRef,
    date: donation.createdAt,
  });

  return pdfBuffer;
}

// ─────────────────────────────────────────────────────
// GIVING SUMMARY / STATS
// ─────────────────────────────────────────────────────

async function getGivingSummary(userId: string, churchId: string) {
  const now = new Date();
  const startOfYear = new Date(now.getFullYear(), 0, 1);
  const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);

  const [yearTotal, monthTotal, totalAllTime, recentDonations] = await Promise.all([
    prisma.donation.aggregate({
      where: { userId, churchId, status: 'SUCCESS', createdAt: { gte: startOfYear } },
      _sum: { amount: true },
      _count: { _all: true },
    }),
    prisma.donation.aggregate({
      where: { userId, churchId, status: 'SUCCESS', createdAt: { gte: startOfMonth } },
      _sum: { amount: true },
    }),
    prisma.donation.aggregate({
      where: { userId, churchId, status: 'SUCCESS' },
      _sum: { amount: true },
      _count: { _all: true },
    }),
    prisma.donation.findMany({
      where: { userId, churchId, status: 'SUCCESS' },
      include: { category: { select: { name: true } } },
      orderBy: { createdAt: 'desc' },
      take: 5,
    }),
  ]);

  return {
    yearToDate: yearTotal._sum.amount || 0,
    yearDonationCount: yearTotal._count._all,
    monthToDate: monthTotal._sum.amount || 0,
    allTime: totalAllTime._sum.amount || 0,
    totalDonations: totalAllTime._count._all,
    recentDonations: recentDonations.map((d) => ({
      id: d.id,
      amount: d.amount,
      currency: d.currency,
      category: d.category?.name || null,
      createdAt: d.createdAt,
    })),
  };
}

// ─────────────────────────────────────────────────────
// PAYMENT METHODS
// ─────────────────────────────────────────────────────

async function getPaymentMethods(userId: string) {
  return prisma.userPaymentMethod.findMany({
    where: { userId },
    orderBy: [{ isDefault: 'desc' }, { createdAt: 'desc' }],
    select: {
      id: true,
      type: true,
      provider: true,
      last4: true,
      brand: true,
      expiryMonth: true,
      expiryYear: true,
      bankName: true,
      isDefault: true,
      createdAt: true,
    },
  });
}

interface AddPaymentMethodParams {
  userId: string;
  type: PaymentMethod;
  provider: PaymentProvider;
  last4: string;
  brand?: string;
  expiryMonth?: number;
  expiryYear?: number;
  bankName?: string;
  isDefault: boolean;
  providerToken: string;
}

async function addPaymentMethod(params: AddPaymentMethodParams) {
  // If setting as default, un-default others
  if (params.isDefault) {
    await prisma.userPaymentMethod.updateMany({
      where: { userId: params.userId, isDefault: true },
      data: { isDefault: false },
    });
  }

  return prisma.userPaymentMethod.create({
    data: params,
    select: {
      id: true,
      type: true,
      provider: true,
      last4: true,
      brand: true,
      expiryMonth: true,
      expiryYear: true,
      bankName: true,
      isDefault: true,
      createdAt: true,
    },
  });
}

async function removePaymentMethod(userId: string, methodId: string) {
  const method = await prisma.userPaymentMethod.findFirst({
    where: { id: methodId, userId },
  });

  if (!method) throw ApiError.notFound('Payment method not found');

  // Check if used by active recurring donations
  const activeRecurring = await prisma.recurringDonation.count({
    where: { paymentMethodId: methodId, status: 'ACTIVE' },
  });

  if (activeRecurring > 0) {
    throw ApiError.badRequest(
      'Cannot remove payment method while it is used by active recurring donations',
    );
  }

  await prisma.userPaymentMethod.delete({ where: { id: methodId } });
  return { deleted: true };
}

// ─────────────────────────────────────────────────────
// CAMPAIGNS
// ─────────────────────────────────────────────────────

async function getCampaigns(churchId: string, page: number, limit: number, activeOnly: boolean) {
  const where: any = { churchId };
  if (activeOnly) where.isActive = true;

  const [campaigns, total] = await Promise.all([
    prisma.givingCampaign.findMany({
      where,
      orderBy: { startDate: 'desc' },
      skip: (page - 1) * limit,
      take: limit,
      select: {
        id: true,
        title: true,
        description: true,
        imageUrl: true,
        goalAmount: true,
        raisedAmount: true,
        donorCount: true,
        startDate: true,
        endDate: true,
        isActive: true,
      },
    }),
    prisma.givingCampaign.count({ where }),
  ]);

  return {
    data: campaigns.map((c) => ({
      ...c,
      percentage: c.goalAmount > 0 ? Math.min(100, Math.round((c.raisedAmount / c.goalAmount) * 100)) : 0,
      daysRemaining: c.endDate
        ? Math.max(0, Math.ceil((new Date(c.endDate).getTime() - Date.now()) / (1000 * 60 * 60 * 24)))
        : null,
    })),
    total,
  };
}

async function getCampaignById(churchId: string, campaignId: string) {
  const campaign = await prisma.givingCampaign.findFirst({
    where: { id: campaignId, churchId },
  });

  if (!campaign) throw ApiError.notFound('Campaign not found');

  // Get recent donors (non-anonymous)
  const recentDonors = await prisma.donation.findMany({
    where: { campaignId, status: 'SUCCESS', isAnonymous: false },
    include: { user: { select: { name: true, avatarUrl: true } } },
    orderBy: { createdAt: 'desc' },
    take: 10,
  });

  return {
    ...campaign,
    percentage: campaign.goalAmount > 0
      ? Math.min(100, Math.round((campaign.raisedAmount / campaign.goalAmount) * 100))
      : 0,
    daysRemaining: campaign.endDate
      ? Math.max(0, Math.ceil((new Date(campaign.endDate).getTime() - Date.now()) / (1000 * 60 * 60 * 24)))
      : null,
    recentDonors: recentDonors.map((d) => ({
      name: d.user.name,
      avatarUrl: d.user.avatarUrl,
      amount: d.amount,
      currency: d.currency,
      donatedAt: d.createdAt,
    })),
  };
}

// ─────────────────────────────────────────────────────
// PLEDGES
// ─────────────────────────────────────────────────────

interface CreatePledgeParams {
  userId: string;
  churchId: string;
  campaignId?: string;
  title: string;
  totalAmount: number;
  frequency: GivingFrequency;
  startDate: string;
  endDate?: string;
  totalPayments?: number;
}

function calculateNextDueDate(startDate: Date, frequency: GivingFrequency): Date {
  const next = new Date(startDate);
  switch (frequency) {
    case 'ONE_TIME':
      return next;
    case 'WEEKLY':
      next.setDate(next.getDate() + 7);
      return next;
    case 'BIWEEKLY':
      next.setDate(next.getDate() + 14);
      return next;
    case 'MONTHLY':
      next.setMonth(next.getMonth() + 1);
      return next;
    case 'QUARTERLY':
      next.setMonth(next.getMonth() + 3);
      return next;
    case 'ANNUALLY':
      next.setFullYear(next.getFullYear() + 1);
      return next;
    default:
      next.setMonth(next.getMonth() + 1);
      return next;
  }
}

async function createPledge(params: CreatePledgeParams) {
  if (params.campaignId) {
    const campaign = await prisma.givingCampaign.findFirst({
      where: { id: params.campaignId, churchId: params.churchId, isActive: true },
    });
    if (!campaign) throw ApiError.notFound('Campaign not found');
  }

  const startDate = new Date(params.startDate);
  const nextDueDate = calculateNextDueDate(startDate, params.frequency);

  const pledge = await prisma.pledge.create({
    data: {
      userId: params.userId,
      churchId: params.churchId,
      campaignId: params.campaignId || null,
      title: params.title,
      totalAmount: params.totalAmount,
      frequency: params.frequency,
      startDate,
      endDate: params.endDate ? new Date(params.endDate) : null,
      nextDueDate,
      totalPayments: params.totalPayments || null,
    },
    include: {
      campaign: { select: { title: true } },
    },
  });

  // Fire notification trigger (non-blocking)
  notifyPledgeCreated(params.userId, params.title, params.totalAmount, pledge.id).catch(() => {});

  return pledge;
}

async function getPledges(
  userId: string,
  churchId: string,
  page: number,
  limit: number,
  status?: string,
) {
  const where: any = { userId, churchId };
  if (status) where.status = status;

  const [pledges, total] = await Promise.all([
    prisma.pledge.findMany({
      where,
      include: {
        campaign: { select: { title: true } },
        payments: {
          orderBy: { paidAt: 'desc' },
          take: 5,
          select: {
            id: true,
            amount: true,
            paidAt: true,
            status: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
      skip: (page - 1) * limit,
      take: limit,
    }),
    prisma.pledge.count({ where }),
  ]);

  return {
    data: pledges.map((p) => ({
      id: p.id,
      title: p.title,
      campaign: p.campaign?.title || null,
      totalAmount: p.totalAmount,
      paidAmount: p.paidAmount,
      remainingAmount: p.totalAmount - p.paidAmount,
      frequency: p.frequency,
      status: p.status,
      startDate: p.startDate,
      endDate: p.endDate,
      nextDueDate: p.nextDueDate,
      paymentsCompleted: p.paymentsCompleted,
      totalPayments: p.totalPayments,
      recentPayments: p.payments,
      progressPercentage:
        p.totalAmount > 0 ? Math.round((p.paidAmount / p.totalAmount) * 100) : 0,
    })),
    total,
  };
}

async function makePledgePayment(userId: string, pledgeId: string, amount: number) {
  const pledge = await prisma.pledge.findFirst({
    where: { id: pledgeId, userId, status: 'ACTIVE' },
  });

  if (!pledge) throw ApiError.notFound('Active pledge not found');

  const newPaidAmount = pledge.paidAmount + amount;
  const newPaymentsCompleted = pledge.paymentsCompleted + 1;
  const isCompleted =
    newPaidAmount >= pledge.totalAmount ||
    (pledge.totalPayments && newPaymentsCompleted >= pledge.totalPayments);

  const newNextDueDate = isCompleted
    ? null
    : calculateNextDueDate(new Date(), pledge.frequency);

  const [payment] = await prisma.$transaction([
    prisma.pledgePayment.create({
      data: {
        pledgeId,
        amount,
        status: 'SUCCESS',
      },
    }),
    prisma.pledge.update({
      where: { id: pledgeId },
      data: {
        paidAmount: newPaidAmount,
        paymentsCompleted: newPaymentsCompleted,
        nextDueDate: newNextDueDate,
        status: isCompleted ? 'COMPLETED' : 'ACTIVE',
      },
    }),
  ]);

  // Fire notification trigger (non-blocking)
  notifyPledgePayment(
    userId,
    pledge.title,
    amount,
    pledge.totalAmount - newPaidAmount,
  ).catch(() => {});

  return {
    payment,
    pledge: {
      id: pledge.id,
      paidAmount: newPaidAmount,
      remainingAmount: pledge.totalAmount - newPaidAmount,
      paymentsCompleted: newPaymentsCompleted,
      status: isCompleted ? 'COMPLETED' : 'ACTIVE',
      nextDueDate: newNextDueDate,
    },
  };
}

async function cancelPledge(userId: string, pledgeId: string) {
  const pledge = await prisma.pledge.findFirst({
    where: { id: pledgeId, userId, status: 'ACTIVE' },
  });

  if (!pledge) throw ApiError.notFound('Active pledge not found');

  await prisma.pledge.update({
    where: { id: pledgeId },
    data: { status: 'CANCELLED', nextDueDate: null },
  });

  return { cancelled: true };
}

// ─────────────────────────────────────────────────────
// RECURRING DONATIONS
// ─────────────────────────────────────────────────────

interface CreateRecurringParams {
  userId: string;
  churchId: string;
  categoryId: string;
  paymentMethodId: string;
  amount: number;
  currency: string;
  frequency: GivingFrequency;
}

async function getRecurringDonations(userId: string, churchId: string) {
  return prisma.recurringDonation.findMany({
    where: { userId, churchId },
    include: {
      category: { select: { name: true } },
      paymentMethod: {
        select: { type: true, brand: true, last4: true },
      },
    },
    orderBy: { createdAt: 'desc' },
  });
}

async function createRecurring(params: CreateRecurringParams) {
  // Validate category
  const category = await prisma.givingCategory.findFirst({
    where: { id: params.categoryId, churchId: params.churchId, isActive: true },
  });
  if (!category) throw ApiError.notFound('Giving category not found');

  // Validate payment method
  const pm = await prisma.userPaymentMethod.findFirst({
    where: { id: params.paymentMethodId, userId: params.userId },
  });
  if (!pm) throw ApiError.notFound('Payment method not found');

  const nextChargeDate = calculateNextDueDate(new Date(), params.frequency);

  const recurring = await prisma.recurringDonation.create({
    data: {
      userId: params.userId,
      churchId: params.churchId,
      categoryId: params.categoryId,
      paymentMethodId: params.paymentMethodId,
      amount: params.amount,
      currency: params.currency,
      frequency: params.frequency,
      nextChargeDate,
    },
    include: {
      category: { select: { name: true } },
      paymentMethod: { select: { type: true, brand: true, last4: true } },
    },
  });

  // Fire notification trigger (non-blocking)
  notifyRecurringSetup(params.userId, params.amount, params.currency, params.frequency).catch(() => {});

  return recurring;
}

async function updateRecurring(
  userId: string,
  recurringId: string,
  updates: {
    amount?: number;
    frequency?: GivingFrequency;
    status?: RecurringStatus;
    paymentMethodId?: string;
  },
) {
  const recurring = await prisma.recurringDonation.findFirst({
    where: { id: recurringId, userId },
  });

  if (!recurring) throw ApiError.notFound('Recurring donation not found');

  // Validate payment method if changing
  if (updates.paymentMethodId) {
    const pm = await prisma.userPaymentMethod.findFirst({
      where: { id: updates.paymentMethodId, userId },
    });
    if (!pm) throw ApiError.notFound('Payment method not found');
  }

  const data: any = {};
  if (updates.amount !== undefined) data.amount = updates.amount;
  if (updates.frequency !== undefined) {
    data.frequency = updates.frequency;
    data.nextChargeDate = calculateNextDueDate(new Date(), updates.frequency);
  }
  if (updates.status !== undefined) data.status = updates.status;
  if (updates.paymentMethodId !== undefined) data.paymentMethodId = updates.paymentMethodId;

  return prisma.recurringDonation.update({
    where: { id: recurringId },
    data,
    include: {
      category: { select: { name: true } },
      paymentMethod: { select: { type: true, brand: true, last4: true } },
    },
  });
}

async function cancelRecurring(userId: string, recurringId: string) {
  const recurring = await prisma.recurringDonation.findFirst({
    where: { id: recurringId, userId },
  });

  if (!recurring) throw ApiError.notFound('Recurring donation not found');

  await prisma.recurringDonation.update({
    where: { id: recurringId },
    data: { status: 'CANCELLED' },
  });

  // Fire notification trigger (non-blocking)
  notifyRecurringCancelled(userId, recurring.amount, recurring.currency).catch(() => {});

  return { cancelled: true };
}

// ─────────────────────────────────────────────────────
// WEBHOOK PROCESSING
// ─────────────────────────────────────────────────────

/**
 * Process Paystack webhook event
 */
async function processPaystackWebhook(event: any) {
  const { event: eventType, data } = event;

  logger.info(`Paystack webhook: ${eventType}`, { reference: data?.reference });

  switch (eventType) {
    case 'charge.success': {
      const reference = data.reference;
      if (!reference) break;

      // Check if donation exists
      const donation = await prisma.donation.findUnique({
        where: { transactionRef: reference },
      });

      if (donation && donation.status === 'PENDING') {
        await completeDonation(reference, 'SUCCESS', String(data.id));
        logger.info(`Webhook: Donation ${donation.id} completed via Paystack`);
      }
      break;
    }
    case 'charge.failed': {
      const reference = data.reference;
      if (!reference) break;

      const donation = await prisma.donation.findUnique({
        where: { transactionRef: reference },
      });

      if (donation && donation.status === 'PENDING') {
        await completeDonation(reference, 'FAILED');
        logger.info(`Webhook: Donation ${donation.id} failed via Paystack`);
      }
      break;
    }
    case 'refund.processed': {
      const reference = data.transaction_reference;
      if (!reference) break;

      const donation = await prisma.donation.findUnique({
        where: { transactionRef: reference },
      });

      if (donation && donation.status === 'SUCCESS') {
        await prisma.donation.update({
          where: { id: donation.id },
          data: { status: 'REFUNDED' },
        });
        logger.info(`Webhook: Donation ${donation.id} refunded via Paystack`);
      }
      break;
    }
    default:
      logger.info(`Unhandled Paystack webhook: ${eventType}`);
  }
}

/**
 * Process Stripe webhook event
 */
async function processStripeWebhook(event: any) {
  const { type: eventType, data } = event;

  logger.info(`Stripe webhook: ${eventType}`);

  switch (eventType) {
    case 'payment_intent.succeeded': {
      const pi = data.object;
      const donationId = pi.metadata?.donationId;
      if (!donationId) break;

      const donation = await prisma.donation.findUnique({
        where: { id: donationId },
      });

      if (donation && donation.status === 'PENDING') {
        await completeDonation(donation.transactionRef, 'SUCCESS', pi.id);
        logger.info(`Webhook: Donation ${donation.id} completed via Stripe`);
      }
      break;
    }
    case 'payment_intent.payment_failed': {
      const pi = data.object;
      const donationId = pi.metadata?.donationId;
      if (!donationId) break;

      const donation = await prisma.donation.findUnique({
        where: { id: donationId },
      });

      if (donation && donation.status === 'PENDING') {
        await completeDonation(donation.transactionRef, 'FAILED');
        logger.info(`Webhook: Donation ${donation.id} failed via Stripe`);
      }
      break;
    }
    default:
      logger.info(`Unhandled Stripe webhook: ${eventType}`);
  }
}

export const givingService = {
  // Categories
  getCategories,

  // Donations
  donate,
  verifyAndComplete,
  getDonationHistory,
  getReceipt,
  downloadReceipt,
  getGivingSummary,

  // Payment Methods
  getPaymentMethods,
  addPaymentMethod,
  removePaymentMethod,

  // Campaigns
  getCampaigns,
  getCampaignById,

  // Pledges
  createPledge,
  getPledges,
  makePledgePayment,
  cancelPledge,

  // Recurring
  getRecurringDonations,
  createRecurring,
  updateRecurring,
  cancelRecurring,

  // Webhooks
  processPaystackWebhook,
  processStripeWebhook,
};
