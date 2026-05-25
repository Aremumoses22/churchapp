'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import axios from 'axios';

// ─────────────────────────────────────────────────────────────────────────────
// Super-admin API client (hits /super-admin/* instead of /admin/*)
// ─────────────────────────────────────────────────────────────────────────────
const BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8080/api/v1';

export const saApi = axios.create({
  baseURL: `${BASE_URL}/super-admin`,
  headers: { 'Content-Type': 'application/json' },
});

saApi.interceptors.request.use((config) => {
  if (typeof window !== 'undefined') {
    const token = localStorage.getItem('admin_access_token');
    if (token) config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// ─────────────────────────────────────────────────────────────────────────────
// Types
// ─────────────────────────────────────────────────────────────────────────────

export interface ChurchSummary {
  id: string;
  name: string;
  tagline: string | null;
  code: string;
  email: string | null;
  phone: string | null;
  address: string | null;
  website: string | null;
  logoUrl: string | null;
  isActive: boolean;
  suspendedAt: string | null;
  suspendReason: string | null;
  createdAt: string;
  updatedAt: string;
  _count: { users: number; sermons: number; events: number };
}

export interface ChurchAdmin {
  id: string;
  name: string;
  email: string;
  role: string;
  isActive: boolean;
  avatarUrl: string | null;
  createdAt: string;
}

export interface ChurchDetail extends ChurchSummary {
  mission: string | null;
  vision: string | null;
  socialLinks: Record<string, string>;
  settings: Record<string, unknown>;
  users: ChurchAdmin[];
  campuses: { id: string; name: string; address: string; isPrimary: boolean }[];
}

export interface ChurchMember {
  id: string;
  name: string;
  email: string;
  role: string;
  isActive: boolean;
  avatarUrl: string | null;
  department: string | null;
  createdAt: string;
}

export interface PlatformStats {
  totalChurches: number;
  activeChurches: number;
  suspendedChurches: number;
  totalUsers: number;
  newChurchesThisMonth: number;
}

export interface CreateChurchInput {
  name: string;
  tagline?: string;
  email?: string;
  phone?: string;
  address?: string;
  website?: string;
  adminName: string;
  adminEmail: string;
  adminPassword: string;
}

export interface UpdateChurchInput {
  name?: string;
  tagline?: string;
  email?: string;
  phone?: string;
  address?: string;
  website?: string;
  mission?: string;
  vision?: string;
}

// ─────────────────────────────────────────────────────────────────────────────
// Hooks
// ─────────────────────────────────────────────────────────────────────────────

export function usePlatformStats() {
  return useQuery<PlatformStats>({
    queryKey: ['super-admin', 'stats'],
    queryFn: async () => {
      const { data } = await saApi.get('/stats');
      return data.data as PlatformStats;
    },
    staleTime: 30_000,
  });
}

export function useChurches(params: {
  page?: number; limit?: number; search?: string; status?: string;
}) {
  return useQuery({
    queryKey: ['super-admin', 'churches', params],
    queryFn: async () => {
      const { data } = await saApi.get('/churches', { params });
      return data as { data: ChurchSummary[]; meta: { page: number; limit: number; total: number; totalPages: number } };
    },
    staleTime: 10_000,
  });
}

export function useChurchDetail(id: string | null) {
  return useQuery<ChurchDetail>({
    queryKey: ['super-admin', 'churches', id],
    queryFn: async () => {
      const { data } = await saApi.get(`/churches/${id}`);
      return data.data as ChurchDetail;
    },
    enabled: !!id,
  });
}

export function useChurchMembers(churchId: string | null, params: {
  page?: number; limit?: number; search?: string; role?: string;
}) {
  return useQuery({
    queryKey: ['super-admin', 'churches', churchId, 'members', params],
    queryFn: async () => {
      const { data } = await saApi.get(`/churches/${churchId}/members`, { params });
      return data as { data: ChurchMember[]; meta: { total: number; totalPages: number; page: number; limit: number } };
    },
    enabled: !!churchId,
  });
}

export function useCreateChurch() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async (input: CreateChurchInput) => {
      const { data } = await saApi.post('/churches', input);
      return data.data as ChurchSummary;
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: ['super-admin', 'churches'] }),
  });
}

export function useUpdateChurch() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, ...input }: UpdateChurchInput & { id: string }) => {
      const { data } = await saApi.put(`/churches/${id}`, input);
      return data.data as ChurchSummary;
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: ['super-admin', 'churches'] }),
  });
}

export function useSuspendChurch() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, reason }: { id: string; reason: string }) => {
      const { data } = await saApi.post(`/churches/${id}/suspend`, { reason });
      return data.data as ChurchSummary;
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: ['super-admin', 'churches'] }),
  });
}

export function useUnsuspendChurch() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async (id: string) => {
      const { data } = await saApi.post(`/churches/${id}/unsuspend`);
      return data.data as ChurchSummary;
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: ['super-admin', 'churches'] }),
  });
}

export function useRegenerateChurchCode() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async (id: string) => {
      const { data } = await saApi.post(`/churches/${id}/regenerate-code`);
      return data.data as ChurchSummary;
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: ['super-admin', 'churches'] }),
  });
}

export function useDeleteChurch() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async (id: string) => {
      await saApi.delete(`/churches/${id}`);
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: ['super-admin', 'churches'] }),
  });
}

export function useRemoveChurchMember() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async ({ churchId, userId }: { churchId: string; userId: string }) => {
      await saApi.delete(`/churches/${churchId}/members/${userId}`);
    },
    onSuccess: (_d, { churchId }) =>
      qc.invalidateQueries({ queryKey: ['super-admin', 'churches', churchId, 'members'] }),
  });
}
