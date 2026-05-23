import { Response, NextFunction } from 'express';
import { adminGivingService } from './giving.service';
import { ApiResponse } from '../../../utils/apiResponse';
import { AuthRequest } from '../../../middleware/auth';

function cid(req: AuthRequest): string | null | undefined {
  if (req.user?.role === 'SUPER_ADMIN') {
    const qId = typeof req.query.churchId === 'string' ? req.query.churchId : undefined;
    return qId || req.user.churchId;
  }
  return req.user?.churchId ?? null;
}

function pid(req: AuthRequest): string { return req.params['id'] as string; }

export const givingController = {
  async listDonations(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { page = '1', limit = '20', search, status, categoryId, campaignId } = req.query as Record<string, string>;
      const result = await adminGivingService.listDonations(cid(req), { page: +page, limit: +limit, search, status, categoryId, campaignId });
      ApiResponse.paginated(res, result.donations, { page: result.page, limit: result.limit, total: result.total, totalPages: result.totalPages });
    } catch (e) { next(e); }
  },

  async getDonationSummary(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.success(res, await adminGivingService.getDonationSummary(cid(req))); } catch (e) { next(e); }
  },

  // Categories
  async listCategories(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.success(res, await adminGivingService.listCategories(cid(req))); } catch (e) { next(e); }
  },

  async createCategory(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.created(res, await adminGivingService.createCategory(cid(req), req.body)); } catch (e) { next(e); }
  },

  async updateCategory(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.success(res, await adminGivingService.updateCategory(cid(req), pid(req), req.body)); } catch (e) { next(e); }
  },

  async deleteCategory(req: AuthRequest, res: Response, next: NextFunction) {
    try { await adminGivingService.deleteCategory(cid(req), pid(req)); ApiResponse.success(res, null, 'Category deleted'); } catch (e) { next(e); }
  },

  // Campaigns
  async listCampaigns(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.success(res, await adminGivingService.listCampaigns(cid(req))); } catch (e) { next(e); }
  },

  async createCampaign(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.created(res, await adminGivingService.createCampaign(cid(req), req.body)); } catch (e) { next(e); }
  },

  async updateCampaign(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.success(res, await adminGivingService.updateCampaign(cid(req), pid(req), req.body)); } catch (e) { next(e); }
  },

  async deleteCampaign(req: AuthRequest, res: Response, next: NextFunction) {
    try { await adminGivingService.deleteCampaign(cid(req), pid(req)); ApiResponse.success(res, null, 'Campaign deleted'); } catch (e) { next(e); }
  },
};
