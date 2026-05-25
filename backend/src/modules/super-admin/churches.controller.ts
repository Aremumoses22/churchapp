import { Response, NextFunction } from 'express';
import { AuthRequest } from '../../middleware/auth';
import { ApiResponse } from '../../utils/apiResponse';
import { superAdminChurchService } from './churches.service';
import { createChurchSchema, updateChurchSchema, suspendChurchSchema } from './churches.validation';

function id(req: AuthRequest): string {
  return req.params['id'] as string;
}

export const superAdminChurchController = {
  async list(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { page = '1', limit = '20', search, status } = req.query as Record<string, string>;
      const result = await superAdminChurchService.list({
        page: Number(page), limit: Number(limit), search, status,
      });
      ApiResponse.paginated(res, result.churches, {
        page: result.page, limit: result.limit, total: result.total, totalPages: result.totalPages,
      });
    } catch (e) { next(e); }
  },

  async getById(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const data = await superAdminChurchService.getById(id(req));
      ApiResponse.success(res, data);
    } catch (e) { next(e); }
  },

  async create(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const input = createChurchSchema.parse(req.body);
      const church = await superAdminChurchService.create(input);
      ApiResponse.created(res, church, 'Church created successfully');
    } catch (e) { next(e); }
  },

  async update(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const input = updateChurchSchema.parse(req.body);
      const church = await superAdminChurchService.update(id(req), input);
      ApiResponse.success(res, church, 'Church updated');
    } catch (e) { next(e); }
  },

  async suspend(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const input = suspendChurchSchema.parse(req.body);
      const church = await superAdminChurchService.suspend(id(req), input);
      ApiResponse.success(res, church, 'Church suspended');
    } catch (e) { next(e); }
  },

  async unsuspend(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const church = await superAdminChurchService.unsuspend(id(req));
      ApiResponse.success(res, church, 'Church reinstated');
    } catch (e) { next(e); }
  },

  async regenerateCode(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const church = await superAdminChurchService.regenerateCode(id(req));
      ApiResponse.success(res, church, 'Church code regenerated');
    } catch (e) { next(e); }
  },

  async delete(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      await superAdminChurchService.delete(id(req));
      ApiResponse.success(res, null, 'Church deleted');
    } catch (e) { next(e); }
  },

  async listMembers(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { page = '1', limit = '20', search, role } = req.query as Record<string, string>;
      const result = await superAdminChurchService.listMembers(id(req), {
        page: Number(page), limit: Number(limit), search, role,
      });
      ApiResponse.paginated(res, result.members, {
        page: result.page, limit: result.limit, total: result.total, totalPages: result.totalPages,
      });
    } catch (e) { next(e); }
  },

  async removeMember(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      await superAdminChurchService.removeMember(id(req), req.params['userId'] as string);
      ApiResponse.success(res, null, 'Member removed from church');
    } catch (e) { next(e); }
  },

  async platformStats(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const stats = await superAdminChurchService.platformStats();
      ApiResponse.success(res, stats);
    } catch (e) { next(e); }
  },
};
