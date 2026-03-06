import { Request, Response, NextFunction } from 'express';
import { authService } from './auth.service';
import { ApiResponse } from '../../utils/apiResponse';
import { AuthRequest } from '../../middleware/auth';

export const authController = {
  // POST /auth/register
  async register(req: Request, res: Response, next: NextFunction) {
    try {
      const result = await authService.register(req.body);
      ApiResponse.created(res, result.user, result.message);
    } catch (error) {
      next(error);
    }
  },

  // POST /auth/login
  async login(req: Request, res: Response, next: NextFunction) {
    try {
      const result = await authService.login(req.body);
      ApiResponse.success(res, {
        user: result.user,
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      }, 'Login successful');
    } catch (error) {
      next(error);
    }
  },

  // GET /auth/verify-email/:token
  async verifyEmail(req: Request, res: Response, next: NextFunction) {
    try {
      const result = await authService.verifyEmail(req.params.token as string);
      ApiResponse.success(res, null, result.message);
    } catch (error) {
      next(error);
    }
  },

  // POST /auth/resend-verification
  async resendVerification(req: Request, res: Response, next: NextFunction) {
    try {
      const result = await authService.resendVerification(req.body.email);
      ApiResponse.success(res, null, result.message);
    } catch (error) {
      next(error);
    }
  },

  // POST /auth/forgot-password
  async forgotPassword(req: Request, res: Response, next: NextFunction) {
    try {
      const result = await authService.forgotPassword(req.body);
      ApiResponse.success(res, null, result.message);
    } catch (error) {
      next(error);
    }
  },

  // POST /auth/reset-password
  async resetPassword(req: Request, res: Response, next: NextFunction) {
    try {
      const result = await authService.resetPassword(req.body);
      ApiResponse.success(res, null, result.message);
    } catch (error) {
      next(error);
    }
  },

  // POST /auth/verify-church-code (protected)
  async verifyChurchCode(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const result = await authService.verifyChurchCode(req.user!.id, req.body);
      ApiResponse.success(res, result, 'Church code verified');
    } catch (error) {
      next(error);
    }
  },

  // POST /auth/complete-setup (protected)
  async completeSetup(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const result = await authService.completeSetup(req.user!.id, req.body);
      ApiResponse.success(res, result, 'Profile setup completed');
    } catch (error) {
      next(error);
    }
  },

  // POST /auth/refresh-token
  async refreshToken(req: Request, res: Response, next: NextFunction) {
    try {
      const result = await authService.refreshToken(req.body);
      ApiResponse.success(res, result, 'Token refreshed');
    } catch (error) {
      next(error);
    }
  },

  // POST /auth/logout (protected)
  async logout(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const fcmToken = typeof req.body.fcmToken === 'string' ? req.body.fcmToken : undefined;
      const result = await authService.logout(req.user!.id, fcmToken);
      ApiResponse.success(res, null, result.message);
    } catch (error) {
      next(error);
    }
  },

  // DELETE /auth/account (protected)
  async deleteAccount(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const result = await authService.deleteAccount(req.user!.id);
      ApiResponse.success(res, null, result.message);
    } catch (error) {
      next(error);
    }
  },
};
