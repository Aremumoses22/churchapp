'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { api } from '@/lib/api';

export interface Group {
  id: string;
  name: string;
  description: string | null;
  category: string;
  meetingDay: string | null;
  meetingTime: string | null;
  location: string | null;
  leaderId: string | null;
  maxMembers: number | null;
  memberCount: number;
  isActive: boolean;
  imageUrl: string | null;
  leader: { id: string; name: string; email: string; avatarUrl: string | null } | null;
  _count?: { memberships: number };
}

export const GROUP_CATEGORIES = ['BIBLE_STUDY', 'YOUTH', 'WOMEN', 'MEN', 'COUPLES', 'PRAYER', 'SERVICE', 'OTHER'];

export function useGroups(params: { page: number; limit: number; search?: string; category?: string }) {
  return useQuery<{ groups: Group[]; total: number; page: number; limit: number; totalPages: number }>({
    queryKey: ['admin', 'groups', params],
    queryFn: async () => {
      const res = await api.get('/groups', { params });
      const { data, meta } = res.data;
      return { groups: data, ...meta };
    },
  });
}

export function useGroup(id: string) {
  return useQuery<Group & { memberships: { user: { id: string; name: string; email: string; avatarUrl: string | null } }[] }>({
    queryKey: ['admin', 'groups', id],
    queryFn: async () => (await api.get(`/groups/${id}`)).data.data,
    enabled: !!id,
  });
}

export function useCreateGroup() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: Omit<Group, 'id' | 'memberCount' | 'leader' | '_count'>) => api.post('/groups', data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'groups'] }),
  });
}

export function useUpdateGroup() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, ...data }: Partial<Group> & { id: string }) => api.put(`/groups/${id}`, data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'groups'] }),
  });
}

export function useDeleteGroup() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => api.delete(`/groups/${id}`),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'groups'] }),
  });
}

export function useRemoveGroupMember() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ groupId, userId }: { groupId: string; userId: string }) =>
      api.delete(`/groups/${groupId}/members/${userId}`),
    onSuccess: (_, vars) => qc.invalidateQueries({ queryKey: ['admin', 'groups', vars.groupId] }),
  });
}
