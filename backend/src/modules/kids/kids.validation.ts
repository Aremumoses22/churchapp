import { z } from 'zod/v4';

export const kidsValidation = {
  listChildren: z.object({
    query: z.object({
      page: z.coerce.number().int().positive().default(1).optional(),
      limit: z.coerce.number().int().positive().max(100).default(20).optional(),
    }),
  }),

  registerChild: z.object({
    body: z.object({
      firstName: z.string().min(1).max(100),
      lastName: z.string().min(1).max(100),
      dateOfBirth: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'Must be YYYY-MM-DD format'),
      allergies: z.string().max(2000).optional(),
      medicalNotes: z.string().max(2000).optional(),
      photoUrl: z.string().url().max(500).optional(),
    }),
  }),

  checkIn: z.object({
    body: z.object({
      childId: z.string().uuid(),
      roomId: z.string().uuid(),
    }),
  }),

  checkOut: z.object({
    body: z.object({
      checkInId: z.string().uuid(),
      securityCode: z.string().min(4).max(10),
    }),
  }),

  listRooms: z.object({
    query: z.object({
      page: z.coerce.number().int().positive().default(1).optional(),
      limit: z.coerce.number().int().positive().max(100).default(20).optional(),
    }),
  }),
};

export type ListChildrenInput = { page: number; limit: number };
export type RegisterChildInput = z.infer<typeof kidsValidation.registerChild>['body'];
export type CheckInInput = z.infer<typeof kidsValidation.checkIn>['body'];
export type CheckOutInput = z.infer<typeof kidsValidation.checkOut>['body'];
