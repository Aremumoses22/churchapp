import { Router } from 'express';
import { notificationsController } from './notifications.controller';
import { authenticate } from '../../middleware/auth';
import { validate } from '../../middleware/validate';
import { notificationsValidation } from './notifications.validation';

const router = Router();

// All notification routes require authentication
router.use(authenticate);

// GET /notifications — list user notifications (paginated)
router.get('/', validate(notificationsValidation.list), notificationsController.list);

// GET /notifications/unread-count — get unread count
router.get('/unread-count', notificationsController.unreadCount);

// PUT /notifications/read-all — mark all as read
router.put('/read-all', notificationsController.markAllRead);

// PUT /notifications/:id/read — mark single as read
router.put('/:id/read', validate(notificationsValidation.markRead), notificationsController.markRead);

// DELETE /notifications/:id — delete a notification
router.delete('/:id', validate(notificationsValidation.delete), notificationsController.remove);

export default router;
