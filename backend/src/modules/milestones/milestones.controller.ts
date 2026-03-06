import { Response, NextFunction } from 'express';
import { milestonesService } from './milestones.service';
import { ApiResponse } from '../../utils/apiResponse';
import { AuthRequest } from '../../middleware/auth';

export const milestonesController = {
  // GET /milestones
  async getUserMilestones(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const result = await milestonesService.getUserMilestones(
        req.user!.id,
        req.query as any,
      );
      ApiResponse.success(res, result);
    } catch (error) {
      next(error);
    }
  },

  // GET /milestones/summary
  async getMilestoneSummary(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const result = await milestonesService.getMilestoneSummary(req.user!.id);
      ApiResponse.success(res, result);
    } catch (error) {
      next(error);
    }
  },

  // POST /milestones (admin)
  async createMilestone(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      if (!req.user?.churchId) {
        return ApiResponse.error(res, 'Church context required', 400);
      }
      const result = await milestonesService.createMilestone(req.user.churchId, req.body);
      ApiResponse.created(res, result, 'Milestone created');
    } catch (error) {
      next(error);
    }
  },

  // DELETE /milestones/:id (admin)
  async deleteMilestone(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      if (!req.user?.churchId) {
        return ApiResponse.error(res, 'Church context required', 400);
      }
      const result = await milestonesService.deleteMilestone(
        req.user.churchId,
        req.params.id as string,
      );
      ApiResponse.success(res, null, result.message);
    } catch (error) {
      next(error);
    }
  },
};
