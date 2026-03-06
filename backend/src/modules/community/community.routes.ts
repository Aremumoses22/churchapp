import { Router } from 'express';
import { authenticate } from '../../middleware/auth';
import { validate } from '../../middleware/validate';
import { listAnnouncementsSchema, idParamSchema } from './community.validation';
import * as communityCtrl from './community.controller';

const router = Router();

// ── Announcements ───────────────────────────────────
router.get('/announcements', authenticate, validate(listAnnouncementsSchema), communityCtrl.getAnnouncements);
router.get('/announcements/:id', authenticate, validate(idParamSchema), communityCtrl.getAnnouncementById);
router.post('/announcements/:id/read', authenticate, validate(idParamSchema), communityCtrl.markAnnouncementRead);

// ── Testimonies ─────────────────────────────────────
router.get('/testimonies', authenticate, validate(listAnnouncementsSchema), communityCtrl.getTestimonies);
router.post('/testimonies', authenticate, communityCtrl.submitTestimony);
router.post('/testimonies/:id/react', authenticate, validate(idParamSchema), communityCtrl.reactToTestimony);

// ── Directory ───────────────────────────────────────
router.get('/directory', authenticate, validate(listAnnouncementsSchema), communityCtrl.getDirectory);

// ── Invites ─────────────────────────────────────────
router.post('/invite/generate', authenticate, communityCtrl.generateInviteLink);
router.get('/invite/stats', authenticate, communityCtrl.getInviteStats);
router.get('/invite/:code', communityCtrl.validateInviteLink); // Public

export default router;
