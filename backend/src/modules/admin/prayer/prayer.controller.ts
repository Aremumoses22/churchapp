import { Response, NextFunction } from 'express';
import { adminPrayerService } from './prayer.service';
import { ApiResponse } from '../../../utils/apiResponse';
import { AuthRequest } from '../../../middleware/auth';
import { PrayerRequestStatus } from '../../../generated/prisma/client';

function cid(req: AuthRequest): string | null | undefined {
  if (req.user?.role === 'SUPER_ADMIN') {
    const qId = typeof req.query.churchId === 'string' ? req.query.churchId : undefined;
    return qId || req.user.churchId;
  }
  return req.user?.churchId ?? null;
}

function pid(req: AuthRequest): string { return req.params['id'] as string; }

export const prayerController = {
  async list(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { page = '1', limit = '20', search, status, urgent } = req.query as Record<string, string>;
      const result = await adminPrayerService.list(cid(req), { page: +page, limit: +limit, search, status, isUrgent: urgent === 'true' });
      ApiResponse.paginated(res, result.requests, { page: result.page, limit: result.limit, total: result.total, totalPages: result.totalPages });
    } catch (e) { next(e); }
  },

  async updateStatus(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { status } = req.body as { status: PrayerRequestStatus };
      ApiResponse.success(res, await adminPrayerService.updateStatus(cid(req), pid(req), status), 'Status updated');
    } catch (e) { next(e); }
  },

  async delete(req: AuthRequest, res: Response, next: NextFunction) {
    try { await adminPrayerService.delete(cid(req), pid(req)); ApiResponse.success(res, null, 'Prayer request deleted'); } catch (e) { next(e); }
  },
};
