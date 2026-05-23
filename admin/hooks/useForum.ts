'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { api } from '@/lib/api';

export interface ForumCategory {
  id: string;
  name: string;
  description: string | null;
  iconUrl: string | null;
  threadCount: number;
  sortOrder: number;
  _count?: { threads: number };
}

export interface ForumThread {
  id: string;
  title: string;
  content: string;
  isPinned: boolean;
  isLocked: boolean;
  viewCount: number;
  likeCount: number;
  replyCount: number;
  lastActivityAt: string;
  createdAt: string;
  author: { id: string; name: string; avatarUrl: string | null };
  category: { id: string; name: string };
}

export function useForumCategories() {
  return useQuery<ForumCategory[]>({
    queryKey: ['admin', 'forum-categories'],
    queryFn: async () => (await api.get('/forum/categories')).data.data,
  });
}

export function useCreateForumCategory() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: Omit<ForumCategory, 'id' | 'threadCount' | '_count'>) =>
      api.post('/forum/categories', data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'forum-categories'] }),
  });
}

export function useUpdateForumCategory() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, ...data }: Partial<ForumCategory> & { id: string }) =>
      api.put(`/forum/categories/${id}`, data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'forum-categories'] }),
  });
}

export function useDeleteForumCategory() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => api.delete(`/forum/categories/${id}`),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'forum-categories'] }),
  });
}

export function useForumThreads(params: { page: number; limit: number; search?: string; categoryId?: string }) {
  return useQuery<{ threads: ForumThread[]; total: number; page: number; limit: number; totalPages: number }>({
    queryKey: ['admin', 'forum-threads', params],
    queryFn: async () => {
      const res = await api.get('/forum/threads', { params });
      const { data, meta } = res.data;
      return { threads: data, ...meta };
    },
  });
}

export function usePinThread() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => api.put(`/forum/threads/${id}/pin`),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'forum-threads'] }),
  });
}

export function useLockThread() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => api.put(`/forum/threads/${id}/lock`),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'forum-threads'] }),
  });
}

export function useDeleteThread() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => api.delete(`/forum/threads/${id}`),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'forum-threads'] }),
  });
}
