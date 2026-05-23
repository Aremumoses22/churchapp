import { Router } from 'express';
import { analyticsController } from './analytics.controller';
import { authenticate } from '../../../middleware/auth';
import { requireAdmin } from '../middleware/requireAdmin';

const router = Router();

router.use(authenticate, requireAdmin);

router.get('/overview', analyticsController.overview);
router.get('/giving-trend', analyticsController.givingTrend);
router.get('/attendance-trend', analyticsController.attendanceTrend);
router.get('/membership-growth', analyticsController.membershipGrowth);
router.get('/engagement', analyticsController.engagement);

export default router;
