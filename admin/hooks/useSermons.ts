'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { api } from '@/lib/api';

// ── Types ─────────────────────────────────────────────────────
export interface SermonSeries {
  id: string;
  title: string;
  description: string | null;
  artworkUrl: string | null;
  startDate: string | null;
  endDate: string | null;
  _count?: { sermons: number };
}

export interface Sermon {
  id: string;
  title: string;
  speaker: string;
  description: string | null;
  date: string;
  audioUrl: string | null;
  videoUrl: string | null;
  thumbnailUrl: string | null;
  scriptureRef: string | null;
  seriesId: string | null;
  series: { id: string; title: string } | null;
  tags: string[];
  isFeatured: boolean;
  viewCount: number;
}

export interface SermonListResult {
  sermons: Sermon[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}

// ── Series ────────────────────────────────────────────────────
export function useSermonSeries() {
  return useQuery<SermonSeries[]>({
    queryKey: ['admin', 'sermon-series'],
    queryFn: async () => (await api.get('/sermons/series')).data.data,
  });
}

export function useCreateSeries() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: Omit<SermonSeries, 'id' | '_count'>) => api.post('/sermons/series', data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'sermon-series'] }),
  });
}

export function useUpdateSeries() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, ...data }: Partial<SermonSeries> & { id: string }) =>
      api.put(`/sermons/series/${id}`, data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'sermon-series'] }),
  });
}

export function useDeleteSeries() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => api.delete(`/sermons/series/${id}`),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'sermon-series'] }),
  });
}

// ── Sermons ───────────────────────────────────────────────────
export function useSermons(params: { page: number; limit: number; search?: string; seriesId?: string }) {
  return useQuery<SermonListResult>({
    queryKey: ['admin', 'sermons', params],
    queryFn: async () => {
      const res = await api.get('/sermons', { params });
      const { data, meta } = res.data;
      return { sermons: data, ...meta };
    },
  });
}

export function useSermon(id: string) {
  return useQuery<Sermon>({
    queryKey: ['admin', 'sermons', id],
    queryFn: async () => (await api.get(`/sermons/${id}`)).data.data,
    enabled: !!id,
  });
}

export function useCreateSermon() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: Omit<Sermon, 'id' | 'series' | 'isFeatured' | 'viewCount'>) =>
      api.post('/sermons', data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'sermons'] }),
  });
}

export function useUpdateSermon() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, ...data }: Partial<Sermon> & { id: string }) =>
      api.put(`/sermons/${id}`, data),
    onSuccess: (_, vars) => {
      qc.invalidateQueries({ queryKey: ['admin', 'sermons'] });
      qc.invalidateQueries({ queryKey: ['admin', 'sermons', vars.id] });
    },
  });
}

export function useDeleteSermon() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => api.delete(`/sermons/${id}`),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'sermons'] }),
  });
}

export function useToggleFeatured() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => api.put(`/sermons/${id}/featured`),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'sermons'] }),
  });
}
