import { Response, NextFunction } from 'express';
import { churchService } from './church.service';
import { ApiResponse } from '../../utils/apiResponse';
import { AuthRequest } from '../../middleware/auth';
import { resolveChurchId } from '../../utils/churchHelper';

export const churchController = {
  // GET /church/about
  async getAbout(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const churchId = await resolveChurchId(req);
      if (!churchId) return ApiResponse.error(res, 'Church context required', 400);
      const about = await churchService.getAbout(churchId);
      ApiResponse.success(res, about);
    } catch (error) {
      next(error);
    }
  },

  // GET /church/staff
  async getStaff(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const churchId = await resolveChurchId(req);
      if (!churchId) return ApiResponse.error(res, 'Church context required', 400);
      const staff = await churchService.getStaff(churchId);
      ApiResponse.success(res, staff);
    } catch (error) {
      next(error);
    }
  },

  // GET /church/campuses
  async getCampuses(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const churchId = await resolveChurchId(req);
      if (!churchId) return ApiResponse.error(res, 'Church context required', 400);
      const campuses = await churchService.getCampuses(churchId);
      ApiResponse.success(res, campuses);
    } catch (error) {
      next(error);
    }
  },

  // GET /church/faqs
  async getFAQs(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const churchId = await resolveChurchId(req);
      if (!churchId) return ApiResponse.error(res, 'Church context required', 400);
      const faqs = await churchService.getFAQs(churchId);
      ApiResponse.success(res, faqs);
    } catch (error) {
      next(error);
    }
  },

  // POST /church/contact
  async submitContact(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const churchId = await resolveChurchId(req);
      if (!churchId) return ApiResponse.error(res, 'Church context required', 400);
      const result = await churchService.submitContact(churchId, req.user!.id, req.body);
      ApiResponse.success(res, null, result.message);
    } catch (error) {
      next(error);
    }
  },
};
