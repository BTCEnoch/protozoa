/**
 * Logging and Error Types
 * Standardized logging and error handling interfaces
 */

/**
 * Log levels enum
 */
export enum LogLevel {
  DEBUG = "debug",
  INFO = "info",
  WARN = "warn",
  ERROR = "error"
}

/**
 * Log entry interface
 */
export interface ILogEntry {
  /** Log level */
  level: LogLevel;
  /** Log message */
  message: string;
  /** Timestamp */
  timestamp: Date;
  /** Service/domain name */
  service: string;
  /** Optional metadata */
  metadata?: Record<string, any>;
  /** Error object if applicable */
  error?: Error;
}

/**
 * Logger interface
 */
export interface ILogger {
  debug(message: string, metadata?: Record<string, any>): void;
  info(message: string, metadata?: Record<string, any>): void;
  warn(message: string, metadata?: Record<string, any>): void;
  error(message: string, error?: Error, metadata?: Record<string, any>): void;
}

/**
 * Performance metrics interface
 */
export interface IPerformanceMetrics {
  /** Operation name */
  operation: string;
  /** Duration in milliseconds */
  duration: number;
  /** Memory usage delta */
  memoryDelta?: number;
  /** Additional metrics */
  metrics?: Record<string, number>;
}

/**
 * Service health status
 */
export enum ServiceStatus {
  HEALTHY = "healthy",
  DEGRADED = "degraded",
  UNHEALTHY = "unhealthy",
  UNKNOWN = "unknown"
}

/**
 * Service health check result
 */
export interface IHealthCheck {
  /** Service name */
  service: string;
  /** Current status */
  status: ServiceStatus;
  /** Check timestamp */
  timestamp: Date;
  /** Response time in milliseconds */
  responseTime: number;
  /** Optional error message */
  error?: string;
  /** Additional details */
  details?: Record<string, any>;
}
