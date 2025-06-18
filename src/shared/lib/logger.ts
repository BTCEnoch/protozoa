// src/shared/lib/logger.ts
// Winston logging utilities for all domains
// Referenced from .cursorrules logging requirements

import winston from 'winston';

const logFormat = winston.format.combine(
  winston.format.timestamp(),
  winston.format.errors({ stack: true }),
  winston.format.json()
);

const baseLogger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: logFormat,
  transports: [
    new winston.transports.Console({
      format: winston.format.combine(
        winston.format.colorize(),
        winston.format.simple()
      )
    })
  ]
});

export function createServiceLogger(serviceName: string): winston.Logger {
  return baseLogger.child({ service: serviceName });
}

export function createPerformanceLogger(serviceName: string): winston.Logger {
  return baseLogger.child({ service: serviceName, type: 'performance' });
}

export function createErrorLogger(serviceName: string): winston.Logger {
  return baseLogger.child({ service: serviceName, type: 'error' });
}
