import type { Response, NextFunction } from 'express';
import type { AuthRequest } from '../../middleware/auth';
import { prayerService } from './prayer.service';
import { ApiError } from '../../utils/apiError';
import { ApiResponse } from '../../utils/apiResponse';

const param = (req: AuthRequest, name: string): string => req.params[name] as string;

export async function listPrayerRequests(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    if (!req.user?.churchId) throw ApiError.badRequest('No church associated');
    const result = await prayerService.listPrayerRequests(req.user.churchId, req.user.id, req.query as any);
    ApiResponse.paginated(res, result.data, result.meta);
  } catch (error) { next(error); }
}

export async function getMyRequests(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    if (!req.user) throw ApiError.unauthorized();
    const page = Number((req.query as any).page) || 1;
    const limit = Number((req.query as any).limit) || 20;
    const result = await prayerService.getMyRequests(req.user.id, { page, limit });
    ApiResponse.paginated(res, result.data, result.meta);
  } catch (error) { next(error); }
}

export async function createPrayerRequest(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    if (!req.user?.churchId) throw ApiError.badRequest('No church associated');
    const result = await prayerService.createPrayerRequest(req.user.id, req.user.churchId, req.body);
    ApiResponse.created(res, result, 'Prayer request submitted');
  } catch (error) { next(error); }
}

export async function prayForRequest(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    if (!req.user) throw ApiError.unauthorized();
    const result = await prayerService.prayForRequest(param(req, 'id'), req.user.id);
    ApiResponse.success(res, result);
  } catch (error) { next(error); }
}

export async function updateStatus(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    if (!req.user) throw ApiError.unauthorized();
    const result = await prayerService.updateStatus(param(req, 'id'), req.user.id, req.body.status);
    ApiResponse.success(res, result, 'Prayer request status updated');
  } catch (error) { next(error); }
}
