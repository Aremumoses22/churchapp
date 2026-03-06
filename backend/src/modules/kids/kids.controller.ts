import type { Response, NextFunction } from 'express';
import type { AuthRequest } from '../../middleware/auth';
import { kidsService } from './kids.service';
import { ApiResponse } from '../../utils/apiResponse';

export const kidsController = {
  async listChildren(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const userId = req.user!.id;
      const query = req.query as any;
      const input = {
        page: query.page ?? 1,
        limit: query.limit ?? 20,
      };

      const result = await kidsService.listChildren(userId, input);
      return ApiResponse.paginated(
        res,
        result.children,
        result.meta.page,
        result.meta.limit,
        result.meta.total
      );
    } catch (error) {
      next(error);
    }
  },

  async registerChild(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const userId = req.user!.id;
      const churchId = req.user?.churchId;
      if (!churchId) return ApiResponse.error(res, 'Church context required', 400);

      const child = await kidsService.registerChild(userId, churchId, req.body);
      return ApiResponse.created(res, child, 'Child registered successfully');
    } catch (error) {
      next(error);
    }
  },

  async checkIn(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const operatorId = req.user!.id;

      const result = await kidsService.checkIn(operatorId, req.body);
      return ApiResponse.created(res, result, 'Child checked in successfully');
    } catch (error) {
      next(error);
    }
  },

  async checkOut(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const result = await kidsService.checkOut(req.body);
      return ApiResponse.success(res, result, 'Child checked out successfully');
    } catch (error) {
      next(error);
    }
  },

  async listRooms(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const churchId = req.user?.churchId;
      if (!churchId) return ApiResponse.error(res, 'Church context required', 400);
      const query = req.query as any;
      const page = query.page ?? 1;
      const limit = query.limit ?? 20;

      const result = await kidsService.listRooms(churchId, page, limit);
      return ApiResponse.paginated(
        res,
        result.rooms,
        result.meta.page,
        result.meta.limit,
        result.meta.total
      );
    } catch (error) {
      next(error);
    }
  },
};
