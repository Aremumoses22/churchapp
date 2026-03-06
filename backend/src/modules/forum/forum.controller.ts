import type { Response, NextFunction } from 'express';
import type { AuthRequest } from '../../middleware/auth';
import { forumService } from './forum.service';
import { ApiError } from '../../utils/apiError';
import { ApiResponse } from '../../utils/apiResponse';

const param = (req: AuthRequest, name: string): string => req.params[name] as string;

export async function getCategories(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    if (!req.user?.churchId) throw ApiError.badRequest('No church associated');
    const result = await forumService.getCategories(req.user.churchId);
    ApiResponse.success(res, result);
  } catch (error) { next(error); }
}

export async function getTrending(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    if (!req.user?.churchId) throw ApiError.badRequest('No church associated');
    const result = await forumService.getTrending(req.user.churchId, req.user.id);
    ApiResponse.success(res, result);
  } catch (error) { next(error); }
}

export async function getRecent(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    if (!req.user?.churchId) throw ApiError.badRequest('No church associated');
    const result = await forumService.getRecent(req.user.churchId, req.user.id, req.query as any);
    ApiResponse.paginated(res, result.data, result.meta);
  } catch (error) { next(error); }
}

export async function getCategoryThreads(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    if (!req.user) throw ApiError.unauthorized();
    const result = await forumService.getCategoryThreads(param(req, 'id'), req.user.id, req.query as any);
    ApiResponse.paginated(res, result.data, result.meta, { category: result.category });
  } catch (error) { next(error); }
}

export async function getThreadDetail(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    if (!req.user) throw ApiError.unauthorized();
    const result = await forumService.getThreadDetail(param(req, 'id'), req.user.id, req.query as any);
    ApiResponse.success(res, result);
  } catch (error) { next(error); }
}

export async function createThread(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    if (!req.user?.churchId) throw ApiError.badRequest('No church associated');
    const result = await forumService.createThread(req.user.id, req.user.churchId, req.body);
    ApiResponse.created(res, result, 'Thread created');
  } catch (error) { next(error); }
}

export async function createReply(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    if (!req.user) throw ApiError.unauthorized();
    const result = await forumService.createReply(param(req, 'id'), req.user.id, req.body.content);
    ApiResponse.created(res, result, 'Reply posted');
  } catch (error) { next(error); }
}

export async function toggleThreadLike(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    if (!req.user) throw ApiError.unauthorized();
    const result = await forumService.toggleThreadLike(param(req, 'id'), req.user.id);
    ApiResponse.success(res, result);
  } catch (error) { next(error); }
}

export async function toggleBookmark(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    if (!req.user) throw ApiError.unauthorized();
    const result = await forumService.toggleBookmark(param(req, 'id'), req.user.id);
    ApiResponse.success(res, result);
  } catch (error) { next(error); }
}

export async function toggleReplyLike(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    if (!req.user) throw ApiError.unauthorized();
    const result = await forumService.toggleReplyLike(param(req, 'id'), req.user.id);
    ApiResponse.success(res, result);
  } catch (error) { next(error); }
}
