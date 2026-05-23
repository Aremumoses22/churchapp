'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { api } from '@/lib/api';

export interface LiveService {
  id: string;
  title: string;
  description: string | null;
  streamUrl: string | null;
  status: 'SCHEDULED' | 'LIVE' | 'ENDED';
  scheduledAt: string;
  startedAt: string | null;
  endedAt: string | null;
  viewerCount: number;
}

export function useLiveServices(params: { page: number; limit: number; status?: string }) {
  return useQuery<{ services: LiveService[]; total: number; page: number; limit: number; totalPages: number }>({
    queryKey: ['admin', 'live', params],
    queryFn: async () => {
      const res = await api.get('/live', { params });
      const { data, meta } = res.data;
      return { services: data, ...meta };
    },
  });
}

export function useCreateLiveService() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: { title: string; description?: string; streamUrl?: string; scheduledAt: string }) =>
      api.post('/live', data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'live'] }),
  });
}

export function useUpdateLiveService() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, ...data }: Partial<LiveService> & { id: string }) => api.put(`/live/${id}`, data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'live'] }),
  });
}

export function useDeleteLiveService() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => api.delete(`/live/${id}`),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'live'] }),
  });
}

export function useGoLive() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => api.put(`/live/${id}/go-live`),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'live'] }),
  });
}

export function useEndLiveService() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => api.put(`/live/${id}/end`),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'live'] }),
  });
}
