import { Request, Response, NextFunction } from 'express';
import { ApiError } from '../utils/apiError';
import { logger } from '../utils/logger';
import env from '../config/env';

/**
 * Global error handler middleware
 * Must be the LAST middleware registered
 */
export function errorHandler(
  err: Error,
  _req: Request,
  res: Response,
  _next: NextFunction,
): void {
  // Log the error
  if (err instanceof ApiError && err.isOperational) {
    logger.warn(`${err.statusCode} - ${err.message}`);
  } else {
    logger.error('Unhandled error:', {
      message: err.message,
      stack: env.isDev ? err.stack : undefined,
    });
  }

  // Handle known ApiError
  if (err instanceof ApiError) {
    res.status(err.statusCode).json({
      success: false,
      message: err.message,
      ...(err.errors && { errors: err.errors }),
      ...(env.isDev && { stack: err.stack }),
    });
    return;
  }

  // Handle unknown errors
  res.status(500).json({
    success: false,
    message: env.isProd ? 'Internal server error' : err.message,
    ...(env.isDev && { stack: err.stack }),
  });
}

/**
 * 404 handler for unmatched routes
 */
export function notFoundHandler(req: Request, _res: Response, next: NextFunction): void {
  next(ApiError.notFound(`Route not found: ${req.method} ${req.originalUrl}`));
}
