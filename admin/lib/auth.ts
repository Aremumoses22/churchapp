export const AUTH_KEYS = {
  accessToken: 'admin_access_token',
  refreshToken: 'admin_refresh_token',
  user: 'admin_user',
} as const;

export function saveSession(accessToken: string, refreshToken: string, user: AdminUser) {
  localStorage.setItem(AUTH_KEYS.accessToken, accessToken);
  localStorage.setItem(AUTH_KEYS.refreshToken, refreshToken);
  localStorage.setItem(AUTH_KEYS.user, JSON.stringify(user));
}

export function clearSession() {
  localStorage.removeItem(AUTH_KEYS.accessToken);
  localStorage.removeItem(AUTH_KEYS.refreshToken);
  localStorage.removeItem(AUTH_KEYS.user);
}

export function getStoredUser(): AdminUser | null {
  if (typeof window === 'undefined') return null;
  const raw = localStorage.getItem(AUTH_KEYS.user);
  if (!raw) return null;
  try { return JSON.parse(raw) as AdminUser; } catch { return null; }
}

export function isAuthenticated(): boolean {
  if (typeof window === 'undefined') return false;
  return !!localStorage.getItem(AUTH_KEYS.accessToken);
}

export interface AdminUser {
  id: string;
  name: string;
  email: string;
  role: 'ADMIN' | 'SUPER_ADMIN';
  avatarUrl: string | null;
  churchId: string | null;
  church: { id: string; name: string; code: string } | null;
}
