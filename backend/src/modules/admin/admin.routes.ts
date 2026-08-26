import { Router } from 'express';
import adminAuthRoutes from './auth/admin-auth.routes';
import analyticsRoutes from './analytics/analytics.routes';
import membersRoutes from './members/members.routes';
import churchRoutes from './church/church.routes';
import sermonsRoutes from './sermons/sermons.routes';
import mediaRoutes from './media/media.routes';
import eventsRoutes from './events/events.routes';
import givingRoutes from './giving/giving.routes';
import groupsRoutes from './groups/groups.routes';
import prayerRoutes from './prayer/prayer.routes';
import liveRoutes from './live/live.routes';
import forumRoutes from './forum/forum.routes';
import notificationsRoutes from './notifications/notifications.routes';
import kidsRoutes from './kids/kids.routes';
import volunteerRoutes from './volunteer/volunteer.routes';
import announcementsRoutes from './announcements/announcements.routes';

const router = Router();

router.use('/auth', adminAuthRoutes);
router.use('/analytics', analyticsRoutes);
router.use('/members', membersRoutes);
router.use('/church', churchRoutes);
router.use('/sermons', sermonsRoutes);
router.use('/media', mediaRoutes);
router.use('/events', eventsRoutes);
router.use('/giving', givingRoutes);
router.use('/groups', groupsRoutes);
router.use('/prayer', prayerRoutes);
router.use('/live', liveRoutes);
router.use('/forum', forumRoutes);
router.use('/notifications', notificationsRoutes);
router.use('/kids', kidsRoutes);
router.use('/volunteer', volunteerRoutes);
router.use('/announcements', announcementsRoutes);

export default router;
