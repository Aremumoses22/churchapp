'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { api } from '@/lib/api';

export interface PrayerRequest {
  id: string;
  title: string;
  content: string;
  isAnonymous: boolean;
  isUrgent: boolean;
  status: 'ACTIVE' | 'ANSWERED' | 'CLOSED';
  prayerCount: number;
  createdAt: string;
  user: { id: string; name: string; avatarUrl: string | null };
}

export function usePrayerRequests(params: { page: number; limit: number; search?: string; status?: string; urgent?: boolean }) {
  return useQuery<{ requests: PrayerRequest[]; total: number; page: number; limit: number; totalPages: number }>({
    queryKey: ['admin', 'prayer', params],
    queryFn: async () => {
      const res = await api.get('/prayer', { params: { ...params, urgent: params.urgent ? 'true' : undefined } });
      const { data, meta } = res.data;
      return { requests: data, ...meta };
    },
  });
}

export function useUpdatePrayerStatus() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, status }: { id: string; status: string }) =>
      api.put(`/prayer/${id}/status`, { status }),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'prayer'] }),
  });
}

export function useDeletePrayerRequest() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => api.delete(`/prayer/${id}`),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'prayer'] }),
  });
}
