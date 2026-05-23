'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { api } from '@/lib/api';

export interface AdminNotification {
  id: string;
  type: string;
  title: string;
  body: string;
  isRead: boolean;
  createdAt: string;
  user: { id: string; name: string; email: string };
}

export const NOTIFICATION_TYPES = ['SERMON', 'EVENT', 'GIVING', 'PRAYER', 'ANNOUNCEMENT', 'GROUP', 'FORUM', 'VOLUNTEER'];

export function useAdminNotifications(params: { page: number; limit: number }) {
  return useQuery<{ notifications: AdminNotification[]; total: number; page: number; limit: number; totalPages: number }>({
    queryKey: ['admin', 'notifications', params],
    queryFn: async () => {
      const res = await api.get('/notifications', { params });
      const { data, meta } = res.data;
      return { notifications: data, ...meta };
    },
  });
}

export function useSendNotificationToAll() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: { type: string; title: string; body: string; entityId?: string; entityType?: string }) =>
      api.post('/notifications/send-all', data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'notifications'] }),
  });
}

export function useDeleteAdminNotification() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => api.delete(`/notifications/${id}`),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'notifications'] }),
  });
}
