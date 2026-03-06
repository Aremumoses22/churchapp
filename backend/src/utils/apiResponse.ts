import { Response } from 'express';

interface ApiResponseData<T> {
  success: boolean;
  message: string;
  data?: T;
  meta?: {
    page?: number;
    limit?: number;
    total?: number;
    totalPages?: number;
  };
}

/**
 * Standardized API response helper
 */
export class ApiResponse {
  static success<T>(res: Response, data?: T, message = 'Success', statusCode = 200) {
    const response: ApiResponseData<T> = {
      success: true,
      message,
      data,
    };
    return res.status(statusCode).json(response);
  }

  static created<T>(res: Response, data?: T, message = 'Created successfully') {
    return ApiResponse.success(res, data, message, 201);
  }

  static paginated<T>(
    res: Response,
    data: T[],
    totalOrMeta: number | { page: number; limit: number; total: number; totalPages: number },
    pageOrExtra?: number | Record<string, any>,
    limit?: number,
    message = 'Success',
  ) {
    let meta: { page: number; limit: number; total: number; totalPages: number };
    let extra: Record<string, any> | undefined;

    if (typeof totalOrMeta === 'object') {
      // New style: paginated(res, data, meta, extra?)
      meta = totalOrMeta;
      extra = pageOrExtra as Record<string, any> | undefined;
    } else {
      // Legacy style: paginated(res, data, total, page, limit)
      const total = totalOrMeta;
      const page = pageOrExtra as number;
      meta = { page, limit: limit!, total, totalPages: Math.ceil(total / (limit || 1)) };
    }

    const response: any = {
      success: true,
      message,
      data,
      meta,
      ...extra,
    };
    return res.status(200).json(response);
  }

  static error(
    res: Response,
    message = 'Something went wrong',
    statusCode = 500,
    errors?: Record<string, string[]>,
  ) {
    return res.status(statusCode).json({
      success: false,
      message,
      ...(errors && { errors }),
    });
  }
}
