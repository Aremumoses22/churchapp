import { Router } from 'express';
import { liveController } from './live.controller';
import { authenticate } from '../../middleware/auth';
import { validate } from '../../middleware/validate';
import { liveValidation } from './live.validation';

const router = Router();

// All live routes require authentication
router.use(authenticate);

// GET /live — list live services (paginated, filter by status)
router.get('/', validate(liveValidation.list), liveController.list);

// GET /live/current — get current live service (or upcoming)
router.get('/current', liveController.getCurrent);

// GET /live/:id — get live service detail
router.get('/:id', validate(liveValidation.getById), liveController.getById);

// GET /live/:id/chat — get chat messages for live service
router.get('/:id/chat', validate(liveValidation.getChatMessages), liveController.getChatMessages);

export default router;
