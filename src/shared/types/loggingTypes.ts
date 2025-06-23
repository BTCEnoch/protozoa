/** Logging & metrics types (Template) */

export enum LogLevel { DEBUG = "debug", INFO = "info", WARN = "warn", ERROR = "error" }

export interface ILogEntry { level: LogLevel; message: string; timestamp: Date; service: string; metadata?: any }

export interface ILogger {
  debug(msg: string, meta?: any): void
  info(msg: string, meta?: any): void
  warn(msg: string, meta?: any): void
  error(msg: string, meta?: any): void
}

export interface IPerformanceMetrics { operation: string; duration: number; memoryDelta?: number }
