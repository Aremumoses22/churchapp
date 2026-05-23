import { Router } from 'express';
import { notificationsController } from './notifications.controller';
import { authenticate } from '../../../middleware/auth';
import { requireAdmin } from '../middleware/requireAdmin';

const router = Router();
router.use(authenticate, requireAdmin);

router.get('/', notificationsController.list);
router.post('/send-all', notificationsController.sendToAll);
router.delete('/:id', notificationsController.delete);

export default router;
