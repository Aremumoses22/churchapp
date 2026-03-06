import { Router } from 'express';
import { eventsController } from './events.controller';
import { authenticate, optionalAuth } from '../../middleware/auth';
import { validate } from '../../middleware/validate';
import { listEventsSchema, idParamSchema } from './events.validation';

const router = Router();

// ── Public / Optional Auth ──────────────────────────
router.get(
  '/',
  optionalAuth,
  validate(listEventsSchema, 'query'),
  eventsController.list,
);

router.get(
  '/featured',
  optionalAuth,
  eventsController.getFeatured,
);

router.get(
  '/my',
  authenticate,
  eventsController.getMyEvents,
);

router.get(
  '/:id',
  optionalAuth,
  validate(idParamSchema, 'params'),
  eventsController.getById,
);

// ── Protected ───────────────────────────────────────
router.post(
  '/:id/register',
  authenticate,
  validate(idParamSchema, 'params'),
  eventsController.register,
);

router.delete(
  '/:id/register',
  authenticate,
  validate(idParamSchema, 'params'),
  eventsController.cancelRegistration,
);

export default router;
