import { Router } from 'express';
import { forumController } from './forum.controller';
import { authenticate } from '../../../middleware/auth';
import { requireAdmin } from '../middleware/requireAdmin';

const router = Router();
router.use(authenticate, requireAdmin);

router.get('/categories', forumController.listCategories);
router.post('/categories', forumController.createCategory);
router.put('/categories/:id', forumController.updateCategory);
router.delete('/categories/:id', forumController.deleteCategory);

router.get('/threads', forumController.listThreads);
router.put('/threads/:id/pin', forumController.pinThread);
router.put('/threads/:id/lock', forumController.lockThread);
router.delete('/threads/:id', forumController.deleteThread);

export default router;
