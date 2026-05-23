import { z } from 'zod';

export const listMembersSchema = z.object({
  query: z.object({
    page: z.coerce.number().min(1).default(1),
    limit: z.coerce.number().min(1).max(100).default(20),
    search: z.string().optional(),
    role: z.enum(['MEMBER', 'LEADER', 'PASTOR', 'ADMIN', 'SUPER_ADMIN']).optional(),
    status: z.enum(['active', 'inactive']).optional(),
  }),
});

export const updateMemberSchema = z.object({
  name: z.string().min(2).max(255).optional(),
  phone: z.string().max(20).optional(),
  bio: z.string().max(2000).optional(),
  department: z.string().max(100).optional(),
});

export const changeRoleSchema = z.object({
  role: z.enum(['MEMBER', 'LEADER', 'PASTOR', 'ADMIN', 'SUPER_ADMIN']),
});

export const changeStatusSchema = z.object({
  isActive: z.boolean(),
});

export const inviteMemberSchema = z.object({
  email: z.string().email(),
  name: z.string().min(2).max(255),
  role: z.enum(['MEMBER', 'LEADER', 'PASTOR']).default('MEMBER'),
});

export type InviteMemberInput = z.infer<typeof inviteMemberSchema>;
