import { Router } from 'express';
import { volunteerController } from './volunteer.controller';
import { authenticate } from '../../../middleware/auth';
import { requireAdmin } from '../middleware/requireAdmin';

const router = Router();
router.use(authenticate, requireAdmin);

router.get('/', volunteerController.listOpportunities);
router.post('/', volunteerController.createOpportunity);
router.put('/:id', volunteerController.updateOpportunity);
router.delete('/:id', volunteerController.deleteOpportunity);
router.put('/:id/toggle-active', volunteerController.toggleActive);
router.get('/:id/signups', volunteerController.listSignups);
router.put('/signups/:signupId/status', volunteerController.updateSignupStatus);

export default router;
