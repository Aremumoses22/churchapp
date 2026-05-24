import { Response, NextFunction } from 'express';
import { adminVolunteerService } from './volunteer.service';
import { ApiResponse } from '../../../utils/apiResponse';
import { AuthRequest } from '../../../middleware/auth';

function cid(req: AuthRequest): string | null | undefined {
  if (req.user?.role === 'SUPER_ADMIN') {
    const qId = typeof req.query.churchId === 'string' ? req.query.churchId : undefined;
    return qId || req.user.churchId;
  }
  return req.user?.churchId ?? null;
}

export const volunteerController = {
  async listOpportunities(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { page = '1', limit = '20', search, department } = req.query as Record<string, string>;
      const result = await adminVolunteerService.listOpportunities(cid(req), { page: +page, limit: +limit, search, department });
      ApiResponse.paginated(res, result.opportunities, { page: result.page, limit: result.limit, total: result.total, totalPages: result.totalPages });
    } catch (e) { next(e); }
  },

  async createOpportunity(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.created(res, await adminVolunteerService.createOpportunity(cid(req), req.body)); } catch (e) { next(e); }
  },

  async updateOpportunity(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.success(res, await adminVolunteerService.updateOpportunity(cid(req), req.params['id'] as string, req.body), 'Opportunity updated'); } catch (e) { next(e); }
  },

  async deleteOpportunity(req: AuthRequest, res: Response, next: NextFunction) {
    try { await adminVolunteerService.deleteOpportunity(cid(req), req.params['id'] as string); ApiResponse.success(res, null, 'Opportunity deleted'); } catch (e) { next(e); }
  },

  async toggleActive(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.success(res, await adminVolunteerService.toggleOpportunityActive(cid(req), req.params['id'] as string)); } catch (e) { next(e); }
  },

  async listSignups(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.success(res, await adminVolunteerService.listSignups(cid(req), req.params['id'] as string)); } catch (e) { next(e); }
  },

  async updateSignupStatus(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.success(res, await adminVolunteerService.updateSignupStatus(req.params['signupId'] as string, req.body.status)); } catch (e) { next(e); }
  },
};
