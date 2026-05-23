'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { api } from '@/lib/api';

export interface Event {
  id: string;
  title: string;
  description: string | null;
  category: string;
  imageUrl: string | null;
  location: string | null;
  startDate: string;
  endDate: string | null;
  registrationRequired: boolean;
  maxCapacity: number | null;
  registeredCount: number;
  isFeatured: boolean;
  tags: string[];
  _count?: { registrations: number };
}

export interface EventRegistration {
  id: string;
  status: string;
  registeredAt: string;
  user: { id: string; name: string; email: string; avatarUrl: string | null };
}

export function useEvents(params: { page: number; limit: number; search?: string; category?: string; upcoming?: boolean }) {
  return useQuery<{ events: Event[]; total: number; page: number; limit: number; totalPages: number }>({
    queryKey: ['admin', 'events', params],
    queryFn: async () => {
      const res = await api.get('/events', { params: { ...params, upcoming: params.upcoming ? 'true' : undefined } });
      const { data, meta } = res.data;
      return { events: data, ...meta };
    },
  });
}

export function useEvent(id: string) {
  return useQuery<Event>({
    queryKey: ['admin', 'events', id],
    queryFn: async () => (await api.get(`/events/${id}`)).data.data,
    enabled: !!id,
  });
}

export function useCreateEvent() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: Omit<Event, 'id' | 'registeredCount' | 'isFeatured' | '_count'>) => api.post('/events', data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'events'] }),
  });
}

export function useUpdateEvent() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, ...data }: Partial<Event> & { id: string }) => api.put(`/events/${id}`, data),
    onSuccess: (_, vars) => {
      qc.invalidateQueries({ queryKey: ['admin', 'events'] });
      qc.invalidateQueries({ queryKey: ['admin', 'events', vars.id] });
    },
  });
}

export function useDeleteEvent() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => api.delete(`/events/${id}`),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'events'] }),
  });
}

export function useToggleEventFeatured() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => api.put(`/events/${id}/featured`),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'events'] }),
  });
}

export function useEventRegistrations(eventId: string, page = 1, limit = 20) {
  return useQuery<{ registrations: EventRegistration[]; total: number; page: number; totalPages: number }>({
    queryKey: ['admin', 'events', eventId, 'registrations', page],
    queryFn: async () => {
      const res = await api.get(`/events/${eventId}/registrations`, { params: { page, limit } });
      const { data, meta } = res.data;
      return { registrations: data, ...meta };
    },
    enabled: !!eventId,
  });
}

export const EVENT_CATEGORIES = ['worship', 'conference', 'youth', 'prayer', 'outreach', 'fellowship'];
