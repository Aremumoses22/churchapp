import app from './app';
import env from './config/env';
import prisma from './config/database';
import { logger } from './utils/logger';
import { initializeSocket } from './socket/index';
import { closeRedis } from './config/redis';
import { startWorkers, stopWorkers, registerScheduledJobs, closeAllQueues } from './jobs/index';

async function startServer() {
  try {
    // Test database connection
    await prisma.$connect();
    logger.info('✅ Database connected');

    // Start Express server
    const server = app.listen(env.port, () => {
      logger.info(`
╔═══════════════════════════════════════════════════════╗
║                                                       ║
║   ⛪ Church App Backend                               ║
║                                                       ║
║   Environment:  ${env.nodeEnv.padEnd(36)}║
║   Port:         ${String(env.port).padEnd(36)}║
║   API:          /api/${env.apiVersion.padEnd(32)}║
║   Health:       http://localhost:${env.port}/health${' '.repeat(12)}║
║                                                       ║
╚═══════════════════════════════════════════════════════╝
      `);
    });

    // Initialize Socket.io
    initializeSocket(server);
    logger.info('✅ Socket.io initialized');

    // Initialize BullMQ workers and scheduled jobs
    startWorkers();
    await registerScheduledJobs();
    logger.info('✅ Background job processing initialized');

    // ── Graceful shutdown ─────────────────────────────
    const shutdown = async (signal: string) => {
      logger.info(`\n${signal} received. Shutting down gracefully...`);

      server.close(async () => {
        await stopWorkers();
        await closeAllQueues();
        await closeRedis();
        await prisma.$disconnect();
        logger.info('✅ All connections closed');
        logger.info('👋 Server shut down');
        process.exit(0);
      });

      // Force exit after 10s
      setTimeout(() => {
        logger.error('Forced shutdown after 10s timeout');
        process.exit(1);
      }, 10000);
    };

    process.on('SIGTERM', () => shutdown('SIGTERM'));
    process.on('SIGINT', () => shutdown('SIGINT'));

    // Handle uncaught errors
    process.on('uncaughtException', (error) => {
      logger.error('Uncaught Exception:', error);
      process.exit(1);
    });

    process.on('unhandledRejection', (reason) => {
      logger.error('Unhandled Rejection:', reason);
      process.exit(1);
    });

  } catch (error) {
    logger.error('❌ Failed to start server:', error);
    await prisma.$disconnect();
    process.exit(1);
  }
}

startServer();
