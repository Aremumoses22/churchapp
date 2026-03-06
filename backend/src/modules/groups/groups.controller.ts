import type { Response, NextFunction } from 'express';
import type { AuthRequest } from '../../middleware/auth';
import { groupsService } from './groups.service';
import { ApiError } from '../../utils/apiError';
import { ApiResponse } from '../../utils/apiResponse';

const param = (req: AuthRequest, name: string): string => req.params[name] as string;

export async function listGroups(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    if (!req.user?.churchId) throw ApiError.badRequest('No church associated');
    const result = await groupsService.listGroups(req.user.churchId, req.user.id, req.query as any);
    ApiResponse.paginated(res, result.data, result.meta);
  } catch (error) { next(error); }
}

export async function getGroupById(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    if (!req.user) throw ApiError.unauthorized();
    const result = await groupsService.getGroupById(param(req, 'id'), req.user.id);
    ApiResponse.success(res, result);
  } catch (error) { next(error); }
}

export async function joinGroup(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    if (!req.user) throw ApiError.unauthorized();
    const result = await groupsService.joinGroup(param(req, 'id'), req.user.id);
    ApiResponse.success(res, result, 'Joined group successfully');
  } catch (error) { next(error); }
}

export async function leaveGroup(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    if (!req.user) throw ApiError.unauthorized();
    const result = await groupsService.leaveGroup(param(req, 'id'), req.user.id);
    ApiResponse.success(res, result, 'Left group successfully');
  } catch (error) { next(error); }
}
