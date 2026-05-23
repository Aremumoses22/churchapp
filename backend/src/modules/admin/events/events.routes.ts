import { Router } from 'express';
import { eventsController } from './events.controller';
import { authenticate } from '../../../middleware/auth';
import { requireAdmin } from '../middleware/requireAdmin';

const router = Router();
router.use(authenticate, requireAdmin);

router.get('/', eventsController.list);
router.post('/', eventsController.create);
router.get('/:id', eventsController.getById);
router.put('/:id', eventsController.update);
router.delete('/:id', eventsController.delete);
router.put('/:id/featured', eventsController.toggleFeatured);
router.get('/:id/registrations', eventsController.listRegistrations);

export default router;
