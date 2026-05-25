import { Router } from 'express';
import { authenticate } from '../../middleware/auth';
import { requireSuperAdmin } from '../admin/middleware/requireAdmin';
import { superAdminChurchController } from './churches.controller';

const router = Router();

// All super-admin routes require authentication + SUPER_ADMIN role
router.use(authenticate, requireSuperAdmin);

// ── Platform stats ────────────────────────────────────────────────────────────
router.get('/stats', superAdminChurchController.platformStats);

// ── Church CRUD ───────────────────────────────────────────────────────────────
router.get('/churches', superAdminChurchController.list);
router.post('/churches', superAdminChurchController.create);
router.get('/churches/:id', superAdminChurchController.getById);
router.put('/churches/:id', superAdminChurchController.update);
router.delete('/churches/:id', superAdminChurchController.delete);

// ── Church actions ────────────────────────────────────────────────────────────
router.post('/churches/:id/suspend', superAdminChurchController.suspend);
router.post('/churches/:id/unsuspend', superAdminChurchController.unsuspend);
router.post('/churches/:id/regenerate-code', superAdminChurchController.regenerateCode);

// ── Church members ────────────────────────────────────────────────────────────
router.get('/churches/:id/members', superAdminChurchController.listMembers);
router.delete('/churches/:id/members/:userId', superAdminChurchController.removeMember);

export default router;
