import { Router } from 'express';
import { adminAuthController } from './admin-auth.controller';
import { authenticate } from '../../../middleware/auth';
import { requireAdmin } from '../middleware/requireAdmin';
import { validate } from '../../../middleware/validate';
import { authLimiter } from '../../../middleware/rateLimiter';
import { adminLoginSchema } from './admin-auth.validation';

const router = Router();

router.post('/login', authLimiter, validate(adminLoginSchema), adminAuthController.login);
router.post('/refresh', authLimiter, adminAuthController.refresh);
router.post('/logout', authenticate, requireAdmin, adminAuthController.logout);
router.get('/me', authenticate, requireAdmin, adminAuthController.me);

export default router;
