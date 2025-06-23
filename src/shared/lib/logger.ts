/**
 * @fileoverview Universal Browser-Compatible Logger
 * @description Pure browser-compatible logging service with no Node.js dependencies
 * @module @/shared/lib/logger
 * @version 2.0.0
 * @author Protozoa Development Team
 */

export type LogLevel = 'debug' | 'info' | 'warn' | 'error'

export interface Logger {
  debug(message: string, meta?: any): void
  info(message: string, meta?: any): void  
  warn(message: string, meta?: any): void
  error(message: string, meta?: any): void
  success(message: string, meta?: any): void
}

/**
 * Pure browser-compatible logger implementation
 * Uses console API with enhanced formatting and colors
 * No Node.js dependencies - works in all environments
 */
class UniversalLogger implements Logger {
  private service: string
  private level: LogLevel
  private colors: Record<LogLevel, string>

  constructor(service: string, level: LogLevel = 'info') {
    this.service = service
    this.level = level
    this.colors = {
      debug: '#6B7280', // Gray
      info: '#3B82F6',  // Blue  
      warn: '#F59E0B',  // Orange
      error: '#EF4444'  // Red
    }
  }

  private shouldLog(level: LogLevel): boolean {
    const levels = { debug: 0, info: 1, warn: 2, error: 3 }
    return levels[level] >= levels[this.level]
  }

  private formatMessage(level: LogLevel, message: string, meta?: any): string {
    const timestamp = new Date().toISOString()
    const metaStr = meta ? ` ${JSON.stringify(meta, null, 2)}` : ''
    return `[${timestamp}] ${level.toUpperCase()} [${this.service}]: ${message}${metaStr}`
  }

  private logWithStyle(level: LogLevel, message: string, meta?: any): void {
    const formattedMessage = this.formatMessage(level, message, meta)
    const color = this.colors[level]
    
    try {
      // Enhanced console logging with colors and styling
      console.log(
        `%c${formattedMessage}`,
        `color: ${color}; font-weight: ${level === 'error' ? 'bold' : 'normal'}`
      )
    } catch {
      // Fallback for environments that don't support styled console
      console.log(formattedMessage)
    }
  }

  debug(message: string, meta?: any): void {
    if (!this.shouldLog('debug')) return
    this.logWithStyle('debug', `ðŸ› ${message}`, meta)
  }

  info(message: string, meta?: any): void {
    if (!this.shouldLog('info')) return
    this.logWithStyle('info', `â„¹ï¸ ${message}`, meta)
  }

  warn(message: string, meta?: any): void {
    if (!this.shouldLog('warn')) return
    this.logWithStyle('warn', `âš ï¸ ${message}`, meta)
    
    // Also use native console.warn for visibility
    try {
      console.warn(`[${this.service}] ${message}`, meta || '')
    } catch {
      // Fallback handled by logWithStyle above
    }
  }

  error(message: string, meta?: any): void {
    if (!this.shouldLog('error')) return
    this.logWithStyle('error', `âŒ ${message}`, meta)
    
    // Also use native console.error for visibility and stack traces
    try {
      console.error(`[${this.service}] ${message}`, meta || '')
    } catch {
      // Fallback handled by logWithStyle above  
    }
  }

  success(message: string, meta?: any): void {
    if (!this.shouldLog('info')) return
    this.logWithStyle('info', `âœ… ${message}`, meta)
  }
}

/**
 * Performance monitoring logger with timing capabilities
 */
class PerformanceLogger extends UniversalLogger {
  private timers: Map<string, number> = new Map()

  constructor(service: string = 'performance') {
    super(service)
  }

  /**
   * Start timing an operation
   * @param operation - Name of the operation to time
   */
  startTimer(operation: string): void {
    this.timers.set(operation, performance.now())
    this.debug(`â±ï¸ Started timing: ${operation}`)
  }

  /**
   * End timing an operation and log the duration
   * @param operation - Name of the operation that was timed
   */
  endTimer(operation: string): number {
    const startTime = this.timers.get(operation)
    if (!startTime) {
      this.warn(`â±ï¸ No timer found for operation: ${operation}`)
      return 0
    }

    const duration = performance.now() - startTime
    this.timers.delete(operation)
    
    // Log performance with appropriate level based on duration
    if (duration > 1000) {
      this.warn(`â±ï¸ SLOW: ${operation} took ${duration.toFixed(2)}ms`)
    } else if (duration > 100) {
      this.info(`â±ï¸ ${operation} took ${duration.toFixed(2)}ms`)
    } else {
      this.debug(`â±ï¸ ${operation} took ${duration.toFixed(2)}ms`)
    }

    return duration
  }

  /**
   * Log memory usage (if available)
   */
  logMemoryUsage(): void {
    try {
      if ('memory' in performance) {
        const memory = (performance as any).memory
        this.info('ðŸ“Š Memory Usage', {
          used: `${(memory.usedJSHeapSize / 1024 / 1024).toFixed(2)}MB`,
          total: `${(memory.totalJSHeapSize / 1024 / 1024).toFixed(2)}MB`,
          limit: `${(memory.jsHeapSizeLimit / 1024 / 1024).toFixed(2)}MB`
        })
      } else {
        this.debug('ðŸ“Š Memory info not available in this environment')
      }
    } catch (error) {
      this.debug('ðŸ“Š Failed to get memory usage', error)
    }
  }
}

/**
 * Creates a logger for the specified service
 * @param service - Service name for logging context
 * @param level - Log level (defaults to 'info' in production, 'debug' in development)
 * @returns Logger instance
 */
export function createServiceLogger(service: string, level?: LogLevel): Logger {
  // Determine log level from environment or parameter
  const getLogLevel = (): LogLevel => {
    if (level) return level
    
    try {
      // Check for debug mode in localStorage (browser)
      if (typeof window !== 'undefined' && window.localStorage) {
        const debugMode = localStorage.getItem('protozoa-debug') === 'true'
        if (debugMode) return 'debug'
      }
      
      // Check for development environment indicators
      if (typeof process !== 'undefined' && process.env?.NODE_ENV === 'development') {
        return 'debug'
      }
      
      // Check for Vite development mode
      if (typeof import.meta !== 'undefined' && (import.meta as any).env?.DEV) {
        return 'debug'
      }
      
      // Default to info level
      return 'info'
    } catch {
      return 'info'
    }
  }

  return new UniversalLogger(service, getLogLevel())
}

/**
 * Creates a performance-specific logger with timing capabilities
 * @param service - Service name (defaults to 'performance')
 * @returns Performance logger instance
 */
export function createPerformanceLogger(service: string = 'performance'): PerformanceLogger {
  return new PerformanceLogger(service)
}

/**
 * Creates an error-specific logger
 * @param service - Service name (defaults to 'error-handler')  
 * @returns Error logger instance
 */
export function createErrorLogger(service: string = 'error-handler'): Logger {
  return createServiceLogger(service, 'debug') // Always debug level for error tracking
}

/**
 * Default logger instance for general use
 */
export const logger = createServiceLogger('protozoa')

/**
 * Performance logger instance for timing operations
 */
export const perfLogger = createPerformanceLogger()

/**
 * Error logger instance for error tracking
 */
export const errorLogger = createErrorLogger()

/**
 * Enable debug mode in browser (utility function)
 * Call this in browser console: enableDebugLogging()
 */
export function enableDebugLogging(): void {
  try {
    if (typeof window !== 'undefined' && window.localStorage) {
      localStorage.setItem('protozoa-debug', 'true')
      console.info('ðŸ› Debug logging enabled. Refresh page to apply.')
    } else {
      console.info('ðŸ› Debug logging not available in this environment')
    }
  } catch (error) {
    console.warn('Failed to enable debug logging:', error)
  }
}

/**
 * Disable debug mode in browser (utility function)
 */
export function disableDebugLogging(): void {
  try {
    if (typeof window !== 'undefined' && window.localStorage) {
      localStorage.removeItem('protozoa-debug')
      console.info('ðŸ› Debug logging disabled. Refresh page to apply.')
    } else {
      console.info('ðŸ› Debug logging not available in this environment')
    }
  } catch (error) {
    console.warn('Failed to disable debug logging:', error)
  }
}

/**
 * Initialize logging system with environment detection
 */
export function initializeLogging(): void {
  logger.info('ðŸš€ Protozoa logging system initialized')
  
  // Log environment info
  try {
    const env = typeof import.meta !== 'undefined' && (import.meta as any).env?.DEV ? 'development' : 'production'
    logger.info(`ðŸŒ Environment: ${env}`)
    
    if (typeof window !== 'undefined') {
      logger.info(`ðŸŒ Browser: ${navigator.userAgent.split(' ').pop() || 'Unknown'}`)
    }
  } catch {
    logger.debug('Environment detection failed - continuing with defaults')
  }
}
