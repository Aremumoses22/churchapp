import { Response, NextFunction } from 'express';
import { analyticsService } from './analytics.service';
import { ApiResponse } from '../../../utils/apiResponse';
import { AuthRequest } from '../../../middleware/auth';

function resolveChurchId(req: AuthRequest): string | null | undefined {
  if (req.user?.role === 'SUPER_ADMIN') {
    const qId = typeof req.query.churchId === 'string' ? req.query.churchId : undefined;
    return qId || req.user.churchId;
  }
  return req.user?.churchId ?? null;
}

export const analyticsController = {
  async overview(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const data = await analyticsService.overview(resolveChurchId(req));
      ApiResponse.success(res, data);
    } catch (e) { next(e); }
  },

  async givingTrend(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const data = await analyticsService.givingTrend(resolveChurchId(req));
      ApiResponse.success(res, data);
    } catch (e) { next(e); }
  },

  async attendanceTrend(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const data = await analyticsService.attendanceTrend(resolveChurchId(req));
      ApiResponse.success(res, data);
    } catch (e) { next(e); }
  },

  async membershipGrowth(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const data = await analyticsService.membershipGrowth(resolveChurchId(req));
      ApiResponse.success(res, data);
    } catch (e) { next(e); }
  },

  async engagement(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const data = await analyticsService.engagement(resolveChurchId(req));
      ApiResponse.success(res, data);
    } catch (e) { next(e); }
  },
};
