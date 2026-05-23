import type { Response, NextFunction } from 'express';
import { liveService } from './live.service';
import { ApiResponse } from '../../utils/apiResponse';
import type { AuthRequest } from '../../middleware/auth';
import { resolveChurchId } from '../../utils/churchHelper';

const param = (req: AuthRequest, name: string): string => req.params[name] as string;

export const liveController = {
  // GET /live — list live services
  async list(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const churchId = await resolveChurchId(req);
      if (!churchId) return ApiResponse.error(res, 'Church context required', 400);

      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 10;
      const status = req.query.status as string | undefined;

      const result = await liveService.list(churchId, { status, page, limit });
      ApiResponse.paginated(res, result.services, result.meta);
    } catch (error) {
      next(error);
    }
  },

  // GET /live/current — get current live service
  async getCurrent(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const churchId = await resolveChurchId(req);
      if (!churchId) return ApiResponse.error(res, 'Church context required', 400);

      const current = await liveService.getCurrentLive(churchId);
      const upcoming = current ? null : await liveService.getUpcoming(churchId);

      ApiResponse.success(res, {
        isLive: !!current,
        current,
        upcoming: upcoming || [],
      });
    } catch (error) {
      next(error);
    }
  },

  // GET /live/:id — get live service detail
  async getById(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const id = param(req, 'id');
      const service = await liveService.getById(id);
      ApiResponse.success(res, service);
    } catch (error) {
      next(error);
    }
  },

  // GET /live/:id/chat — get chat messages for live service
  async getChatMessages(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const id = param(req, 'id');
      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 50;

      const result = await liveService.getChatMessages(id, page, limit);
      ApiResponse.paginated(res, result.messages, result.meta);
    } catch (error) {
      next(error);
    }
  },
};
