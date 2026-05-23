export interface PaginationMeta {
  page: number;
  limit: number;
  total: number;
  totalPages: number;
}

export interface ApiResponse<T> {
  success: boolean;
  message: string;
  data: T;
  meta?: PaginationMeta;
}

export type UserRole = 'MEMBER' | 'LEADER' | 'PASTOR' | 'ADMIN' | 'SUPER_ADMIN';

export interface Member {
  id: string;
  name: string;
  email: string;
  role: UserRole;
  profileImage: string | null;
  isActive: boolean;
  isEmailVerified: boolean;
  churchId: string | null;
  createdAt: string;
}
