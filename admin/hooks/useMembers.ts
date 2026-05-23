'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { api } from '@/lib/api';

export interface Member {
  id: string;
  name: string;
  email: string;
  role: string;
  avatarUrl: string | null;
  phone: string | null;
  bio: string | null;
  department: string | null;
  isActive: boolean;
  emailVerified: boolean;
  churchId: string | null;
  createdAt: string;
  church: { id: string; name: string } | null;
  _count?: { donations: number; eventRegistrations: number; groupMemberships: number };
}

export interface MembersPage {
  data: Member[];
  meta: { page: number; limit: number; total: number; totalPages: number };
}

function extract<T>(res: { data: T }) { return res.data; }

export function useMembers(params: { page?: number; limit?: number; search?: string; role?: string; status?: string }) {
  const sp = new URLSearchParams();
  if (params.page) sp.set('page', String(params.page));
  if (params.limit) sp.set('limit', String(params.limit));
  if (params.search) sp.set('search', params.search);
  if (params.role) sp.set('role', params.role);
  if (params.status) sp.set('status', params.status);

  return useQuery<MembersPage>({
    queryKey: ['members', params],
    queryFn: () => api.get(`/members?${sp}`).then(extract<MembersPage>),
  });
}

export function useMember(id: string) {
  return useQuery<Member>({
    queryKey: ['members', id],
    queryFn: () => api.get(`/members/${id}`).then((r) => r.data.data as Member),
    enabled: !!id,
  });
}

export function useUpdateMember() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, ...data }: Partial<Member> & { id: string }) =>
      api.put(`/members/${id}`, data).then((r) => r.data.data as Member),
    onSuccess: (updated) => {
      qc.invalidateQueries({ queryKey: ['members'] });
      qc.setQueryData(['members', updated.id], updated);
    },
  });
}

export function useChangeRole() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, role }: { id: string; role: string }) =>
      api.put(`/members/${id}/role`, { role }).then((r) => r.data.data as Member),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['members'] }),
  });
}

export function useSetMemberStatus() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, isActive }: { id: string; isActive: boolean }) =>
      api.put(`/members/${id}/status`, { isActive }).then((r) => r.data.data as Member),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['members'] }),
  });
}

export function useDeleteMember() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => api.delete(`/members/${id}`),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['members'] }),
  });
}

export function useMemberGivingHistory(id: string) {
  return useQuery({
    queryKey: ['members', id, 'giving-history'],
    queryFn: () => api.get(`/members/${id}/giving-history`).then((r) => r.data.data),
    enabled: !!id,
  });
}
