'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { api } from '@/lib/api';

export interface Room {
  id: string;
  name: string;
  ageGroup: string;
  capacity: number;
  currentCount: number;
  createdAt: string;
}

export interface Child {
  id: string;
  firstName: string;
  lastName: string;
  dateOfBirth: string;
  allergies: string | null;
  medicalNotes: string | null;
  photoUrl: string | null;
  parent: { id: string; name: string; email: string; phone: string | null };
}

export interface CheckIn {
  id: string;
  securityCode: string;
  status: string;
  checkedInAt: string;
  checkedOutAt: string | null;
  child: { id: string; firstName: string; lastName: string };
  room: { id: string; name: string };
  parent: { id: string; name: string; phone: string | null };
}

export function useKidsRooms() {
  return useQuery<Room[]>({
    queryKey: ['admin', 'kids-rooms'],
    queryFn: async () => (await api.get('/kids/rooms')).data.data,
  });
}

export function useCreateRoom() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: { name: string; ageGroup: string; capacity: number }) => api.post('/kids/rooms', data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'kids-rooms'] }),
  });
}

export function useUpdateRoom() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, ...data }: Partial<Room> & { id: string }) => api.put(`/kids/rooms/${id}`, data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'kids-rooms'] }),
  });
}

export function useDeleteRoom() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => api.delete(`/kids/rooms/${id}`),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'kids-rooms'] }),
  });
}

export function useKidsChildren(params: { page: number; limit: number; search?: string }) {
  return useQuery<{ children: Child[]; total: number; page: number; limit: number; totalPages: number }>({
    queryKey: ['admin', 'kids-children', params],
    queryFn: async () => {
      const res = await api.get('/kids/children', { params });
      const { data, meta } = res.data;
      return { children: data, ...meta };
    },
  });
}

export function useTodayCheckins() {
  return useQuery<CheckIn[]>({
    queryKey: ['admin', 'kids-checkins-today'],
    queryFn: async () => (await api.get('/kids/checkins/today')).data.data,
    refetchInterval: 30000,
  });
}

export function useCheckinHistory(params: { page: number; limit: number; roomId?: string }) {
  return useQuery<{ checkins: CheckIn[]; total: number; page: number; limit: number; totalPages: number }>({
    queryKey: ['admin', 'kids-checkins-history', params],
    queryFn: async () => {
      const res = await api.get('/kids/checkins/history', { params });
      const { data, meta } = res.data;
      return { checkins: data, ...meta };
    },
  });
}
