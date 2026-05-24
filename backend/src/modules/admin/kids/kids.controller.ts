import { Response, NextFunction } from 'express';
import { adminKidsService } from './kids.service';
import { ApiResponse } from '../../../utils/apiResponse';
import { AuthRequest } from '../../../middleware/auth';

function cid(req: AuthRequest): string | null | undefined {
  if (req.user?.role === 'SUPER_ADMIN') {
    const qId = typeof req.query.churchId === 'string' ? req.query.churchId : undefined;
    return qId || req.user.churchId;
  }
  return req.user?.churchId ?? null;
}

export const kidsController = {
  // Rooms
  async listRooms(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.success(res, await adminKidsService.listRooms(cid(req))); } catch (e) { next(e); }
  },
  async createRoom(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.created(res, await adminKidsService.createRoom(cid(req), req.body)); } catch (e) { next(e); }
  },
  async updateRoom(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.success(res, await adminKidsService.updateRoom(cid(req), req.params['id'] as string, req.body), 'Room updated'); } catch (e) { next(e); }
  },
  async deleteRoom(req: AuthRequest, res: Response, next: NextFunction) {
    try { await adminKidsService.deleteRoom(cid(req), req.params['id'] as string); ApiResponse.success(res, null, 'Room deleted'); } catch (e) { next(e); }
  },

  // Children
  async listChildren(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { page = '1', limit = '20', search } = req.query as Record<string, string>;
      const result = await adminKidsService.listChildren(cid(req), { page: +page, limit: +limit, search });
      ApiResponse.paginated(res, result.children, { page: result.page, limit: result.limit, total: result.total, totalPages: result.totalPages });
    } catch (e) { next(e); }
  },

  // Check-ins
  async todayCheckins(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.success(res, await adminKidsService.todayCheckins(cid(req))); } catch (e) { next(e); }
  },
  async listCheckinHistory(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { page = '1', limit = '20', roomId } = req.query as Record<string, string>;
      const result = await adminKidsService.listCheckinHistory(cid(req), { page: +page, limit: +limit, roomId });
      ApiResponse.paginated(res, result.checkins, { page: result.page, limit: result.limit, total: result.total, totalPages: result.totalPages });
    } catch (e) { next(e); }
  },
};
