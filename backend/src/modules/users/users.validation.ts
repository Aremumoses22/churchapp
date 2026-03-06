import { z } from 'zod';

// ── Update Profile ──────────────────────────────────
export const updateProfileSchema = z.object({
  name: z.string().min(2).max(255).optional(),
  phone: z.string().max(20).optional().nullable(),
  bio: z.string().max(1000).optional().nullable(),
  department: z.string().max(100).optional().nullable(),
  isDirectoryVisible: z.boolean().optional(),
});

// ── Update Notification Preferences ─────────────────
export const updateNotificationPrefsSchema = z.object({
  pushEnabled: z.boolean().optional(),
  emailEnabled: z.boolean().optional(),
  sermons: z.boolean().optional(),
  events: z.boolean().optional(),
  live: z.boolean().optional(),
  chat: z.boolean().optional(),
  giving: z.boolean().optional(),
  prayer: z.boolean().optional(),
  announcements: z.boolean().optional(),
  groups: z.boolean().optional(),
  forum: z.boolean().optional(),
  volunteering: z.boolean().optional(),
  devotionals: z.boolean().optional(),
  quietHoursEnabled: z.boolean().optional(),
  quietHoursStart: z.string().max(5).optional(),  // "22:00"
  quietHoursEnd: z.string().max(5).optional(),     // "07:00"
});

// ── Update FCM Token ────────────────────────────────
export const updateFcmTokenSchema = z.object({
  fcmToken: z.string().min(1, 'FCM token is required'),
});

// ── Types ───────────────────────────────────────────
export type UpdateProfileInput = z.infer<typeof updateProfileSchema>;
export type UpdateNotificationPrefsInput = z.infer<typeof updateNotificationPrefsSchema>;
export type UpdateFcmTokenInput = z.infer<typeof updateFcmTokenSchema>;
