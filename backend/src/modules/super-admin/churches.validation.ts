import { z } from 'zod';

export const createChurchSchema = z.object({
  name: z.string().min(2).max(255),
  tagline: z.string().max(500).optional(),
  email: z.string().email().optional(),
  phone: z.string().max(20).optional(),
  address: z.string().optional(),
  website: z.string().url().optional().or(z.literal('')),
  // Admin account
  adminName: z.string().min(2).max(255),
  adminEmail: z.string().email(),
  adminPassword: z.string().min(8).max(100),
});

export const updateChurchSchema = z.object({
  name: z.string().min(2).max(255).optional(),
  tagline: z.string().max(500).optional(),
  email: z.string().email().optional(),
  phone: z.string().max(20).optional(),
  address: z.string().optional(),
  website: z.string().url().optional().or(z.literal('')),
  mission: z.string().optional(),
  vision: z.string().optional(),
});

export const suspendChurchSchema = z.object({
  reason: z.string().min(5).max(500),
});

export type CreateChurchInput = z.infer<typeof createChurchSchema>;
export type UpdateChurchInput = z.infer<typeof updateChurchSchema>;
export type SuspendChurchInput = z.infer<typeof suspendChurchSchema>;
