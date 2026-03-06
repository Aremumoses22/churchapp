import env from '../config/env';

type LogLevel = 'info' | 'warn' | 'error' | 'debug';

const LOG_COLORS: Record<LogLevel, string> = {
  info: '\x1b[36m',   // cyan
  warn: '\x1b[33m',   // yellow
  error: '\x1b[31m',  // red
  debug: '\x1b[90m',  // gray
};
const RESET = '\x1b[0m';

function formatMessage(level: LogLevel, message: string, meta?: unknown): string {
  const timestamp = new Date().toISOString();
  const color = LOG_COLORS[level];
  const metaStr = meta ? ` ${JSON.stringify(meta)}` : '';
  return `${color}[${timestamp}] [${level.toUpperCase()}]${RESET} ${message}${metaStr}`;
}

export const logger = {
  info(message: string, meta?: unknown) {
    console.log(formatMessage('info', message, meta));
  },

  warn(message: string, meta?: unknown) {
    console.warn(formatMessage('warn', message, meta));
  },

  error(message: string, meta?: unknown) {
    console.error(formatMessage('error', message, meta));
  },

  debug(message: string, meta?: unknown) {
    if (env.isDev) {
      console.debug(formatMessage('debug', message, meta));
    }
  },
};
