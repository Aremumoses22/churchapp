// ═══════════════════════════════════════════════════════════════
// Socket.io Server — Central Socket Manager
// Phase 5: Real-Time & Notifications
// ═══════════════════════════════════════════════════════════════

import { Server as HttpServer } from 'http';
import { Server, Socket } from 'socket.io';
import jwt from 'jsonwebtoken';
import env from '../config/env';
import { getRedis } from '../config/redis';
import { logger } from '../utils/logger'; 
import { setupChatSocket } from './chat.socket';
import { setupLiveSocket } from './live.socket';
import { setupNotificationSocket } from './notification.socket';
let io: Server | null = null;

interface SocketUser {
  id: string;
  email: string;
  role: string;
  churchId: string | null;
}

// Extend Socket type to include user
declare module 'socket.io' {
  interface Socket {
    user?: SocketUser;
  }
}

/**
 * Initialize Socket.io server with JWT authentication
 */
export function initializeSocket(httpServer: HttpServer): Server {
  io = new Server(httpServer, {
    cors: {
      origin: env.corsOrigin,
      methods: ['GET', 'POST'],
      credentials: true,
    },
    pingInterval: 25000,
    pingTimeout: 60000,
    transports: ['websocket', 'polling'],
  });

  // Try to connect Redis adapter for horizontal scaling
  setupRedisAdapter().catch((err) => {
    logger.warn('Redis adapter not available, using in-memory adapter:', err.message);
  });

  // JWT Authentication middleware for all socket connections
  io.use(async (socket: Socket, next) => {
    try {
      const token = socket.handshake.auth.token || socket.handshake.headers.authorization?.split(' ')[1];

      if (!token) {
        return next(new Error('Authentication required'));
      }

      const decoded = jwt.verify(token, env.jwtSecret) as {
        sub: string;
        email: string;
        role: string;
        churchId: string | null;
        type: string;
      };

      if (decoded.type !== 'access') {
        return next(new Error('Invalid token type'));
      }

      socket.user = {
        id: decoded.sub,
        email: decoded.email,
        role: decoded.role,
        churchId: decoded.churchId,
      };

      next();
    } catch (error: any) {
      if (error.name === 'TokenExpiredError') {
        return next(new Error('Token expired'));
      }
      return next(new Error('Invalid token'));
    }
  });

  // Connection handler
  io.on('connection', async (socket: Socket) => {
    const user = socket.user!;
    logger.info(`🔌 Socket connected: ${user.email} (${socket.id})`);

    // Join personal room for direct notifications
    socket.join(`user:${user.id}`);

    // Join church room for broadcast events
    if (user.churchId) {
      socket.join(`church:${user.churchId}`);
    }

    // Track online status
    await setUserOnline(user.id, true);
    io!.emit('presence:online', { userId: user.id });

    // Setup namespace handlers
    setupChatSocket(io!, socket);
    setupLiveSocket(io!, socket);
    setupNotificationSocket(io!, socket);

    // Handle disconnection
    socket.on('disconnect', async (reason) => {
      logger.info(`🔌 Socket disconnected: ${user.email} (${reason})`);
      await setUserOnline(user.id, false);
      io!.emit('presence:offline', { userId: user.id });
    });

    // Handle errors
    socket.on('error', (error) => {
      logger.error(`Socket error for ${user.email}:`, error);
    });
  });

  logger.info('🔌 Socket.io initialized');
  return io;
}

/**
 * Setup Redis adapter for Socket.io (horizontal scaling)
 */
async function setupRedisAdapter(): Promise<void> {
  try {
    const redis = getRedis();
    await redis.ping();

    const { createAdapter } = await import('@socket.io/redis-adapter');
    const pubClient = redis.duplicate();
    const subClient = redis.duplicate();

    io!.adapter(createAdapter(pubClient, subClient));
    logger.info('🔌 Socket.io Redis adapter connected');
  } catch (error) {
    throw error;
  }
}

/**
 * Track user online status in Redis
 */
async function setUserOnline(userId: string, online: boolean): Promise<void> {
  try {
    const redis = getRedis();
    if (online) {
      await redis.sadd('online_users', userId);
      await redis.set(`user:${userId}:last_seen`, new Date().toISOString());
    } else {
      await redis.srem('online_users', userId);
      await redis.set(`user:${userId}:last_seen`, new Date().toISOString());
    }
  } catch {
    // Redis not available, skip presence tracking
  }
}

/**
 * Check if a user is online
 */
export async function isUserOnline(userId: string): Promise<boolean> {
  try {
    const redis = getRedis();
    return (await redis.sismember('online_users', userId)) === 1;
  } catch {
    return false;
  }
}

/**
 * Get all online user IDs
 */
export async function getOnlineUsers(): Promise<string[]> {
  try {
    const redis = getRedis();
    return await redis.smembers('online_users');
  } catch {
    return [];
  }
}

/**
 * Get the Socket.io server instance
 */
export function getIO(): Server {
  if (!io) {
    throw new Error('Socket.io not initialized. Call initializeSocket() first.');
  }
  return io;
}

/**
 * Emit an event to a specific user (by userId)
 */
export function emitToUser(userId: string, event: string, data: unknown): void {
  if (io) {
    io.to(`user:${userId}`).emit(event, data);
  }
}

/**
 * Emit an event to all members of a church
 */
export function emitToChurch(churchId: string, event: string, data: unknown): void {
  if (io) {
    io.to(`church:${churchId}`).emit(event, data);
  }
}

/**
 * Emit an event to a specific room
 */
export function emitToRoom(room: string, event: string, data: unknown): void {
  if (io) {
    io.to(room).emit(event, data);
  }
}
