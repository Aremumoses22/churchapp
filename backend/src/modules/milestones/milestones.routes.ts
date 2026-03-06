import { Router } from 'express';
import { milestonesController } from './milestones.controller';
import { authenticate, authorize } from '../../middleware/auth';
import { validate } from '../../middleware/validate';
import { listMilestonesSchema, createMilestoneSchema } from './milestones.validation';

const router = Router();

// All routes require authentication
router.use(authenticate);

// ── User endpoints ──────────────────────────────────
router.get('/', validate(listMilestonesSchema, 'query'), milestonesController.getUserMilestones);
router.get('/summary', milestonesController.getMilestoneSummary);

// ── Admin endpoints ─────────────────────────────────
router.post('/', authorize('ADMIN', 'PASTOR'), validate(createMilestoneSchema), milestonesController.createMilestone);
router.delete('/:id', authorize('ADMIN', 'PASTOR'), milestonesController.deleteMilestone);

export default router;
