import { Request, Response, NextFunction } from 'express';
import { adminAuthService } from './admin-auth.service';
import { ApiResponse } from '../../../utils/apiResponse';
import { AuthRequest } from '../../../middleware/auth';

export const adminAuthController = {
  async login(req: Request, res: Response, next: NextFunction) {
    try {
      const result = await adminAuthService.login(req.body);
      ApiResponse.success(res, {
        user: result.user,
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      }, 'Admin login successful');
    } catch (error) {
      next(error);
    }
  },

  async refresh(req: Request, res: Response, next: NextFunction) {
    try {
      const { refreshToken } = req.body;
      if (!refreshToken) {
        return ApiResponse.error(res, 'Refresh token required', 400);
      }
      const result = await adminAuthService.refresh(refreshToken);
      ApiResponse.success(res, result, 'Token refreshed');
    } catch (error) {
      next(error);
    }
  },

  async logout(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      await adminAuthService.logout(req.user!.id);
      ApiResponse.success(res, null, 'Logged out successfully');
    } catch (error) {
      next(error);
    }
  },

  async me(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const user = await adminAuthService.me(req.user!.id);
      ApiResponse.success(res, user);
    } catch (error) {
      next(error);
    }
  },
};
