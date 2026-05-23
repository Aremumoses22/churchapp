import { Response, NextFunction } from 'express';
import { adminForumService } from './forum.service';
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

export const forumController = {
  async listCategories(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.success(res, await adminForumService.listCategories(cid(req))); } catch (e) { next(e); }
  },
  async createCategory(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.created(res, await adminForumService.createCategory(cid(req), req.body)); } catch (e) { next(e); }
  },
  async updateCategory(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.success(res, await adminForumService.updateCategory(cid(req), pid(req), req.body)); } catch (e) { next(e); }
  },
  async deleteCategory(req: AuthRequest, res: Response, next: NextFunction) {
    try { await adminForumService.deleteCategory(cid(req), pid(req)); ApiResponse.success(res, null, 'Category deleted'); } catch (e) { next(e); }
  },

  async listThreads(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { page = '1', limit = '20', search, categoryId } = req.query as Record<string, string>;
      const result = await adminForumService.listThreads(cid(req), { page: +page, limit: +limit, search, categoryId });
      ApiResponse.paginated(res, result.threads, { page: result.page, limit: result.limit, total: result.total, totalPages: result.totalPages });
    } catch (e) { next(e); }
  },
  async pinThread(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.success(res, await adminForumService.pinThread(cid(req), pid(req))); } catch (e) { next(e); }
  },
  async lockThread(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.success(res, await adminForumService.lockThread(cid(req), pid(req))); } catch (e) { next(e); }
  },
  async deleteThread(req: AuthRequest, res: Response, next: NextFunction) {
    try { await adminForumService.deleteThread(cid(req), pid(req)); ApiResponse.success(res, null, 'Thread deleted'); } catch (e) { next(e); }
  },
};
