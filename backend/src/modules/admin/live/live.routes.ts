import { Router } from 'express';
import { liveController } from './live.controller';
import { authenticate } from '../../../middleware/auth';
import { requireAdmin } from '../middleware/requireAdmin';

const router = Router();
router.use(authenticate, requireAdmin);

router.get('/', liveController.list);
router.post('/', liveController.create);
router.put('/:id', liveController.update);
router.delete('/:id', liveController.delete);
router.put('/:id/go-live', liveController.goLive);
router.put('/:id/end', liveController.endService);

export default router;
