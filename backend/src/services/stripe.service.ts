import env from '../config/env';
import { logger } from '../utils/logger';

// ────────────────────────────────────────────────────
// Stripe Payment Service
// Handles payment intents, customer management,
// payment methods, and webhook verification
// ────────────────────────────────────────────────────

// Lazy-load Stripe SDK to avoid requiring it when not configured
let stripeInstance: any = null;

/**
 * Check if we should use dev mode stubs
 * (no key, or obviously placeholder key like sk_test_xxxxx)
 */
function isDevStub(): boolean {
  const key = env.stripeSecretKey;
  return env.isDev && (!key || /^sk_test_x+$/i.test(key));
}

async function getStripe() {
  if (stripeInstance) return stripeInstance;

  if (!env.stripeSecretKey || isDevStub()) {
    logger.warn('Stripe not configured — using dev mode stubs');
    return null;
  }

  try {
    const Stripe = (await import('stripe')).default;
    stripeInstance = new Stripe(env.stripeSecretKey, {
      apiVersion: '2025-05-28.basil' as any,
    });
    return stripeInstance;
  } catch (error) {
    logger.error('Failed to initialize Stripe:', error);
    return null;
  }
}

interface CreatePaymentIntentParams {
  amount: number; // in smallest unit (cents for USD)
  currency: string;
  customerEmail: string;
  metadata?: Record<string, string>;
  paymentMethodId?: string;
}

interface StripePaymentResult {
  id: string;
  clientSecret: string;
  status: string;
  amount: number;
  currency: string;
}

/**
 * Create a Stripe Payment Intent
 */
async function createPaymentIntent(
  params: CreatePaymentIntentParams,
): Promise<StripePaymentResult | null> {
  // Dev mode stub
  if (isDevStub()) {
    logger.info('💳 Stripe (dev mode): Create payment intent', {
      amount: params.amount,
      currency: params.currency,
    });
    const fakeId = `pi_test_${Date.now()}`;
    return {
      id: fakeId,
      clientSecret: `${fakeId}_secret_test`,
      status: 'requires_payment_method',
      amount: params.amount,
      currency: params.currency,
    };
  }

  const stripe = await getStripe();
  if (!stripe) return null;

  try {
    const intent = await stripe.paymentIntents.create({
      amount: params.amount,
      currency: params.currency,
      receipt_email: params.customerEmail,
      metadata: params.metadata || {},
      ...(params.paymentMethodId && {
        payment_method: params.paymentMethodId,
        confirm: true,
      }),
    });

    return {
      id: intent.id,
      clientSecret: intent.client_secret!,
      status: intent.status,
      amount: intent.amount,
      currency: intent.currency,
    };
  } catch (error) {
    logger.error('Stripe createPaymentIntent error:', error);
    return null;
  }
}

/**
 * Confirm a Stripe Payment Intent
 */
async function confirmPaymentIntent(paymentIntentId: string): Promise<StripePaymentResult | null> {
  if (isDevStub()) {
    logger.info('💳 Stripe (dev mode): Confirm payment intent', { paymentIntentId });
    return {
      id: paymentIntentId,
      clientSecret: `${paymentIntentId}_secret_test`,
      status: 'succeeded',
      amount: 0,
      currency: 'usd',
    };
  }

  const stripe = await getStripe();
  if (!stripe) return null;

  try {
    const intent = await stripe.paymentIntents.confirm(paymentIntentId);
    return {
      id: intent.id,
      clientSecret: intent.client_secret!,
      status: intent.status,
      amount: intent.amount,
      currency: intent.currency,
    };
  } catch (error) {
    logger.error('Stripe confirmPaymentIntent error:', error);
    return null;
  }
}

/**
 * Create or retrieve a Stripe customer
 */
async function getOrCreateCustomer(email: string, name: string): Promise<string | null> {
  if (isDevStub()) {
    return `cus_test_${Date.now()}`;
  }

  const stripe = await getStripe();
  if (!stripe) return null;

  try {
    // Check for existing customer
    const existing = await stripe.customers.list({ email, limit: 1 });
    if (existing.data.length > 0) {
      return existing.data[0].id;
    }

    // Create new
    const customer = await stripe.customers.create({ email, name });
    return customer.id;
  } catch (error) {
    logger.error('Stripe getOrCreateCustomer error:', error);
    return null;
  }
}

/**
 * Verify Stripe webhook signature
 */
function verifyWebhookSignature(
  body: string | Buffer,
  signature: string,
  webhookSecret: string,
): any {
  if (isDevStub()) {
    logger.info('💳 Stripe (dev mode): Verify webhook signature');
    try {
      return JSON.parse(body.toString());
    } catch {
      return null;
    }
  }

  // Stripe webhook verification requires the Stripe SDK
  // In production, use stripe.webhooks.constructEvent(body, signature, webhookSecret)
  try {
    if (stripeInstance) {
      return stripeInstance.webhooks.constructEvent(body, signature, webhookSecret);
    }
    return null;
  } catch (error) {
    logger.error('Stripe webhook verification failed:', error);
    return null;
  }
}

/**
 * Create a refund
 */
async function createRefund(paymentIntentId: string, amount?: number): Promise<boolean> {
  if (isDevStub()) {
    logger.info('💳 Stripe (dev mode): Refund', { paymentIntentId, amount });
    return true;
  }

  const stripe = await getStripe();
  if (!stripe) return false;

  try {
    const params: Record<string, any> = { payment_intent: paymentIntentId };
    if (amount) params.amount = amount;

    await stripe.refunds.create(params);
    return true;
  } catch (error) {
    logger.error('Stripe refund error:', error);
    return false;
  }
}

export const stripeService = {
  createPaymentIntent,
  confirmPaymentIntent,
  getOrCreateCustomer,
  verifyWebhookSignature,
  createRefund,
};
