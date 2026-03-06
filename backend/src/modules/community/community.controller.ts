import type { Response, NextFunction } from 'express';
import type { AuthRequest } from '../../middleware/auth';
import { communityService } from './community.service';
import { ApiError } from '../../utils/apiError';
import { ApiResponse } from '../../utils/apiResponse';

const param = (req: AuthRequest, name: string): string => req.params[name] as string;

// ═══════════════════════════════════════════════════════
// ANNOUNCEMENTS
// ═══════════════════════════════════════════════════════
export async function getAnnouncements(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    if (!req.user?.churchId) throw ApiError.badRequest('No church associated');
    const result = await communityService.getAnnouncements(req.user.churchId, req.user.id, req.query as any);
    ApiResponse.paginated(res, result.data, result.meta);
  } catch (error) { next(error); }
}

export async function getAnnouncementById(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    if (!req.user) throw ApiError.unauthorized();
    const result = await communityService.getAnnouncementById(param(req, 'id'), req.user.id);
    ApiResponse.success(res, result);
  } catch (error) { next(error); }
}

export async function markAnnouncementRead(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    if (!req.user) throw ApiError.unauthorized();
    const result = await communityService.markAnnouncementRead(param(req, 'id'), req.user.id);
    ApiResponse.success(res, result, 'Announcement marked as read');
  } catch (error) { next(error); }
}

// ═══════════════════════════════════════════════════════
// TESTIMONIES
// ═══════════════════════════════════════════════════════
export async function getTestimonies(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    if (!req.user?.churchId) throw ApiError.badRequest('No church associated');
    const result = await communityService.getTestimonies(req.user.churchId, req.user.id, req.query as any);
    ApiResponse.paginated(res, result.data, result.meta);
  } catch (error) { next(error); }
}

export async function submitTestimony(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    if (!req.user?.churchId) throw ApiError.badRequest('No church associated');
    const result = await communityService.submitTestimony(req.user.id, req.user.churchId, req.body);
    ApiResponse.created(res, result, 'Testimony submitted for review');
  } catch (error) { next(error); }
}

export async function reactToTestimony(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    if (!req.user) throw ApiError.unauthorized();
    const { type } = req.body;
    const result = await communityService.reactToTestimony(param(req, 'id'), req.user.id, type);
    ApiResponse.success(res, result);
  } catch (error) { next(error); }
}

// ═══════════════════════════════════════════════════════
// DIRECTORY
// ═══════════════════════════════════════════════════════
export async function getDirectory(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    if (!req.user?.churchId) throw ApiError.badRequest('No church associated');
    const result = await communityService.getDirectory(req.user.churchId, req.query as any);
    ApiResponse.paginated(res, result.data, result.meta);
  } catch (error) { next(error); }
}

// ═══════════════════════════════════════════════════════
// INVITES
// ═══════════════════════════════════════════════════════
export async function generateInviteLink(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    if (!req.user?.churchId) throw ApiError.badRequest('No church associated');
    const result = await communityService.generateInviteLink(req.user.id, req.user.churchId);
    ApiResponse.created(res, result, 'Invite link generated');
  } catch (error) { next(error); }
}

export async function validateInviteLink(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    const code = param(req, 'code');
    const result = await communityService.validateInviteLink(code);
    ApiResponse.success(res, result);
  } catch (error) { next(error); }
}

export async function getInviteStats(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    if (!req.user) throw ApiError.unauthorized();
    const result = await communityService.getUserInviteStats(req.user.id);
    ApiResponse.success(res, result);
  } catch (error) { next(error); }
}
