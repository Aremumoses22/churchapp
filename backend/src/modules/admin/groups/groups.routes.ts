import { Router } from 'express';
import { groupsController } from './groups.controller';
import { authenticate } from '../../../middleware/auth';
import { requireAdmin } from '../middleware/requireAdmin';

const router = Router();
router.use(authenticate, requireAdmin);

router.get('/', groupsController.list);
router.post('/', groupsController.create);
router.get('/:id', groupsController.getById);
router.put('/:id', groupsController.update);
router.delete('/:id', groupsController.delete);
router.delete('/:id/members/:userId', groupsController.removeMember);

export default router;
