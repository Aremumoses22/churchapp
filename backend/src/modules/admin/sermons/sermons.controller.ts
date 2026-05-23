import { Response, NextFunction } from 'express';
import { adminSermonsService } from './sermons.service';
import { ApiResponse } from '../../../utils/apiResponse';
import { AuthRequest } from '../../../middleware/auth';

function cid(req: AuthRequest) {
  if (req.user?.role === 'SUPER_ADMIN') {
    const qId = typeof req.query.churchId === 'string' ? req.query.churchId : undefined;
    return qId || req.user.churchId;
  }
  return req.user?.churchId;
}

function pid(req: AuthRequest) { return req.params['id'] as string; }

export const sermonsController = {
  // Series
  async listSeries(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.success(res, await adminSermonsService.listSeries(cid(req))); } catch (e) { next(e); }
  },
  async createSeries(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.created(res, await adminSermonsService.createSeries(cid(req), req.body)); } catch (e) { next(e); }
  },
  async updateSeries(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.success(res, await adminSermonsService.updateSeries(cid(req), pid(req), req.body), 'Series updated'); } catch (e) { next(e); }
  },
  async deleteSeries(req: AuthRequest, res: Response, next: NextFunction) {
    try { await adminSermonsService.deleteSeries(cid(req), pid(req)); ApiResponse.success(res, null, 'Series deleted'); } catch (e) { next(e); }
  },

  // Sermons
  async list(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { page = '1', limit = '20', search, seriesId } = req.query as Record<string, string>;
      const result = await adminSermonsService.list(cid(req), { page: +page, limit: +limit, search, seriesId });
      ApiResponse.paginated(res, result.sermons, { page: result.page, limit: result.limit, total: result.total, totalPages: result.totalPages });
    } catch (e) { next(e); }
  },
  async getById(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.success(res, await adminSermonsService.getById(cid(req), pid(req))); } catch (e) { next(e); }
  },
  async create(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.created(res, await adminSermonsService.create(cid(req), req.body)); } catch (e) { next(e); }
  },
  async update(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.success(res, await adminSermonsService.update(cid(req), pid(req), req.body), 'Sermon updated'); } catch (e) { next(e); }
  },
  async delete(req: AuthRequest, res: Response, next: NextFunction) {
    try { await adminSermonsService.delete(cid(req), pid(req)); ApiResponse.success(res, null, 'Sermon deleted'); } catch (e) { next(e); }
  },
  async toggleFeatured(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.success(res, await adminSermonsService.toggleFeatured(cid(req), pid(req))); } catch (e) { next(e); }
  },
};
