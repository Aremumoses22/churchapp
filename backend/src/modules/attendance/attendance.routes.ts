import { Router } from 'express';
import { attendanceController } from './attendance.controller';
import { authenticate, authorize } from '../../middleware/auth';
import { validate } from '../../middleware/validate';
import { recordAttendanceSchema, listAttendanceSchema } from './attendance.validation';

const router = Router();

// All routes require authentication
router.use(authenticate);

// ── User endpoints ──────────────────────────────────
router.post('/', validate(recordAttendanceSchema), attendanceController.recordAttendance);
router.get('/', validate(listAttendanceSchema, 'query'), attendanceController.getHistory);
router.get('/streak', attendanceController.getStreak);
router.delete('/:id', attendanceController.deleteAttendance);

// ── Admin endpoints ─────────────────────────────────
router.get('/stats', authorize('ADMIN', 'PASTOR'), attendanceController.getStats);

export default router;
