import type { Response, NextFunction } from 'express';
import type { AuthRequest } from '../../middleware/auth';
import { volunteerService } from './volunteer.service';
import { ApiResponse } from '../../utils/apiResponse';
import { resolveChurchId } from '../../utils/churchHelper';

export const volunteerController = {
  async listOpportunities(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const churchId = await resolveChurchId(req);
      if (!churchId) return ApiResponse.error(res, 'Church context required', 400);
      const query = req.query as any;
      const input: any = {
        page: query.page ?? 1,
        limit: query.limit ?? 20,
        department: query.department,
      };
      if (query.active !== undefined) input.active = query.active;

      const result = await volunteerService.listOpportunities(churchId, input);
      return ApiResponse.paginated(
        res,
        result.opportunities,
        result.meta.page,
        result.meta.limit,
        result.meta.total
      );
    } catch (error) {
      next(error);
    }
  },

  async signup(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const userId = req.user!.id;
      const { opportunityId } = req.body;

      const signup = await volunteerService.signup(userId, opportunityId);
      return ApiResponse.created(res, signup, 'Successfully signed up for volunteering');
    } catch (error) {
      next(error);
    }
  },

  async listRoster(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const userId = req.user!.id;
      const query = req.query as any;
      const input = {
        page: query.page ?? 1,
        limit: query.limit ?? 20,
        upcoming: query.upcoming ?? true,
      };

      const result = await volunteerService.listRoster(userId, input);
      return ApiResponse.paginated(
        res,
        result.shifts,
        result.meta.page,
        result.meta.limit,
        result.meta.total
      );
    } catch (error) {
      next(error);
    }
  },

  async checkin(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const userId = req.user!.id;
      const id = req.params.id as string;

      const shift = await volunteerService.checkin(userId, id);
      return ApiResponse.success(res, shift, 'Checked in successfully');
    } catch (error) {
      next(error);
    }
  },

  async swapShift(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const userId = req.user!.id;
      const id = req.params.id as string;
      const { targetUserId } = req.body;

      const shift = await volunteerService.swapShift(userId, id, targetUserId);
      return ApiResponse.success(res, shift, 'Shift swapped successfully');
    } catch (error) {
      next(error);
    }
  },
};
