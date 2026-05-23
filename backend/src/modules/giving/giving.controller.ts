import { Response, NextFunction } from 'express';
import { AuthRequest } from '../../middleware/auth';
import { givingService } from './giving.service';
import { ApiResponse } from '../../utils/apiResponse';
import { ApiError } from '../../utils/apiError';
import { resolveChurchId } from '../../utils/churchHelper';

// Helper to safely extract param (Express 5 params can be string | string[])
const param = (req: AuthRequest, name: string): string => req.params[name] as string;

// ────────────────────────────────────────────────────
// Giving Controller
// ────────────────────────────────────────────────────

// ── Categories ──────────────────────────────────────

export async function getCategories(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    const churchId = await resolveChurchId(req);
    if (!churchId) throw ApiError.badRequest('No church associated');
    const categories = await givingService.getCategories(churchId);
    ApiResponse.success(res, categories);
  } catch (error) {
    next(error);
  }
}

// ── Donations ───────────────────────────────────────

export async function donate(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    const churchId = await resolveChurchId(req);
    if (!churchId) throw ApiError.badRequest('No church associated');

    const result = await givingService.donate({
      userId: req.user!.id,
      churchId,
      email: req.user!.email,
      ...req.body,
    });

    ApiResponse.created(res, result, 'Donation initiated');
  } catch (error) {
    next(error);
  }
}

export async function verifyTransaction(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    const { reference, provider } = req.body;
    const result = await givingService.verifyAndComplete(reference, provider);

    if (result.alreadyProcessed) {
      ApiResponse.success(res, result.donation, 'Transaction already processed');
    } else {
      ApiResponse.success(res, result.donation, 'Transaction verified');
    }
  } catch (error) {
    next(error);
  }
}

export async function getDonationHistory(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    const churchId = await resolveChurchId(req);
    if (!churchId) throw ApiError.badRequest('No church associated');

    const { page, limit, status, startDate, endDate, categoryId, campaignId } = req.query as any;

    const result = await givingService.getDonationHistory({
      userId: req.user!.id,
      churchId,
      page: Number(page),
      limit: Number(limit),
      status,
      startDate,
      endDate,
      categoryId,
      campaignId,
    });

    ApiResponse.paginated(res, result.data, result.total, Number(page), Number(limit));
  } catch (error) {
    next(error);
  }
}

export async function getReceipt(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    const receipt = await givingService.getReceipt(req.user!.id, param(req, 'id'));
    ApiResponse.success(res, receipt);
  } catch (error) {
    next(error);
  }
}

export async function downloadReceipt(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    const pdfBuffer = await givingService.downloadReceipt(req.user!.id, param(req, 'id'));
    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', `attachment; filename="receipt-${param(req, 'id')}.pdf"`);
    res.send(pdfBuffer);
  } catch (error) {
    next(error);
  }
}

export async function getGivingSummary(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    const churchId = await resolveChurchId(req);
    if (!churchId) throw ApiError.badRequest('No church associated');
    const summary = await givingService.getGivingSummary(req.user!.id, churchId);
    ApiResponse.success(res, summary);
  } catch (error) {
    next(error);
  }
}

// ── Payment Methods ─────────────────────────────────

export async function getPaymentMethods(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    const methods = await givingService.getPaymentMethods(req.user!.id);
    ApiResponse.success(res, methods);
  } catch (error) {
    next(error);
  }
}

export async function addPaymentMethod(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    const method = await givingService.addPaymentMethod({
      userId: req.user!.id,
      ...req.body,
    });
    ApiResponse.created(res, method, 'Payment method added');
  } catch (error) {
    next(error);
  }
}

export async function removePaymentMethod(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    const result = await givingService.removePaymentMethod(req.user!.id, param(req, 'id'));
    ApiResponse.success(res, result, 'Payment method removed');
  } catch (error) {
    next(error);
  }
}

// ── Campaigns ───────────────────────────────────────

export async function getCampaigns(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    const churchId = await resolveChurchId(req);
    if (!churchId) throw ApiError.badRequest('No church associated');
    const { page, limit, active } = req.query as any;
    const result = await givingService.getCampaigns(
      churchId,
      Number(page),
      Number(limit),
      active,
    );
    ApiResponse.paginated(res, result.data, result.total, Number(page), Number(limit));
  } catch (error) {
    next(error);
  }
}

export async function getCampaignById(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    const churchId = await resolveChurchId(req);
    if (!churchId) throw ApiError.badRequest('No church associated');
    const campaign = await givingService.getCampaignById(churchId, param(req, 'id'));
    ApiResponse.success(res, campaign);
  } catch (error) {
    next(error);
  }
}

export async function donateToCampaign(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    const churchId = await resolveChurchId(req);
    if (!churchId) throw ApiError.badRequest('No church associated');

    const result = await givingService.donate({
      userId: req.user!.id,
      churchId,
      email: req.user!.email,
      campaignId: param(req, 'id'),
      ...req.body,
    });

    ApiResponse.created(res, result, 'Campaign donation initiated');
  } catch (error) {
    next(error);
  }
}

// ── Pledges ─────────────────────────────────────────

export async function getPledges(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    const churchId = await resolveChurchId(req);
    if (!churchId) throw ApiError.badRequest('No church associated');
    const { page, limit, status } = req.query as any;
    const result = await givingService.getPledges(
      req.user!.id,
      churchId,
      Number(page),
      Number(limit),
      status,
    );
    ApiResponse.paginated(res, result.data, result.total, Number(page), Number(limit));
  } catch (error) {
    next(error);
  }
}

export async function createPledge(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    const churchId = await resolveChurchId(req);
    if (!churchId) throw ApiError.badRequest('No church associated');
    const pledge = await givingService.createPledge({
      userId: req.user!.id,
      churchId,
      ...req.body,
    });
    ApiResponse.created(res, pledge, 'Pledge created');
  } catch (error) {
    next(error);
  }
}

export async function makePledgePayment(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    const result = await givingService.makePledgePayment(
      req.user!.id,
      param(req, 'id'),
      req.body.amount,
    );
    ApiResponse.success(res, result, 'Pledge payment recorded');
  } catch (error) {
    next(error);
  }
}

export async function cancelPledge(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    const result = await givingService.cancelPledge(req.user!.id, param(req, 'id'));
    ApiResponse.success(res, result, 'Pledge cancelled');
  } catch (error) {
    next(error);
  }
}

// ── Recurring Donations ─────────────────────────────

export async function getRecurringDonations(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    const churchId = await resolveChurchId(req);
    if (!churchId) throw ApiError.badRequest('No church associated');
    const recurring = await givingService.getRecurringDonations(req.user!.id, churchId);
    ApiResponse.success(res, recurring);
  } catch (error) {
    next(error);
  }
}

export async function createRecurring(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    const churchId = await resolveChurchId(req);
    if (!churchId) throw ApiError.badRequest('No church associated');
    const recurring = await givingService.createRecurring({
      userId: req.user!.id,
      churchId,
      ...req.body,
    });
    ApiResponse.created(res, recurring, 'Recurring donation created');
  } catch (error) {
    next(error);
  }
}

export async function updateRecurring(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    const recurring = await givingService.updateRecurring(
      req.user!.id,
      param(req, 'id'),
      req.body,
    );
    ApiResponse.success(res, recurring, 'Recurring donation updated');
  } catch (error) {
    next(error);
  }
}

export async function cancelRecurring(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    const result = await givingService.cancelRecurring(req.user!.id, param(req, 'id'));
    ApiResponse.success(res, result, 'Recurring donation cancelled');
  } catch (error) {
    next(error);
  }
}

// ── Webhooks ────────────────────────────────────────

export async function paystackWebhook(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    const signature = req.headers['x-paystack-signature'] as string;
    const rawBody = JSON.stringify(req.body);

    // Verify signature (service handles dev mode stubs internally)
    const { paystackService } = await import('../../services/paystack.service');
    const isValid = paystackService.verifyWebhookSignature(rawBody, signature || '');

    if (!isValid) {
      return res.status(401).json({ error: 'Invalid signature' });
    }

    await givingService.processPaystackWebhook(req.body);

    // Paystack expects 200 response quickly
    res.status(200).json({ received: true });
  } catch (error) {
    // Still return 200 to Paystack to prevent retries
    res.status(200).json({ received: true, error: 'Processing error' });
  }
}

export async function stripeWebhook(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    const signature = req.headers['stripe-signature'] as string;
    const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET || '';

    let event = req.body;

    // Verify signature in production
    if (process.env.STRIPE_SECRET_KEY && webhookSecret) {
      const { stripeService } = await import('../../services/stripe.service');
      event = stripeService.verifyWebhookSignature(
        JSON.stringify(req.body),
        signature || '',
        webhookSecret,
      );

      if (!event) {
        return res.status(401).json({ error: 'Invalid signature' });
      }
    }

    await givingService.processStripeWebhook(event);

    res.status(200).json({ received: true });
  } catch (error) {
    res.status(200).json({ received: true, error: 'Processing error' });
  }
}
