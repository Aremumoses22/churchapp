import env from '../config/env';
import { logger } from '../utils/logger';
import crypto from 'crypto';

// ────────────────────────────────────────────────────
// Paystack Payment Service
// Handles transaction initialization, verification,
// charge authorization (recurring), and webhook verification
// ────────────────────────────────────────────────────

const PAYSTACK_BASE_URL = 'https://api.paystack.co';

interface PaystackInitResponse {
  status: boolean;
  message: string;
  data: {
    authorization_url: string;
    access_code: string;
    reference: string;
  };
}

interface PaystackVerifyResponse {
  status: boolean;
  message: string;
  data: {
    id: number;
    domain: string;
    status: string; // "success", "failed", "abandoned"
    reference: string;
    amount: number; // in kobo (smallest unit)
    currency: string;
    channel: string; // "card", "bank", "ussd", "mobile_money"
    gateway_response: string;
    paid_at: string;
    authorization: {
      authorization_code: string;
      bin: string;
      last4: string;
      exp_month: string;
      exp_year: string;
      channel: string;
      card_type: string;
      bank: string;
      brand: string;
      reusable: boolean;
      country_code: string;
    };
    customer: {
      id: number;
      email: string;
      customer_code: string;
    };
    metadata: Record<string, any>;
  };
}

interface PaystackChargeResponse {
  status: boolean;
  message: string;
  data: {
    reference: string;
    status: string;
    amount: number;
    currency: string;
  };
}

/**
 * Check if we should use dev mode stubs
 * (no key, or obviously placeholder key like sk_test_xxxxx)
 */
function isDevStub(): boolean {
  const key = env.paystackSecretKey;
  return env.isDev && (!key || /^sk_test_x+$/i.test(key));
}

function getHeaders(): Record<string, string> {
  return {
    Authorization: `Bearer ${env.paystackSecretKey}`,
    'Content-Type': 'application/json',
  };
}

/**
 * Initialize a Paystack transaction
 * Returns an authorization URL to redirect the user to
 */
async function initializeTransaction(params: {
  email: string;
  amount: number; // in smallest unit (kobo for NGN)
  reference: string;
  callbackUrl?: string;
  metadata?: Record<string, any>;
}): Promise<PaystackInitResponse['data'] | null> {
  // In dev mode without real Paystack key, simulate
  if (isDevStub()) {
    logger.info('💳 Paystack (dev mode): Initialize transaction', {
      reference: params.reference,
      amount: params.amount,
    });
    return {
      authorization_url: `https://checkout.paystack.com/test/${params.reference}`,
      access_code: `test_access_${params.reference}`,
      reference: params.reference,
    };
  }

  try {
    const response = await fetch(`${PAYSTACK_BASE_URL}/transaction/initialize`, {
      method: 'POST',
      headers: getHeaders(),
      body: JSON.stringify({
        email: params.email,
        amount: params.amount,
        reference: params.reference,
        callback_url: params.callbackUrl,
        metadata: params.metadata,
      }),
    });

    const data = (await response.json()) as PaystackInitResponse;

    if (!data.status) {
      logger.error('Paystack init failed:', data.message);
      return null;
    }

    return data.data;
  } catch (error) {
    logger.error('Paystack initialize error:', error);
    return null;
  }
}

/**
 * Verify a Paystack transaction by reference
 */
async function verifyTransaction(
  reference: string,
): Promise<PaystackVerifyResponse['data'] | null> {
  // In dev mode without real Paystack key, simulate success
  if (isDevStub()) {
    logger.info('💳 Paystack (dev mode): Verify transaction', { reference });
    return {
      id: Date.now(),
      domain: 'test',
      status: 'success',
      reference,
      amount: 0,
      currency: 'NGN',
      channel: 'card',
      gateway_response: 'Successful',
      paid_at: new Date().toISOString(),
      authorization: {
        authorization_code: `AUTH_test_${reference}`,
        bin: '408408',
        last4: '4081',
        exp_month: '12',
        exp_year: '2030',
        channel: 'card',
        card_type: 'visa',
        bank: 'Test Bank',
        brand: 'Visa',
        reusable: true,
        country_code: 'NG',
      },
      customer: {
        id: 1,
        email: 'test@example.com',
        customer_code: 'CUS_test',
      },
      metadata: {},
    };
  }

  try {
    const response = await fetch(
      `${PAYSTACK_BASE_URL}/transaction/verify/${encodeURIComponent(reference)}`,
      { method: 'GET', headers: getHeaders() },
    );

    const data = (await response.json()) as PaystackVerifyResponse;

    if (!data.status) {
      logger.error('Paystack verify failed:', data.message);
      return null;
    }

    return data.data;
  } catch (error) {
    logger.error('Paystack verify error:', error);
    return null;
  }
}

/**
 * Charge a previously authorized card (for recurring payments)
 */
async function chargeAuthorization(params: {
  authorizationCode: string;
  email: string;
  amount: number;
  reference: string;
  metadata?: Record<string, any>;
}): Promise<PaystackChargeResponse['data'] | null> {
  // In dev mode, simulate
  if (isDevStub()) {
    logger.info('💳 Paystack (dev mode): Charge authorization', {
      reference: params.reference,
      amount: params.amount,
    });
    return {
      reference: params.reference,
      status: 'success',
      amount: params.amount,
      currency: 'NGN',
    };
  }

  try {
    const response = await fetch(`${PAYSTACK_BASE_URL}/transaction/charge_authorization`, {
      method: 'POST',
      headers: getHeaders(),
      body: JSON.stringify({
        authorization_code: params.authorizationCode,
        email: params.email,
        amount: params.amount,
        reference: params.reference,
        metadata: params.metadata,
      }),
    });

    const data = (await response.json()) as PaystackChargeResponse;

    if (!data.status) {
      logger.error('Paystack charge failed:', data.message);
      return null;
    }

    return data.data;
  } catch (error) {
    logger.error('Paystack charge error:', error);
    return null;
  }
}

/**
 * Verify a Paystack webhook signature
 */
function verifyWebhookSignature(body: string, signature: string): boolean {
  if (isDevStub()) return true; // Skip signature check in dev mode

  if (!env.paystackSecretKey) return false;

  const hash = crypto
    .createHmac('sha512', env.paystackSecretKey)
    .update(body)
    .digest('hex');

  return hash === signature;
}

/**
 * Create a refund
 */
async function createRefund(transactionRef: string, amount?: number): Promise<boolean> {
  if (isDevStub()) {
    logger.info('💳 Paystack (dev mode): Refund', { transactionRef, amount });
    return true;
  }

  try {
    const body: Record<string, any> = { transaction: transactionRef };
    if (amount) body.amount = amount;

    const response = await fetch(`${PAYSTACK_BASE_URL}/refund`, {
      method: 'POST',
      headers: getHeaders(),
      body: JSON.stringify(body),
    });

    const data = (await response.json()) as { status: boolean; message: string };
    return data.status;
  } catch (error) {
    logger.error('Paystack refund error:', error);
    return false;
  }
}

export const paystackService = {
  initializeTransaction,
  verifyTransaction,
  chargeAuthorization,
  verifyWebhookSignature,
  createRefund,
};
