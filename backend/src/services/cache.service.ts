// ═══════════════════════════════════════════════════════════════
// Redis Cache Service
// Phase 7: Caching Strategy for frequently accessed data
// ═══════════════════════════════════════════════════════════════

import { getRedis } from '../config/redis';
import { logger } from '../utils/logger';

// Cache TTLs in seconds
export const CACHE_TTLS = {
  HOME_FEED: 60,         // 1 minute
  SERMONS_LIST: 300,     // 5 minutes
  EVENTS_UPCOMING: 300,  // 5 minutes
  BIBLE_CHAPTER: 86400,  // 24 hours
  CHURCH_ABOUT: 3600,    // 1 hour
  SEARCH_TRENDING: 900,  // 15 minutes
  LIVE_VIEWERS: 30,      // 30 seconds
  ONLINE_USERS: 60,      // 1 minute
} as const;

// Cache key patterns
export const CACHE_KEYS = {
  homeFeed: (userId: string) => `home:feed:${userId}`,
  sermonsList: (churchId: string, page: number) => `sermons:list:${churchId}:${page}`,
  eventsUpcoming: (churchId: string) => `events:upcoming:${churchId}`,
  bibleChapter: (bookId: string, chapter: number) => `bible:${bookId}:${chapter}`,
  churchAbout: (churchId: string) => `church:about:${churchId}`,
  searchTrending: (churchId: string) => `search:trending:${churchId}`,
  liveViewers: (serviceId: string) => `live:viewers:${serviceId}`,
  onlineUsers: (churchId: string) => `online:${churchId}`,
} as const;

export const cacheService = {
  /**
   * Get a cached value (returns null if not found)
   */
  async get<T>(key: string): Promise<T | null> {
    try {
      const redis = getRedis();
      const cached = await redis.get(key);
      if (cached === null) return null;
      return JSON.parse(cached) as T;
    } catch (error) {
      logger.error(`Cache get error for key ${key}:`, error);
      return null;
    }
  },

  /**
   * Set a cached value with TTL
   */
  async set(key: string, value: unknown, ttlSeconds: number): Promise<void> {
    try {
      const redis = getRedis();
      await redis.set(key, JSON.stringify(value), 'EX', ttlSeconds);
    } catch (error) {
      logger.error(`Cache set error for key ${key}:`, error);
    }
  },

  /**
   * Delete a cached value
   */
  async del(key: string): Promise<void> {
    try {
      const redis = getRedis();
      await redis.del(key);
    } catch (error) {
      logger.error(`Cache del error for key ${key}:`, error);
    }
  },

  /**
   * Delete all keys matching a pattern
   */
  async delPattern(pattern: string): Promise<void> {
    try {
      const redis = getRedis();
      const keys = await redis.keys(pattern);
      if (keys.length > 0) {
        await redis.del(...keys);
      }
    } catch (error) {
      logger.error(`Cache delPattern error for pattern ${pattern}:`, error);
    }
  },

  /**
   * Get-or-set pattern: returns cached value or calls factory and caches result
   */
  async getOrSet<T>(key: string, ttlSeconds: number, factory: () => Promise<T>): Promise<T> {
    const cached = await cacheService.get<T>(key);
    if (cached !== null) return cached;

    const value = await factory();
    await cacheService.set(key, value, ttlSeconds);
    return value;
  },

  /**
   * Increment a counter (for live viewer counts etc.)
   */
  async increment(key: string, ttlSeconds?: number): Promise<number> {
    try {
      const redis = getRedis();
      const count = await redis.incr(key);
      if (ttlSeconds) {
        await redis.expire(key, ttlSeconds);
      }
      return count;
    } catch (error) {
      logger.error(`Cache increment error for key ${key}:`, error);
      return 0;
    }
  },

  /**
   * Decrement a counter
   */
  async decrement(key: string): Promise<number> {
    try {
      const redis = getRedis();
      const count = await redis.decr(key);
      return Math.max(0, count);
    } catch (error) {
      logger.error(`Cache decrement error for key ${key}:`, error);
      return 0;
    }
  },

  /**
   * Add to a set (for online users tracking)
   */
  async addToSet(key: string, member: string, ttlSeconds?: number): Promise<void> {
    try {
      const redis = getRedis();
      await redis.sadd(key, member);
      if (ttlSeconds) {
        await redis.expire(key, ttlSeconds);
      }
    } catch (error) {
      logger.error(`Cache addToSet error for key ${key}:`, error);
    }
  },

  /**
   * Remove from a set
   */
  async removeFromSet(key: string, member: string): Promise<void> {
    try {
      const redis = getRedis();
      await redis.srem(key, member);
    } catch (error) {
      logger.error(`Cache removeFromSet error for key ${key}:`, error);
    }
  },

  /**
   * Get set size (for online user counts)
   */
  async getSetSize(key: string): Promise<number> {
    try {
      const redis = getRedis();
      return await redis.scard(key);
    } catch (error) {
      logger.error(`Cache getSetSize error for key ${key}:`, error);
      return 0;
    }
  },
};
