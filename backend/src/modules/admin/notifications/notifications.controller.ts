import { Response, NextFunction } from 'express';
import { adminNotificationsService } from './notifications.service';
import { ApiResponse } from '../../../utils/apiResponse';
import { AuthRequest } from '../../../middleware/auth';

function cid(req: AuthRequest): string | null | undefined {
  if (req.user?.role === 'SUPER_ADMIN') {
    const qId = typeof req.query.churchId === 'string' ? req.query.churchId : undefined;
    return qId || req.user.churchId;
  }
  return req.user?.churchId ?? null;
}

export const notificationsController = {
  async list(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { page = '1', limit = '20' } = req.query as Record<string, string>;
      const result = await adminNotificationsService.list(cid(req), { page: +page, limit: +limit });
      ApiResponse.paginated(res, result.notifications, { page: result.page, limit: result.limit, total: result.total, totalPages: result.totalPages });
    } catch (e) { next(e); }
  },

  async sendToAll(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.success(res, await adminNotificationsService.sendToAll(cid(req), req.body), 'Notifications sent'); } catch (e) { next(e); }
  },

  async delete(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const id = req.params['id'] as string;
      await adminNotificationsService.deleteNotification(id);
      ApiResponse.success(res, null, 'Notification deleted');
    } catch (e) { next(e); }
  },
};
