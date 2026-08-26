import { Router } from 'express';
import { requireAdmin } from '../middleware/requireAdmin';
import { adminAnnouncementsController } from './announcements.controller';

const router = Router();

router.use(requireAdmin);

router.get('/', adminAnnouncementsController.list);
router.post('/', adminAnnouncementsController.create);
router.patch('/:id', adminAnnouncementsController.update);
router.delete('/:id', adminAnnouncementsController.delete);

export default router;
