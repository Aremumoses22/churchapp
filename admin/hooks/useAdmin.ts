'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useRouter } from 'next/navigation';
import { api } from '@/lib/api';
import { saveSession, clearSession, getStoredUser, type AdminUser } from '@/lib/auth';

export function useAdminUser() {
  return useQuery<AdminUser>({
    queryKey: ['admin', 'me'],
    queryFn: async () => {
      const { data } = await api.get('/auth/me');
      return data.data as AdminUser;
    },
    staleTime: 5 * 60 * 1000,
    retry: false,
    initialData: () => getStoredUser() ?? undefined,
  });
}

export function useAdminLogin() {
  const qc = useQueryClient();
  const router = useRouter();

  return useMutation({
    mutationFn: async (creds: { email: string; password: string }) => {
      const { data } = await api.post('/auth/login', creds);
      return data.data as { user: AdminUser; accessToken: string; refreshToken: string };
    },
    onSuccess: ({ user, accessToken, refreshToken }) => {
      saveSession(accessToken, refreshToken, user);
      qc.setQueryData(['admin', 'me'], user);
      router.replace('/');
    },
  });
}

export function useAdminLogout() {
  const qc = useQueryClient();
  const router = useRouter();

  return useMutation({
    mutationFn: async () => {
      await api.post('/auth/logout');
    },
    onSettled: () => {
      clearSession();
      qc.clear();
      router.replace('/login');
    },
  });
}
