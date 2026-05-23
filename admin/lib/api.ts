import axios from 'axios';

const BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8080/api/v1';

export const api = axios.create({
  baseURL: `${BASE_URL}/admin`,
  headers: { 'Content-Type': 'application/json' },
  withCredentials: false,
});

// Attach access token from localStorage on every request
api.interceptors.request.use((config) => {
  if (typeof window !== 'undefined') {
    const token = localStorage.getItem('admin_access_token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
  }
  return config;
});

// On 401 → try refresh; on failure → redirect to login
api.interceptors.response.use(
  (res) => res,
  async (error) => {
    const original = error.config;
    if (error.response?.status === 401 && !original._retry) {
      original._retry = true;
      try {
        const refreshToken = localStorage.getItem('admin_refresh_token');
        if (!refreshToken) throw new Error('no refresh token');

        const { data } = await axios.post(`${BASE_URL}/admin/auth/refresh`, { refreshToken });
        const newToken = data.data?.accessToken as string;
        localStorage.setItem('admin_access_token', newToken);
        original.headers.Authorization = `Bearer ${newToken}`;
        return api(original);
      } catch {
        localStorage.removeItem('admin_access_token');
        localStorage.removeItem('admin_refresh_token');
        window.location.href = '/login';
      }
    }
    return Promise.reject(error);
  },
);

// Non-admin API calls (same base but without /admin prefix)
export const publicApi = axios.create({
  baseURL: BASE_URL,
  headers: { 'Content-Type': 'application/json' },
});
