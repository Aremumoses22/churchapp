import { Router } from 'express';
import { bibleController } from './bible.controller';
import { authenticate, optionalAuth } from '../../middleware/auth';
import { validate } from '../../middleware/validate';
import {
  chapterParamsSchema,
  bibleSearchSchema,
  addHighlightSchema,
  idParamSchema,
  dateParamSchema,
  listReadingPlansSchema,
  markDayCompleteSchema,
} from './bible.validation';

const router = Router();

// ═══════════════════════════════════════════════════
// BIBLE
// ═══════════════════════════════════════════════════

router.get('/books', bibleController.getBooks);

router.get('/search', validate(bibleSearchSchema, 'query'), bibleController.searchVerses);

router.get(
  '/highlights',
  authenticate,
  bibleController.getHighlights,
);

router.post(
  '/highlights',
  authenticate,
  validate(addHighlightSchema),
  bibleController.addHighlight,
);

router.delete(
  '/highlights/:id',
  authenticate,
  validate(idParamSchema, 'params'),
  bibleController.removeHighlight,
);

// ═══════════════════════════════════════════════════
// DEVOTIONALS (must be before /:bookId/:chapter)
// ═══════════════════════════════════════════════════

router.get(
  '/devotionals/today',
  authenticate,
  bibleController.getDevotionalToday,
);

router.get(
  '/devotionals/streak',
  authenticate,
  bibleController.getDevotionalStreak,
);

router.get(
  '/devotionals/:date',
  authenticate,
  validate(dateParamSchema, 'params'),
  bibleController.getDevotionalByDate,
);

router.post(
  '/devotionals/:id/read',
  authenticate,
  validate(idParamSchema, 'params'),
  bibleController.markDevotionalRead,
);

// ═══════════════════════════════════════════════════
// READING PLANS (must be before /:bookId/:chapter)
// ═══════════════════════════════════════════════════

router.get(
  '/reading-plans',
  optionalAuth,
  validate(listReadingPlansSchema, 'query'),
  bibleController.browseReadingPlans,
);

router.get(
  '/reading-plans/my',
  authenticate,
  bibleController.getMyReadingPlans,
);

router.get(
  '/reading-plans/:id',
  optionalAuth,
  validate(idParamSchema, 'params'),
  bibleController.getReadingPlanById,
);

router.post(
  '/reading-plans/:id/enroll',
  authenticate,
  validate(idParamSchema, 'params'),
  bibleController.enrollInPlan,
);

router.post(
  '/reading-plans/:id/progress',
  authenticate,
  validate(idParamSchema, 'params'),
  validate(markDayCompleteSchema),
  bibleController.markDayComplete,
);

// ═══════════════════════════════════════════════════
// CHAPTER (catch-all, must be LAST)
// ═══════════════════════════════════════════════════

router.get(
  '/:bookId/:chapter',
  optionalAuth,
  validate(chapterParamsSchema, 'params'),
  bibleController.getChapter,
);

export default router;
