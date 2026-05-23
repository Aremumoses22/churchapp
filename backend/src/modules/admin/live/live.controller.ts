import { Response, NextFunction } from 'express';
import { adminLiveService } from './live.service';
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

export const liveController = {
  async list(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { page = '1', limit = '20', status } = req.query as Record<string, string>;
      const result = await adminLiveService.list(cid(req), { page: +page, limit: +limit, status });
      ApiResponse.paginated(res, result.services, { page: result.page, limit: result.limit, total: result.total, totalPages: result.totalPages });
    } catch (e) { next(e); }
  },

  async create(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.created(res, await adminLiveService.create(cid(req), req.body)); } catch (e) { next(e); }
  },

  async update(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.success(res, await adminLiveService.update(cid(req), pid(req), req.body), 'Service updated'); } catch (e) { next(e); }
  },

  async delete(req: AuthRequest, res: Response, next: NextFunction) {
    try { await adminLiveService.delete(cid(req), pid(req)); ApiResponse.success(res, null, 'Service deleted'); } catch (e) { next(e); }
  },

  async goLive(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.success(res, await adminLiveService.goLive(cid(req), pid(req)), 'Service is now LIVE'); } catch (e) { next(e); }
  },

  async endService(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.success(res, await adminLiveService.endService(cid(req), pid(req)), 'Service ended'); } catch (e) { next(e); }
  },
};
