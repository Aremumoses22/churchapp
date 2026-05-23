import { Router } from 'express';
import adminAuthRoutes from './auth/admin-auth.routes';

const router = Router();

router.use('/auth', adminAuthRoutes);

// Phase 1+ sub-routers will be mounted here:
// router.use('/overview', adminOverviewRoutes);
// router.use('/members', adminMembersRoutes);
// router.use('/sermons', adminSermonsRoutes);
// router.use('/events', adminEventsRoutes);
// router.use('/giving', adminGivingRoutes);
// router.use('/groups', adminGroupsRoutes);
// router.use('/prayer', adminPrayerRoutes);
// router.use('/forum', adminForumRoutes);
// router.use('/media', adminMediaRoutes);
// router.use('/live', adminLiveRoutes);
// router.use('/notifications', adminNotificationsRoutes);
// router.use('/volunteer', adminVolunteerRoutes);
// router.use('/kids', adminKidsRoutes);
// router.use('/church', adminChurchRoutes);

export default router;
