'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { api } from '@/lib/api';

// ── Types ─────────────────────────────────────────────────────
export interface ChurchInfo {
  id: string;
  name: string;
  tagline: string | null;
  mission: string | null;
  vision: string | null;
  description: string | null;
  phone: string | null;
  email: string | null;
  website: string | null;
  address: string | null;
  city: string | null;
  state: string | null;
  country: string | null;
  logoUrl: string | null;
  coverImageUrl: string | null;
  settings: Record<string, unknown> | null;
  staff: StaffMember[];
  campuses: Campus[];
  faqs: FAQ[];
  coreValues: CoreValue[];
}

export interface StaffMember {
  id: string;
  name: string;
  title: string;
  bio: string | null;
  imageUrl: string | null;
  email: string | null;
  phone: string | null;
  order: number;
}

export interface Campus {
  id: string;
  name: string;
  address: string | null;
  city: string | null;
  state: string | null;
  phone: string | null;
  email: string | null;
  isMain: boolean;
  serviceTimes: ServiceTime[];
}

export interface ServiceTime {
  id: string;
  day: string;
  time: string;
  label: string | null;
}

export interface FAQ {
  id: string;
  question: string;
  answer: string;
  order: number;
}

export interface CoreValue {
  id: string;
  title: string;
  description: string;
  icon: string | null;
  order: number;
}

// ── Church Info ───────────────────────────────────────────────
export function useChurchInfo() {
  return useQuery<ChurchInfo>({
    queryKey: ['admin', 'church'],
    queryFn: async () => (await api.get('/church')).data.data,
  });
}

export function useUpdateChurchInfo() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: Partial<ChurchInfo>) => api.put('/church', data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'church'] }),
  });
}

export function useUpdateLogo() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (logoUrl: string) => api.put('/church/logo', { logoUrl }),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'church'] }),
  });
}

export function useUpdateCoverImage() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (coverImageUrl: string) => api.put('/church/cover-image', { coverImageUrl }),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'church'] }),
  });
}

export function useUpdateTimeline() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: { foundedYear?: number; history?: string }) =>
      api.put('/church/timeline', data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'church'] }),
  });
}

// ── Staff ─────────────────────────────────────────────────────
export function useCreateStaff() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: Omit<StaffMember, 'id'>) => api.post('/church/staff', data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'church'] }),
  });
}

export function useUpdateStaff() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, ...data }: Partial<StaffMember> & { id: string }) =>
      api.put(`/church/staff/${id}`, data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'church'] }),
  });
}

export function useDeleteStaff() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => api.delete(`/church/staff/${id}`),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'church'] }),
  });
}

// ── Campuses ──────────────────────────────────────────────────
export function useCreateCampus() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: Omit<Campus, 'id' | 'serviceTimes'>) => api.post('/church/campuses', data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'church'] }),
  });
}

export function useUpdateCampus() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, ...data }: Partial<Campus> & { id: string }) =>
      api.put(`/church/campuses/${id}`, data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'church'] }),
  });
}

export function useDeleteCampus() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => api.delete(`/church/campuses/${id}`),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'church'] }),
  });
}

export function useUpsertServiceTimes() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ campusId, serviceTimes }: { campusId: string; serviceTimes: Omit<ServiceTime, 'id'>[] }) =>
      api.put(`/church/campuses/${campusId}/service-times`, { serviceTimes }),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'church'] }),
  });
}

// ── FAQs ──────────────────────────────────────────────────────
export function useCreateFaq() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: Omit<FAQ, 'id'>) => api.post('/church/faqs', data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'church'] }),
  });
}

export function useUpdateFaq() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, ...data }: Partial<FAQ> & { id: string }) =>
      api.put(`/church/faqs/${id}`, data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'church'] }),
  });
}

export function useDeleteFaq() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => api.delete(`/church/faqs/${id}`),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'church'] }),
  });
}

// ── Core Values ───────────────────────────────────────────────
export function useCreateCoreValue() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: Omit<CoreValue, 'id'>) => api.post('/church/core-values', data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'church'] }),
  });
}

export function useUpdateCoreValue() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, ...data }: Partial<CoreValue> & { id: string }) =>
      api.put(`/church/core-values/${id}`, data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'church'] }),
  });
}

export function useDeleteCoreValue() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => api.delete(`/church/core-values/${id}`),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'church'] }),
  });
}
