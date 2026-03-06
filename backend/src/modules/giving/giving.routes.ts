import { Router } from 'express';
import { authenticate } from '../../middleware/auth';
import { validate } from '../../middleware/validate';
import {
  donateSchema,
  campaignDonateSchema,
  donationHistorySchema,
  addPaymentMethodSchema,
  idParamSchema,
  createPledgeSchema,
  pledgePaymentSchema,
  listPledgesSchema,
  createRecurringSchema,
  updateRecurringSchema,
  verifyTransactionSchema,
  listCampaignsSchema,
} from './giving.validation';
import * as ctrl from './giving.controller';

// ────────────────────────────────────────────────────
// Giving Routes — /api/v1/giving
// ────────────────────────────────────────────────────

const router = Router();

// ── Categories ──────────────────────────────────────
router.get('/categories', authenticate, ctrl.getCategories);

// ── Summary / Stats ─────────────────────────────────
router.get('/summary', authenticate, ctrl.getGivingSummary);

// ── Donations ───────────────────────────────────────
router.post('/donate', authenticate, validate(donateSchema), ctrl.donate);
router.post('/verify', authenticate, validate(verifyTransactionSchema), ctrl.verifyTransaction);
router.get('/history', authenticate, validate(donationHistorySchema, 'query'), ctrl.getDonationHistory);

// ── Receipts ────────────────────────────────────────
router.get('/receipts/:id', authenticate, validate(idParamSchema, 'params'), ctrl.getReceipt);
router.get('/receipts/:id/download', authenticate, validate(idParamSchema, 'params'), ctrl.downloadReceipt);

// ── Payment Methods ─────────────────────────────────
router.get('/payment-methods', authenticate, ctrl.getPaymentMethods);
router.post('/payment-methods', authenticate, validate(addPaymentMethodSchema), ctrl.addPaymentMethod);
router.delete('/payment-methods/:id', authenticate, validate(idParamSchema, 'params'), ctrl.removePaymentMethod);

// ── Campaigns ───────────────────────────────────────
router.get('/campaigns', authenticate, validate(listCampaignsSchema, 'query'), ctrl.getCampaigns);
router.get('/campaigns/:id', authenticate, validate(idParamSchema, 'params'), ctrl.getCampaignById);
router.post('/campaigns/:id/donate', authenticate, validate(campaignDonateSchema), ctrl.donateToCampaign);

// ── Pledges ─────────────────────────────────────────
router.get('/pledges', authenticate, validate(listPledgesSchema, 'query'), ctrl.getPledges);
router.post('/pledges', authenticate, validate(createPledgeSchema), ctrl.createPledge);
router.post('/pledges/:id/pay', authenticate, validate(pledgePaymentSchema), ctrl.makePledgePayment);
router.delete('/pledges/:id', authenticate, validate(idParamSchema, 'params'), ctrl.cancelPledge);

// ── Recurring Donations ─────────────────────────────
router.get('/recurring', authenticate, ctrl.getRecurringDonations);
router.post('/recurring', authenticate, validate(createRecurringSchema), ctrl.createRecurring);
router.put('/recurring/:id', authenticate, validate(updateRecurringSchema), ctrl.updateRecurring);
router.delete('/recurring/:id', authenticate, validate(idParamSchema, 'params'), ctrl.cancelRecurring);

// ── Webhooks (public — signature verified internally) ──
router.post('/webhooks/paystack', ctrl.paystackWebhook);
router.post('/webhooks/stripe', ctrl.stripeWebhook);

export default router;
