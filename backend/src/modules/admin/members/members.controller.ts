import { Response, NextFunction } from 'express';
import { membersService } from './members.service';
import { ApiResponse } from '../../../utils/apiResponse';
import { AuthRequest } from '../../../middleware/auth';

function resolveChurchId(req: AuthRequest): string | null | undefined {
  if (req.user?.role === 'SUPER_ADMIN') {
    const qId = typeof req.query.churchId === 'string' ? req.query.churchId : undefined;
    return qId || req.user.churchId;
  }
  return req.user?.churchId ?? null;
}

function id(req: AuthRequest): string {
  return req.params['id'] as string;
}

export const membersController = {
  async list(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { page = 1, limit = 20, search, role, status } = req.query as Record<string, string>;
      const result = await membersService.list(resolveChurchId(req), {
        page: Number(page), limit: Number(limit), search, role, status,
      });
      ApiResponse.paginated(res, result.members, { page: result.page, limit: result.limit, total: result.total, totalPages: result.totalPages });
    } catch (e) { next(e); }
  },

  async getById(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const data = await membersService.getById(resolveChurchId(req), id(req));
      ApiResponse.success(res, data);
    } catch (e) { next(e); }
  },

  async update(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const data = await membersService.update(resolveChurchId(req), id(req), req.body);
      ApiResponse.success(res, data, 'Member updated');
    } catch (e) { next(e); }
  },

  async changeRole(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const data = await membersService.changeRole(req.user!.role, resolveChurchId(req), id(req), req.body.role);
      ApiResponse.success(res, data, 'Role updated');
    } catch (e) { next(e); }
  },

  async setStatus(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const data = await membersService.setStatus(resolveChurchId(req), id(req), req.body.isActive);
      ApiResponse.success(res, data, `Member ${req.body.isActive ? 'activated' : 'deactivated'}`);
    } catch (e) { next(e); }
  },

  async delete(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      await membersService.delete(req.user!.role, resolveChurchId(req), id(req));
      ApiResponse.success(res, null, 'Member deleted');
    } catch (e) { next(e); }
  },

  async givingHistory(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const data = await membersService.givingHistory(resolveChurchId(req), id(req));
      ApiResponse.success(res, data);
    } catch (e) { next(e); }
  },

  async invite(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const result = await membersService.invite(resolveChurchId(req), req.body);
      ApiResponse.created(res, result, 'Invitation sent');
    } catch (e) { next(e); }
  },

  async exportCsv(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const csv = await membersService.exportCsv(resolveChurchId(req));
      res.setHeader('Content-Type', 'text/csv');
      res.setHeader('Content-Disposition', 'attachment; filename="members.csv"');
      res.send(csv);
    } catch (e) { next(e); }
  },
};
