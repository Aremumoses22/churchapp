import { PrismaClient } from '../generated/prisma/client';
import { PrismaPg } from '@prisma/adapter-pg';
import env from './env';

const adapter = new PrismaPg({
  connectionString: env.databaseUrl,
});

const prisma = new PrismaClient({
  adapter,
  log: env.isDev ? ['query', 'info', 'warn', 'error'] : ['error'],
});

export default prisma;
