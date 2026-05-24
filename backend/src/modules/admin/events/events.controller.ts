import { Response, NextFunction } from 'express';
import { adminEventsService } from './events.service';
import { ApiResponse } from '../../../utils/apiResponse';
import { AuthRequest } from '../../../middleware/auth';
import { notifyNewEvent } from '../../../services/notification.triggers';

function cid(req: AuthRequest): string | null | undefined {
  if (req.user?.role === 'SUPER_ADMIN') {
    const qId = typeof req.query.churchId === 'string' ? req.query.churchId : undefined;
    return qId || req.user.churchId;
  }
  return req.user?.churchId ?? null;
}

function pid(req: AuthRequest): string { return req.params['id'] as string; }

export const eventsController = {
  async list(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { page = '1', limit = '20', search, category, upcoming } = req.query as Record<string, string>;
      const result = await adminEventsService.list(cid(req), { page: +page, limit: +limit, search, category, upcoming: upcoming === 'true' });
      ApiResponse.paginated(res, result.events, { page: result.page, limit: result.limit, total: result.total, totalPages: result.totalPages });
    } catch (e) { next(e); }
  },

  async getById(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.success(res, await adminEventsService.getById(cid(req), pid(req))); } catch (e) { next(e); }
  },

  async create(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const churchId = cid(req);
      const event = await adminEventsService.create(churchId, req.body);
      ApiResponse.created(res, event);
      if (churchId) notifyNewEvent(churchId, event.id, event.title, event.startDate).catch(() => {});
    } catch (e) { next(e); }
  },

  async update(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.success(res, await adminEventsService.update(cid(req), pid(req), req.body), 'Event updated'); } catch (e) { next(e); }
  },

  async delete(req: AuthRequest, res: Response, next: NextFunction) {
    try { await adminEventsService.delete(cid(req), pid(req)); ApiResponse.success(res, null, 'Event deleted'); } catch (e) { next(e); }
  },

  async toggleFeatured(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.success(res, await adminEventsService.toggleFeatured(cid(req), pid(req))); } catch (e) { next(e); }
  },

  async listRegistrations(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { page = '1', limit = '20' } = req.query as Record<string, string>;
      const result = await adminEventsService.listRegistrations(cid(req), pid(req), { page: +page, limit: +limit });
      ApiResponse.paginated(res, result.registrations, { page: result.page, limit: result.limit, total: result.total, totalPages: result.totalPages });
    } catch (e) { next(e); }
  },
};
