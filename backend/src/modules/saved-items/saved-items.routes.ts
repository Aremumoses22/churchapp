import { Router } from 'express';
import { savedItemsController } from './saved-items.controller';
import { authenticate } from '../../middleware/auth';
import { validate } from '../../middleware/validate';
import { saveItemSchema, listSavedItemsSchema } from './saved-items.validation';

const router = Router();

// All routes require authentication
router.use(authenticate);

// ── User endpoints ──────────────────────────────────
router.get('/', validate(listSavedItemsSchema, 'query'), savedItemsController.listSavedItems);
router.get('/check', savedItemsController.checkSaved);
router.post('/', validate(saveItemSchema), savedItemsController.saveItem);
router.delete('/:id', savedItemsController.removeSavedItem);

export default router;
