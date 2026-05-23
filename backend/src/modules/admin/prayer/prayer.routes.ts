import { Router } from 'express';
import { prayerController } from './prayer.controller';
import { authenticate } from '../../../middleware/auth';
import { requireAdmin } from '../middleware/requireAdmin';

const router = Router();
router.use(authenticate, requireAdmin);

router.get('/', prayerController.list);
router.put('/:id/status', prayerController.updateStatus);
router.delete('/:id', prayerController.delete);

export default router;
