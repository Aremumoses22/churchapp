'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { api } from '@/lib/api';

export interface VolunteerOpportunity {
  id: string;
  title: string;
  description: string | null;
  department: string;
  requirements: string | null;
  imageUrl: string | null;
  isActive: boolean;
  createdAt: string;
  _count?: { signups: number };
}

export interface VolunteerSignup {
  id: string;
  status: string;
  appliedAt: string;
  user: { id: string; name: string; email: string; avatarUrl: string | null; phone: string | null };
}

export const VOLUNTEER_DEPARTMENTS = ['Media', 'Worship', 'Ushering', 'Children', 'Technical', 'Hospitality', 'Security', 'Admin'];

export const SIGNUP_STATUSES = ['PENDING', 'APPROVED', 'REJECTED'];

export function useVolunteerOpportunities(params: { page: number; limit: number; search?: string; department?: string }) {
  return useQuery<{ opportunities: VolunteerOpportunity[]; total: number; page: number; limit: number; totalPages: number }>({
    queryKey: ['admin', 'volunteer-opportunities', params],
    queryFn: async () => {
      const res = await api.get('/volunteer', { params });
      const { data, meta } = res.data;
      return { opportunities: data, ...meta };
    },
  });
}

export function useCreateOpportunity() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: Omit<VolunteerOpportunity, 'id' | 'createdAt' | '_count'>) => api.post('/volunteer', data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'volunteer-opportunities'] }),
  });
}

export function useUpdateOpportunity() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, ...data }: Partial<VolunteerOpportunity> & { id: string }) => api.put(`/volunteer/${id}`, data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'volunteer-opportunities'] }),
  });
}

export function useDeleteOpportunity() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => api.delete(`/volunteer/${id}`),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'volunteer-opportunities'] }),
  });
}

export function useToggleOpportunityActive() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => api.put(`/volunteer/${id}/toggle-active`),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'volunteer-opportunities'] }),
  });
}

export function useOpportunitySignups(id: string) {
  return useQuery<VolunteerSignup[]>({
    queryKey: ['admin', 'volunteer-signups', id],
    queryFn: async () => (await api.get(`/volunteer/${id}/signups`)).data.data,
    enabled: !!id,
  });
}

export function useUpdateSignupStatus() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ signupId, status }: { signupId: string; status: string }) =>
      api.put(`/volunteer/signups/${signupId}/status`, { status }),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'volunteer-signups'] }),
  });
}
