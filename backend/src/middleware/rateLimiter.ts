import { Request, Response, NextFunction } from 'express';
import { getRedis } from '../config/redis';
import { ApiError } from '../utils/apiError';

interface RateLimitOptions {
  windowMs: number;      // Time window in milliseconds
  maxRequests: number;   // Max requests per window
  keyPrefix?: string;    // Redis key prefix
}

/**
 * Rate limiter middleware using Redis sliding window
 */
export function rateLimiter(options: RateLimitOptions) {
  const { windowMs, maxRequests, keyPrefix = 'rl' } = options;

  return async (req: Request, _res: Response, next: NextFunction): Promise<void> => {
    try {
      const redis = getRedis();
      const ip = req.ip || req.socket.remoteAddress || 'unknown';
      const key = `${keyPrefix}:${ip}:${req.path}`;

      const current = await redis.incr(key);
      if (current === 1) {
        await redis.pexpire(key, windowMs);
      }

      if (current > maxRequests) {
        const ttl = await redis.pttl(key);
        next(
          ApiError.tooManyRequests(
            `Rate limit exceeded. Try again in ${Math.ceil(ttl / 1000)} seconds.`,
          ),
        );
        return;
      }

      next();
    } catch {
      // If Redis is down, allow the request through
      next();
    }
  };
}

/**
 * Pre-configured rate limiters for common use cases
 */
export const authLimiter = rateLimiter({
  windowMs: 15 * 60 * 1000,  // 15 minutes
  maxRequests: process.env.NODE_ENV === 'development' ? 100 : 10,
  keyPrefix: 'rl:auth',
});

export const generalLimiter = rateLimiter({
  windowMs: 60 * 1000,        // 1 minute
  maxRequests: 100,            // 100 requests per minute
  keyPrefix: 'rl:general',
});
