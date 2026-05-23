'use client';

import { useQuery } from '@tanstack/react-query';
import { api } from '@/lib/api';

export interface OverviewStats {
  totalMembers: number;
  newMembersThisMonth: number;
  totalDonationsYTD: number;
  totalDonationsMTD: number;
  upcomingEvents: number;
  activePrayerRequests: number;
  activeGroups: number;
  liveServiceViewers: number;
}

export interface TrendPoint { month: string; total: number }
export interface AttendancePoint { week: string; count: number }
export interface GrowthPoint { month: string; newMembers: number }
export interface EngagementStats {
  sermonPlays: number;
  eventRegistrations: number;
  forumPosts: number;
  prayerInteractions: number;
  periodDays: number;
}

function extract<T>(res: { data: { data: T } }) { return res.data.data; }

export function useOverviewStats() {
  return useQuery<OverviewStats>({
    queryKey: ['analytics', 'overview'],
    queryFn: () => api.get('/analytics/overview').then(extract<OverviewStats>),
    staleTime: 2 * 60 * 1000,
  });
}

export function useGivingTrend() {
  return useQuery<TrendPoint[]>({
    queryKey: ['analytics', 'giving-trend'],
    queryFn: () => api.get('/analytics/giving-trend').then(extract<TrendPoint[]>),
    staleTime: 5 * 60 * 1000,
  });
}

export function useAttendanceTrend() {
  return useQuery<AttendancePoint[]>({
    queryKey: ['analytics', 'attendance-trend'],
    queryFn: () => api.get('/analytics/attendance-trend').then(extract<AttendancePoint[]>),
    staleTime: 5 * 60 * 1000,
  });
}

export function useMembershipGrowth() {
  return useQuery<GrowthPoint[]>({
    queryKey: ['analytics', 'membership-growth'],
    queryFn: () => api.get('/analytics/membership-growth').then(extract<GrowthPoint[]>),
    staleTime: 5 * 60 * 1000,
  });
}

export function useEngagement() {
  return useQuery<EngagementStats>({
    queryKey: ['analytics', 'engagement'],
    queryFn: () => api.get('/analytics/engagement').then(extract<EngagementStats>),
    staleTime: 5 * 60 * 1000,
  });
}
