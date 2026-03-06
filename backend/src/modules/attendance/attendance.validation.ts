import { z } from 'zod';

// ── Record Attendance ───────────────────────────────
export const recordAttendanceSchema = z.object({
  serviceDate: z.coerce.date(),
  serviceType: z.enum(['SUNDAY', 'MIDWEEK', 'SPECIAL', 'YOUTH', 'PRAYER']).default('SUNDAY'),
  checkinMethod: z.enum(['MANUAL', 'QR', 'GEOFENCE']).default('MANUAL'),
  notes: z.string().max(500).optional(),
});

// ── List Attendance (query params) ──────────────────
export const listAttendanceSchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  startDate: z.coerce.date().optional(),
  endDate: z.coerce.date().optional(),
  serviceType: z.enum(['SUNDAY', 'MIDWEEK', 'SPECIAL', 'YOUTH', 'PRAYER']).optional(),
});

export type RecordAttendanceInput = z.infer<typeof recordAttendanceSchema>;
export type ListAttendanceInput = z.infer<typeof listAttendanceSchema>;
