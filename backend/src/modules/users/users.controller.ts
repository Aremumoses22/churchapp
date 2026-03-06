import { Response, NextFunction } from 'express';
import { usersService } from './users.service';
import { ApiResponse } from '../../utils/apiResponse';
import { AuthRequest } from '../../middleware/auth';

export const usersController = {
  // GET /users/me
  async getProfile(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const user = await usersService.getProfile(req.user!.id);
      ApiResponse.success(res, user);
    } catch (error) {
      next(error);
    }
  },

  // PUT /users/me
  async updateProfile(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const user = await usersService.updateProfile(req.user!.id, req.body);
      ApiResponse.success(res, user, 'Profile updated');
    } catch (error) {
      next(error);
    }
  },

  // PUT /users/me/avatar
  async updateAvatar(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      if (!req.file) {
        return ApiResponse.error(res, 'No file uploaded', 400);
      }
      const result = await usersService.updateAvatar(req.user!.id, req.file.buffer);
      ApiResponse.success(res, result, 'Avatar updated');
    } catch (error) {
      next(error);
    }
  },

  // PUT /users/me/notification-prefs
  async updateNotificationPrefs(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const result = await usersService.updateNotificationPrefs(req.user!.id, req.body);
      ApiResponse.success(res, result, 'Notification preferences updated');
    } catch (error) {
      next(error);
    }
  },

  // PUT /users/me/fcm-token
  async updateFcmToken(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const result = await usersService.updateFcmToken(req.user!.id, req.body);
      ApiResponse.success(res, null, result.message);
    } catch (error) {
      next(error);
    }
  },

  // GET /users/me/attendance
  async getAttendance(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const result = await usersService.getAttendance(req.user!.id);
      ApiResponse.success(res, result);
    } catch (error) {
      next(error);
    }
  },

  // GET /users/me/milestones
  async getMilestones(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const result = await usersService.getMilestones(req.user!.id);
      ApiResponse.success(res, result);
    } catch (error) {
      next(error);
    }
  },

  // GET /users/me/saved-items
  async getSavedItems(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const result = await usersService.getSavedItems(req.user!.id);
      ApiResponse.success(res, result);
    } catch (error) {
      next(error);
    }
  },

  // POST /users/me/saved-items
  async addSavedItem(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const result = await usersService.addSavedItem(req.user!.id, req.body.itemType, req.body.itemId);
      ApiResponse.created(res, result, 'Item saved');
    } catch (error) {
      next(error);
    }
  },

  // DELETE /users/me/saved-items/:id
  async removeSavedItem(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const result = await usersService.removeSavedItem(req.user!.id, req.params.id as string);
      ApiResponse.success(res, null, result.message);
    } catch (error) {
      next(error);
    }
  },
};
