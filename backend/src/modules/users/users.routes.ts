import { Router } from 'express';
import multer from 'multer';
import { usersController } from './users.controller';
import { authenticate } from '../../middleware/auth';
import { validate } from '../../middleware/validate';
import {
  updateProfileSchema,
  updateNotificationPrefsSchema,
  updateFcmTokenSchema,
} from './users.validation';

const router = Router();

// Multer config for avatar upload (5 MB max, images only)
const avatarUpload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 5 * 1024 * 1024 }, // 5 MB
  fileFilter: (_req, file, cb) => {
    if (file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('Only image files are allowed'));
    }
  },
});

// All routes are protected
router.use(authenticate);

// ── Profile ─────────────────────────────────────────
router.get('/me', usersController.getProfile);

router.put(
  '/me',
  validate(updateProfileSchema),
  usersController.updateProfile,
);

router.put(
  '/me/avatar',
  avatarUpload.single('avatar'),
  usersController.updateAvatar,
);

// ── Notification Preferences ────────────────────────
router.put(
  '/me/notification-prefs',
  validate(updateNotificationPrefsSchema),
  usersController.updateNotificationPrefs,
);

// ── FCM Token ───────────────────────────────────────
router.put(
  '/me/fcm-token',
  validate(updateFcmTokenSchema),
  usersController.updateFcmToken,
);

// ── Profile Sub-data (placeholders for later phases) ─
router.get('/me/attendance', usersController.getAttendance);
router.get('/me/milestones', usersController.getMilestones);
router.get('/me/saved-items', usersController.getSavedItems);
router.post('/me/saved-items', usersController.addSavedItem);
router.delete('/me/saved-items/:id', usersController.removeSavedItem);

export default router;
