import { z } from 'zod';

// ── Contact Form ────────────────────────────────────
export const contactFormSchema = z.object({
  subject: z.string().min(2, 'Subject is required').max(255),
  message: z.string().min(10, 'Message must be at least 10 characters').max(5000),
  category: z.enum(['general', 'prayer', 'feedback', 'support', 'other']).default('general'),
});

// ── Types ───────────────────────────────────────────
export type ContactFormInput = z.infer<typeof contactFormSchema>;
