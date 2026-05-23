import { Response, NextFunction } from 'express';
import { adminChurchService } from './church.service';
import { ApiResponse } from '../../../utils/apiResponse';
import { AuthRequest } from '../../../middleware/auth';

function cid(req: AuthRequest) {
  if (req.user?.role === 'SUPER_ADMIN') {
    const qId = typeof req.query.churchId === 'string' ? req.query.churchId : undefined;
    return qId || req.user.churchId;
  }
  return req.user?.churchId;
}

function pid(req: AuthRequest) { return req.params['id'] as string; }

export const churchController = {
  async get(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.success(res, await adminChurchService.get(cid(req))); } catch (e) { next(e); }
  },
  async updateInfo(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.success(res, await adminChurchService.updateInfo(cid(req), req.body), 'Church updated'); } catch (e) { next(e); }
  },
  async updateLogo(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.success(res, await adminChurchService.updateLogo(cid(req), req.body.logoUrl), 'Logo updated'); } catch (e) { next(e); }
  },
  async updateCoverImage(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.success(res, await adminChurchService.updateCoverImage(cid(req), req.body.coverImageUrl), 'Cover image updated'); } catch (e) { next(e); }
  },
  async updateTimeline(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.success(res, await adminChurchService.updateTimeline(cid(req), req.body.timeline), 'Timeline updated'); } catch (e) { next(e); }
  },

  // Staff
  async listStaff(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.success(res, await adminChurchService.listStaff(cid(req))); } catch (e) { next(e); }
  },
  async createStaff(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.created(res, await adminChurchService.createStaff(cid(req), req.body), 'Staff member added'); } catch (e) { next(e); }
  },
  async updateStaff(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.success(res, await adminChurchService.updateStaff(cid(req), pid(req), req.body), 'Staff member updated'); } catch (e) { next(e); }
  },
  async deleteStaff(req: AuthRequest, res: Response, next: NextFunction) {
    try { await adminChurchService.deleteStaff(cid(req), pid(req)); ApiResponse.success(res, null, 'Staff member removed'); } catch (e) { next(e); }
  },

  // Campuses
  async listCampuses(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.success(res, await adminChurchService.listCampuses(cid(req))); } catch (e) { next(e); }
  },
  async createCampus(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.created(res, await adminChurchService.createCampus(cid(req), req.body), 'Campus added'); } catch (e) { next(e); }
  },
  async updateCampus(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.success(res, await adminChurchService.updateCampus(cid(req), pid(req), req.body), 'Campus updated'); } catch (e) { next(e); }
  },
  async deleteCampus(req: AuthRequest, res: Response, next: NextFunction) {
    try { await adminChurchService.deleteCampus(cid(req), pid(req)); ApiResponse.success(res, null, 'Campus removed'); } catch (e) { next(e); }
  },
  async upsertServiceTimes(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.success(res, await adminChurchService.upsertServiceTimes(pid(req), cid(req), req.body.times), 'Service times updated'); } catch (e) { next(e); }
  },

  // FAQs
  async listFaqs(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.success(res, await adminChurchService.listFaqs(cid(req))); } catch (e) { next(e); }
  },
  async createFaq(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.created(res, await adminChurchService.createFaq(cid(req), req.body), 'FAQ added'); } catch (e) { next(e); }
  },
  async updateFaq(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.success(res, await adminChurchService.updateFaq(cid(req), pid(req), req.body), 'FAQ updated'); } catch (e) { next(e); }
  },
  async deleteFaq(req: AuthRequest, res: Response, next: NextFunction) {
    try { await adminChurchService.deleteFaq(cid(req), pid(req)); ApiResponse.success(res, null, 'FAQ deleted'); } catch (e) { next(e); }
  },

  // Core Values
  async listCoreValues(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.success(res, await adminChurchService.listCoreValues(cid(req))); } catch (e) { next(e); }
  },
  async createCoreValue(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.created(res, await adminChurchService.createCoreValue(cid(req), req.body), 'Core value added'); } catch (e) { next(e); }
  },
  async updateCoreValue(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.success(res, await adminChurchService.updateCoreValue(cid(req), pid(req), req.body), 'Core value updated'); } catch (e) { next(e); }
  },
  async deleteCoreValue(req: AuthRequest, res: Response, next: NextFunction) {
    try { await adminChurchService.deleteCoreValue(cid(req), pid(req)); ApiResponse.success(res, null, 'Core value deleted'); } catch (e) { next(e); }
  },
};
