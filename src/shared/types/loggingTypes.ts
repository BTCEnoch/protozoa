/**
 * Logging type definitions
 */

// Log levels
export type LogLevel = "error" | "warn" | "info" | "debug" | "trace";

// Log entry interface
export interface LogEntry {
  level: LogLevel;
  message: string;
  timestamp: number;
  service: string;
  data?: Record<string, any>;
  error?: Error;
}

// Performance log entry
export interface PerformanceLogEntry extends LogEntry {
  operation: string;
  duration: number;
  memoryUsage?: number;
}

// Error log entry
export interface ErrorLogEntry extends LogEntry {
  level: "error";
  error: Error;
  stackTrace?: string;
}
