import { Response, NextFunction } from 'express';
import { eventsService } from './events.service';
import { ApiResponse } from '../../utils/apiResponse';
import { AuthRequest } from '../../middleware/auth';
import { resolveChurchId } from '../../utils/churchHelper';

export const eventsController = {
  // GET /events
  async list(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const churchId = await resolveChurchId(req);
      if (!churchId) return ApiResponse.error(res, 'Church context required', 400);
      const result = await eventsService.list(churchId, req.query as any);
      ApiResponse.paginated(res, result.events, result.total, result.page, result.limit);
    } catch (error) {
      next(error);
    }
  },

  // GET /events/featured
  async getFeatured(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const churchId = await resolveChurchId(req);
      if (!churchId) return ApiResponse.error(res, 'Church context required', 400);
      const events = await eventsService.getFeatured(churchId);
      ApiResponse.success(res, events);
    } catch (error) {
      next(error);
    }
  },

  // GET /events/my
  async getMyEvents(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const events = await eventsService.getMyEvents(req.user!.id);
      ApiResponse.success(res, events);
    } catch (error) {
      next(error);
    }
  },

  // GET /events/:id
  async getById(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const event = await eventsService.getById(req.params.id as string, req.user?.id);
      ApiResponse.success(res, event);
    } catch (error) {
      next(error);
    }
  },

  // POST /events/:id/register
  async register(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const result = await eventsService.register(req.user!.id, req.params.id as string);
      ApiResponse.created(res, result, `Registered (${result.status})`);
    } catch (error) {
      next(error);
    }
  },

  // DELETE /events/:id/register
  async cancelRegistration(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const result = await eventsService.cancelRegistration(req.user!.id, req.params.id as string);
      ApiResponse.success(res, null, result.message);
    } catch (error) {
      next(error);
    }
  },
};
