import type { Response, NextFunction } from 'express';
import type { AuthRequest } from '../../middleware/auth';
import { searchService } from './search.service';
import { ApiResponse } from '../../utils/apiResponse';

export const searchController = {
  async search(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const churchId = req.user?.churchId;
      if (!churchId) return ApiResponse.error(res, 'Church context required', 400);
      const query = req.query as any;
      const input = {
        q: query.q as string,
        type: query.type ?? 'all',
        page: query.page ?? 1,
        limit: query.limit ?? 20,
      };

      const result = await searchService.search(churchId, input);
      return ApiResponse.paginated(
        res,
        result.results,
        result.meta.page,
        result.meta.limit,
        result.meta.total
      );
    } catch (error) {
      next(error);
    }
  },

  async trending(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const churchId = req.user?.churchId;
      if (!churchId) return ApiResponse.error(res, 'Church context required', 400);
      const query = req.query as any;
      const limit = query.limit ?? 10;

      const trending = await searchService.getTrending(churchId, limit);
      return ApiResponse.success(res, trending, 'Trending items retrieved');
    } catch (error) {
      next(error);
    }
  },
};
