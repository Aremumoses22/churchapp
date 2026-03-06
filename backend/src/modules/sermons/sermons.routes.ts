import { Router } from 'express';
import { sermonsController } from './sermons.controller';
import { authenticate, optionalAuth } from '../../middleware/auth';
import { validate } from '../../middleware/validate';
import {
  listSermonsSchema,
  saveProgressSchema,
  saveNotesSchema,
  idParamSchema,
} from './sermons.validation';

const router = Router();

// ── Public / Optional Auth ──────────────────────────
router.get(
  '/',
  optionalAuth,
  validate(listSermonsSchema, 'query'),
  sermonsController.list,
);

router.get(
  '/featured',
  optionalAuth,
  sermonsController.getFeatured,
);

router.get(
  '/saved',
  authenticate,
  sermonsController.getSaved,
);

router.get(
  '/:id',
  optionalAuth,
  validate(idParamSchema, 'params'),
  sermonsController.getById,
);

router.get(
  '/:id/stream',
  authenticate,
  validate(idParamSchema, 'params'),
  sermonsController.getStreamUrl,
);

// ── Protected ───────────────────────────────────────
router.post(
  '/:id/progress',
  authenticate,
  validate(idParamSchema, 'params'),
  validate(saveProgressSchema),
  sermonsController.saveProgress,
);

router.post(
  '/:id/save',
  authenticate,
  validate(idParamSchema, 'params'),
  sermonsController.toggleSave,
);

router.get(
  '/:id/notes',
  authenticate,
  validate(idParamSchema, 'params'),
  sermonsController.getNotes,
);

router.put(
  '/:id/notes',
  authenticate,
  validate(idParamSchema, 'params'),
  validate(saveNotesSchema),
  sermonsController.saveNotes,
);

// ── Series routes ───────────────────────────────────
router.get(
  '/series/all',
  optionalAuth,
  sermonsController.listSeries,
);

router.get(
  '/series/:id',
  optionalAuth,
  validate(idParamSchema, 'params'),
  sermonsController.getSeriesById,
);

export default router;
