import { Response, NextFunction } from 'express';
import { sermonsService } from './sermons.service';
import { ApiResponse } from '../../utils/apiResponse';
import { AuthRequest } from '../../middleware/auth';
import { resolveChurchId } from '../../utils/churchHelper';

export const sermonsController = {
  // GET /sermons
  async list(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const churchId = await resolveChurchId(req);
      if (!churchId) return ApiResponse.error(res, 'Church context required', 400);
      const result = await sermonsService.list(churchId, req.query as any);
      ApiResponse.paginated(res, result.sermons, result.total, result.page, result.limit);
    } catch (error) {
      next(error);
    }
  },

  // GET /sermons/featured
  async getFeatured(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const churchId = await resolveChurchId(req);
      if (!churchId) return ApiResponse.error(res, 'Church context required', 400);
      const sermons = await sermonsService.getFeatured(churchId);
      ApiResponse.success(res, sermons);
    } catch (error) {
      next(error);
    }
  },

  // GET /sermons/:id
  async getById(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const sermon = await sermonsService.getById(req.params.id as string, req.user?.id);
      ApiResponse.success(res, sermon);
    } catch (error) {
      next(error);
    }
  },

  // GET /sermons/:id/stream
  async getStreamUrl(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const result = await sermonsService.getStreamUrl(req.params.id as string);
      ApiResponse.success(res, result);
    } catch (error) {
      next(error);
    }
  },

  // POST /sermons/:id/progress
  async saveProgress(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const result = await sermonsService.saveProgress(req.user!.id, req.params.id as string, req.body);
      ApiResponse.success(res, result, 'Progress saved');
    } catch (error) {
      next(error);
    }
  },

  // POST /sermons/:id/save
  async toggleSave(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const result = await sermonsService.toggleSave(req.user!.id, req.params.id as string);
      ApiResponse.success(res, { saved: result.saved }, result.message);
    } catch (error) {
      next(error);
    }
  },

  // GET /sermons/saved
  async getSaved(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const sermons = await sermonsService.getSaved(req.user!.id);
      ApiResponse.success(res, sermons);
    } catch (error) {
      next(error);
    }
  },

  // GET /sermons/:id/notes
  async getNotes(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const notes = await sermonsService.getNotes(req.user!.id, req.params.id as string);
      ApiResponse.success(res, notes);
    } catch (error) {
      next(error);
    }
  },

  // PUT /sermons/:id/notes
  async saveNotes(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const notes = await sermonsService.saveNotes(req.user!.id, req.params.id as string, req.body);
      ApiResponse.success(res, notes, 'Notes saved');
    } catch (error) {
      next(error);
    }
  },

  // GET /series
  async listSeries(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const churchId = await resolveChurchId(req);
      if (!churchId) return ApiResponse.error(res, 'Church context required', 400);
      const series = await sermonsService.listSeries(churchId);
      ApiResponse.success(res, series);
    } catch (error) {
      next(error);
    }
  },

  // GET /series/:id
  async getSeriesById(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const series = await sermonsService.getSeriesById(req.params.id as string);
      ApiResponse.success(res, series);
    } catch (error) {
      next(error);
    }
  },
};
