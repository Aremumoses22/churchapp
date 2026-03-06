import type { Response, NextFunction } from 'express';
import { notificationService } from '../../services/notification.service';
import { ApiResponse } from '../../utils/apiResponse';
import { ApiError } from '../../utils/apiError';
import type { AuthRequest } from '../../middleware/auth';
import prisma from '../../config/database';

const param = (req: AuthRequest, name: string): string => req.params[name] as string;

export const notificationsController = {
  // GET /notifications
  async list(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const userId = req.user!.id;
      const { page, limit, type, unreadOnly } = req.query as any;

      const result = await notificationService.getUserNotifications(userId, {
        page: page ? parseInt(page) : 1,
        limit: limit ? parseInt(limit) : 20,
        type,
        unreadOnly: unreadOnly === 'true',
      });

      ApiResponse.paginated(res, result.notifications, result.meta);
    } catch (error) {
      next(error);
    }
  },

  // PUT /notifications/:id/read
  async markRead(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const userId = req.user!.id;
      const id = param(req, 'id');

      const notification = await notificationService.markAsRead(id, userId);
      ApiResponse.success(res, notification, 'Notification marked as read');
    } catch (error) {
      next(error);
    }
  },

  // PUT /notifications/read-all
  async markAllRead(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const userId = req.user!.id;
      await notificationService.markAllAsRead(userId);
      ApiResponse.success(res, null, 'All notifications marked as read');
    } catch (error) {
      next(error);
    }
  },

  // GET /notifications/unread-count
  async unreadCount(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const userId = req.user!.id;
      const count = await notificationService.getUnreadCount(userId);
      ApiResponse.success(res, { count });
    } catch (error) {
      next(error);
    }
  },

  // DELETE /notifications/:id
  async remove(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const userId = req.user!.id;
      const id = param(req, 'id');

      await prisma.notification.delete({
        where: { id, userId },
      });

      ApiResponse.success(res, null, 'Notification deleted');
    } catch (error) {
      next(error);
    }
  },
};
