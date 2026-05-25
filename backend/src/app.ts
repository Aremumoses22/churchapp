import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import compression from 'compression';
import cookieParser from 'cookie-parser';
import swaggerUi from 'swagger-ui-express';
import env from './config/env';
import { swaggerSpec } from './config/swagger';
import { errorHandler, notFoundHandler } from './middleware/errorHandler';
import { generalLimiter } from './middleware/rateLimiter';

// ── Route imports ───────────────────────────────────
import authRoutes from './modules/auth/auth.routes';
import usersRoutes from './modules/users/users.routes';
// Phase 2
import sermonsRoutes from './modules/sermons/sermons.routes';
import eventsRoutes from './modules/events/events.routes';
import bibleRoutes from './modules/bible/bible.routes';
import churchRoutes from './modules/church/church.routes';
import homeRoutes from './modules/home/home.routes';
// Phase 3
import givingRoutes from './modules/giving/giving.routes';
// Phase 4
import groupsRoutes from './modules/groups/groups.routes';
import communityRoutes from './modules/community/community.routes';
import forumRoutes from './modules/forum/forum.routes';
import prayerRoutes from './modules/prayer/prayer.routes';
// Phase 5
import chatRoutes from './modules/chat/chat.routes';
import notificationsRoutes from './modules/notifications/notifications.routes';
import liveRoutes from './modules/live/live.routes';
// Phase 6
import volunteerRoutes from './modules/volunteer/volunteer.routes';
import kidsRoutes from './modules/kids/kids.routes';
import mediaRoutes from './modules/media/media.routes';
import searchRoutes from './modules/search/search.routes';
// Phase 7
import attendanceRoutes from './modules/attendance/attendance.routes';
import milestonesRoutes from './modules/milestones/milestones.routes';
import savedItemsRoutes from './modules/saved-items/saved-items.routes';

// Admin dashboard
import adminRoutes from './modules/admin/admin.routes';
// Super admin
import superAdminRoutes from './modules/super-admin/super-admin.routes';

const app = express();

// ── Global middleware ───────────────────────────────
app.use(helmet());
app.use(cors({
  origin: env.corsOrigin === '*' ? true : env.corsOrigin,
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));
app.use(compression());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));
app.use(cookieParser());

// Logging
if (env.isDev) {
  app.use(morgan('dev'));
} else {
  app.use(morgan('combined'));
}

// ── Health check ────────────────────────────────────
app.get('/health', (_req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    version: env.apiVersion,
    environment: env.nodeEnv,
  });
});

// ── API Documentation (Swagger UI) ─────────────────
app.use('/api/docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec, {
  customCss: '.swagger-ui .topbar { display: none }',
  customSiteTitle: 'Church App API Docs',
}));
app.get('/api/docs.json', (_req, res) => {
  res.setHeader('Content-Type', 'application/json');
  res.send(swaggerSpec);
});

// ── API routes ──────────────────────────────────────
const apiPrefix = `/api/${env.apiVersion}`;

// ── Global rate limiter (100 req/min per IP) ────────
app.use(apiPrefix, generalLimiter);

app.use(`${apiPrefix}/auth`, authRoutes);
app.use(`${apiPrefix}/users`, usersRoutes);
// Phase 2
app.use(`${apiPrefix}/sermons`, sermonsRoutes);
app.use(`${apiPrefix}/events`, eventsRoutes);
app.use(`${apiPrefix}/bible`, bibleRoutes);
app.use(`${apiPrefix}/church`, churchRoutes);
app.use(`${apiPrefix}/home`, homeRoutes);
// Phase 3
app.use(`${apiPrefix}/giving`, givingRoutes);
// Phase 4
app.use(`${apiPrefix}/groups`, groupsRoutes);
app.use(`${apiPrefix}/community`, communityRoutes);
app.use(`${apiPrefix}/forum`, forumRoutes);
app.use(`${apiPrefix}/prayer-requests`, prayerRoutes);
// Phase 5
app.use(`${apiPrefix}/chat`, chatRoutes);
app.use(`${apiPrefix}/notifications`, notificationsRoutes);
app.use(`${apiPrefix}/live`, liveRoutes);

// Phase 6
app.use(`${apiPrefix}/volunteer`, volunteerRoutes);
app.use(`${apiPrefix}/kids`, kidsRoutes);
app.use(`${apiPrefix}/media`, mediaRoutes);
app.use(`${apiPrefix}/search`, searchRoutes);

// Phase 7
app.use(`${apiPrefix}/attendance`, attendanceRoutes);
app.use(`${apiPrefix}/milestones`, milestonesRoutes);
app.use(`${apiPrefix}/saved-items`, savedItemsRoutes);

// Admin dashboard
app.use(`${apiPrefix}/admin`, adminRoutes);
// Super admin (platform-level, SUPER_ADMIN role only)
app.use(`${apiPrefix}/super-admin`, superAdminRoutes);

// ── Error handling ──────────────────────────────────
app.use(notFoundHandler);
app.use(errorHandler);

export default app;
