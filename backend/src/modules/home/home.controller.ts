import { Response, NextFunction } from 'express';
import { homeService } from './home.service';
import { ApiResponse } from '../../utils/apiResponse';
import { AuthRequest } from '../../middleware/auth';

export const homeController = {
  // GET /home/feed
  async getFeed(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const userId = req.user!.id;
      const churchId = req.user!.churchId;
      if (!churchId) return ApiResponse.error(res, 'Church context required', 400);
      const feed = await homeService.getFeed(userId, churchId);
      ApiResponse.success(res, feed);
    } catch (error) {
      next(error);
    }
  },
};
