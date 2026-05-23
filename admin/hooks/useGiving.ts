'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { api } from '@/lib/api';

export interface Donation {
  id: string;
  amount: number;
  currency: string;
  status: string;
  paymentMethod: string;
  transactionRef: string;
  isAnonymous: boolean;
  note: string | null;
  createdAt: string;
  user: { id: string; name: string; email: string; avatarUrl: string | null };
  category: { id: string; name: string } | null;
  campaign: { id: string; title: string } | null;
}

export interface DonationSummary {
  totalRaised: number;
  totalCount: number;
  thisMonth: number;
  pendingCount: number;
}

export interface GivingCategory {
  id: string;
  name: string;
  description: string | null;
  isActive: boolean;
  sortOrder: number;
}

export interface GivingCampaign {
  id: string;
  title: string;
  description: string | null;
  imageUrl: string | null;
  goalAmount: number;
  raisedAmount: number;
  donorCount: number;
  startDate: string;
  endDate: string | null;
  isActive: boolean;
  _count?: { donations: number };
}

// Donations
export function useDonations(params: { page: number; limit: number; search?: string; status?: string; categoryId?: string; campaignId?: string }) {
  return useQuery<{ donations: Donation[]; total: number; page: number; limit: number; totalPages: number }>({
    queryKey: ['admin', 'donations', params],
    queryFn: async () => {
      const res = await api.get('/giving/donations', { params });
      const { data, meta } = res.data;
      return { donations: data, ...meta };
    },
  });
}

export function useDonationSummary() {
  return useQuery<DonationSummary>({
    queryKey: ['admin', 'donations', 'summary'],
    queryFn: async () => (await api.get('/giving/donations/summary')).data.data,
  });
}

// Giving Categories
export function useGivingCategories() {
  return useQuery<GivingCategory[]>({
    queryKey: ['admin', 'giving-categories'],
    queryFn: async () => (await api.get('/giving/categories')).data.data,
  });
}

export function useCreateGivingCategory() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: Omit<GivingCategory, 'id'>) => api.post('/giving/categories', data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'giving-categories'] }),
  });
}

export function useUpdateGivingCategory() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, ...data }: Partial<GivingCategory> & { id: string }) => api.put(`/giving/categories/${id}`, data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'giving-categories'] }),
  });
}

export function useDeleteGivingCategory() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => api.delete(`/giving/categories/${id}`),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'giving-categories'] }),
  });
}

// Giving Campaigns
export function useGivingCampaigns() {
  return useQuery<GivingCampaign[]>({
    queryKey: ['admin', 'giving-campaigns'],
    queryFn: async () => (await api.get('/giving/campaigns')).data.data,
  });
}

export function useCreateGivingCampaign() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: Omit<GivingCampaign, 'id' | 'raisedAmount' | 'donorCount' | '_count'>) => api.post('/giving/campaigns', data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'giving-campaigns'] }),
  });
}

export function useUpdateGivingCampaign() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, ...data }: Partial<GivingCampaign> & { id: string }) => api.put(`/giving/campaigns/${id}`, data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'giving-campaigns'] }),
  });
}

export function useDeleteGivingCampaign() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => api.delete(`/giving/campaigns/${id}`),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin', 'giving-campaigns'] }),
  });
}
