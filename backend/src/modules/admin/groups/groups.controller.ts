import { Response, NextFunction } from 'express';
import { adminGroupsService } from './groups.service';
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

export const groupsController = {
  async list(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { page = '1', limit = '20', search, category } = req.query as Record<string, string>;
      const result = await adminGroupsService.list(cid(req), { page: +page, limit: +limit, search, category });
      ApiResponse.paginated(res, result.groups, { page: result.page, limit: result.limit, total: result.total, totalPages: result.totalPages });
    } catch (e) { next(e); }
  },

  async getById(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.success(res, await adminGroupsService.getById(cid(req), pid(req))); } catch (e) { next(e); }
  },

  async create(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.created(res, await adminGroupsService.create(cid(req), req.body)); } catch (e) { next(e); }
  },

  async update(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.success(res, await adminGroupsService.update(cid(req), pid(req), req.body), 'Group updated'); } catch (e) { next(e); }
  },

  async delete(req: AuthRequest, res: Response, next: NextFunction) {
    try { await adminGroupsService.delete(cid(req), pid(req)); ApiResponse.success(res, null, 'Group deleted'); } catch (e) { next(e); }
  },

  async removeMember(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const userId = req.params['userId'] as string;
      await adminGroupsService.removeMember(cid(req), pid(req), userId);
      ApiResponse.success(res, null, 'Member removed');
    } catch (e) { next(e); }
  },
};
