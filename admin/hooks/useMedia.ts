'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { api } from '@/lib/api';

// ── Types ─────────────────────────────────────────────────────
export interface PhotoAlbum {
  id: string;
  title: string;
  description: string | null;
  coverImageUrl: string | null;
  photoCount: number;
  _count?: { photos: number };
}

export interface Photo {
  id: string;
  imageUrl: string;
  caption: string | null;
  albumId: string;
}

export interface PodcastEpisode {
  id: string;
  title: string;
  description: string | null;
  audioUrl: string;
  duration: number;
  thumbnailUrl: string | null;
  publishedAt: string;
}

export interface WorshipSong {
  id: string;
  title: string;
  artist: string;
  key: string | null;
  tempo: number | null;
  tags: string[];
}

// ── Albums ────────────────────────────────────────────────────
export function useAlbums() {
  return useQuery<PhotoAlbum[]>({
    queryKey: ['admin', 'albums'],
    queryFn: async () => (await api.get('/media/albums')).data.data,
  });
}

export function useAlbumPhotos(albumId: string) {
  return useQuery<Photo[]>({
    queryKey: ['admin', 'albums', albumId, 'photos'],
    queryFn: async () => (await api.get(`/media/albums/${albumId}/photos`)).data.data,
    enabled: !!albumId,
  });
}

export function useCreateAlbum() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: Omit<PhotoAlbum, 'id' | 'photoCount' | '_count'>) =>
      api.post('/media/albums', data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'albums'] }),
  });
}

export function useUpdateAlbum() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, ...data }: Partial<PhotoAlbum> & { id: string }) =>
      api.put(`/media/albums/${id}`, data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'albums'] }),
  });
}

export function useDeleteAlbum() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => api.delete(`/media/albums/${id}`),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'albums'] }),
  });
}

export function useAddPhotos() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ albumId, photos }: { albumId: string; photos: { imageUrl: string; caption?: string }[] }) =>
      api.post(`/media/albums/${albumId}/photos`, { photos }),
    onSuccess: (_, vars) => {
      qc.invalidateQueries({ queryKey: ['admin', 'albums', vars.albumId, 'photos'] });
      qc.invalidateQueries({ queryKey: ['admin', 'albums'] });
    },
  });
}

export function useDeletePhoto() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ photoId, albumId }: { photoId: string; albumId: string }) =>
      api.delete(`/media/photos/${photoId}`),
    onSuccess: (_, vars) => {
      qc.invalidateQueries({ queryKey: ['admin', 'albums', vars.albumId, 'photos'] });
      qc.invalidateQueries({ queryKey: ['admin', 'albums'] });
    },
  });
}

// ── Podcasts ──────────────────────────────────────────────────
export function usePodcasts(params: { page: number; limit: number; search?: string }) {
  return useQuery<{ episodes: PodcastEpisode[]; total: number; page: number; limit: number; totalPages: number }>({
    queryKey: ['admin', 'podcasts', params],
    queryFn: async () => {
      const res = await api.get('/media/podcasts', { params });
      const { data, meta } = res.data;
      return { episodes: data, ...meta };
    },
  });
}

export function useCreatePodcast() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: Omit<PodcastEpisode, 'id'>) => api.post('/media/podcasts', data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'podcasts'] }),
  });
}

export function useUpdatePodcast() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, ...data }: Partial<PodcastEpisode> & { id: string }) =>
      api.put(`/media/podcasts/${id}`, data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'podcasts'] }),
  });
}

export function useDeletePodcast() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => api.delete(`/media/podcasts/${id}`),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'podcasts'] }),
  });
}

// ── Songs ─────────────────────────────────────────────────────
export function useSongs(params: { page: number; limit: number; search?: string }) {
  return useQuery<{ songs: WorshipSong[]; total: number; page: number; limit: number; totalPages: number }>({
    queryKey: ['admin', 'songs', params],
    queryFn: async () => {
      const res = await api.get('/media/songs', { params });
      const { data, meta } = res.data;
      return { songs: data, ...meta };
    },
  });
}

export function useCreateSong() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: Omit<WorshipSong, 'id'>) => api.post('/media/songs', data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'songs'] }),
  });
}

export function useUpdateSong() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, ...data }: Partial<WorshipSong> & { id: string }) =>
      api.put(`/media/songs/${id}`, data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'songs'] }),
  });
}

export function useDeleteSong() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => api.delete(`/media/songs/${id}`),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'songs'] }),
  });
}
