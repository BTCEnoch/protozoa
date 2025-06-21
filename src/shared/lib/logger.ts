/**
 * @fileoverview Universal Logger - Browser & Node.js Compatible
 * @description Cross-platform logging service that works in browser and Node.js
 * @module @/shared/lib/logger
 * @version 1.0.0
 * @author Protozoa Development Team
 */

// Environment detection
const isBrowser = typeof window !== 'undefined'
const isNode = typeof process !== 'undefined' && process.versions?.node

export type LogLevel = 'debug' | 'info' | 'warn' | 'error'

export interface Logger {
  debug(message: string, meta?: any): void
  info(message: string, meta?: any): void  
  warn(message: string, meta?: any): void
  error(message: string, meta?: any): void
}

/**
 * Browser-compatible logger implementation
 * Uses console API with enhanced formatting and colors
 */
class BrowserLogger implements Logger {
  private service: string
  private level: LogLevel

  constructor(service: string, level: LogLevel = 'info') {
    this.service = service
    this.level = level
  }

  private shouldLog(level: LogLevel): boolean {
    const levels = { debug: 0, info: 1, warn: 2, error: 3 }
    return levels[level] >= levels[this.level]
  }

  private formatMessage(level: LogLevel, message: string, meta?: any): string {
    const timestamp = new Date().toISOString()
    const metaStr = meta ? ` ${JSON.stringify(meta)}` : ''
    return `[${timestamp}] ${level.toUpperCase()} [${this.service}]: ${message}${metaStr}`
  }

  debug(message: string, meta?: any): void {
    if (!this.shouldLog('debug')) return
    if (isBrowser) {
      console.debug(`ðŸ› ${this.formatMessage('debug', message, meta)}`)
    } else {
      console.debug(this.formatMessage('debug', message, meta))
    }
  }

  info(message: string, meta?: any): void {
    if (!this.shouldLog('info')) return
    if (isBrowser) {
      console.info(`â„¹ï¸ ${this.formatMessage('info', message, meta)}`)
    } else {
      console.info(this.formatMessage('info', message, meta))
    }
  }

  warn(message: string, meta?: any): void {
    if (!this.shouldLog('warn')) return
    if (isBrowser) {
      console.warn(`âš ï¸ ${this.formatMessage('warn', message, meta)}`)
    } else {
      console.warn(this.formatMessage('warn', message, meta))
    }
  }

  error(message: string, meta?: any): void {
    if (!this.shouldLog('error')) return
    if (isBrowser) {
      console.error(`âŒ ${this.formatMessage('error', message, meta)}`)
    } else {
      console.error(this.formatMessage('error', message, meta))
    }
  }
}

/**
 * Node.js Winston logger implementation (fallback for server-side)
 * Only loaded when running in Node.js environment
 */
class NodeLogger implements Logger {
  private logger: any
  private service: string

  constructor(service: string) {
    this.service = service
    
    try {
      // Dynamic import of Winston only in Node.js environment
      const winston = require('winston')
      
      this.logger = winston.createLogger({
        level: process.env.NODE_ENV === 'production' ? 'info' : 'debug',
        format: winston.format.combine(
          winston.format.timestamp(),
          winston.format.errors({ stack: true }),
          winston.format.json()
        ),
        defaultMeta: { service },
        transports: [
          new winston.transports.Console({
            format: winston.format.simple()
          })
        ]
      })
    } catch (error) {
      // Fallback to console if Winston is not available
      console.warn(`Winston not available, falling back to console logging for service: ${service}`)
      this.logger = null
    }
  }

  debug(message: string, meta?: any): void {
    if (this.logger) {
      this.logger.debug(message, meta)
    } else {
      console.debug(`[${this.service}] DEBUG: ${message}`, meta || '')
    }
  }

  info(message: string, meta?: any): void {
    if (this.logger) {
      this.logger.info(message, meta)
    } else {
      console.info(`[${this.service}] INFO: ${message}`, meta || '')
    }
  }

  warn(message: string, meta?: any): void {
    if (this.logger) {
      this.logger.warn(message, meta)
    } else {
      console.warn(`[${this.service}] WARN: ${message}`, meta || '')
    }
  }

  error(message: string, meta?: any): void {
    if (this.logger) {
      this.logger.error(message, meta)
    } else {
      console.error(`[${this.service}] ERROR: ${message}`, meta || '')
    }
  }
}

/**
 * Creates a logger appropriate for the current environment
 * @param service - Service name for logging context
 * @returns Logger instance compatible with current environment
 */
export function createServiceLogger(service: string): Logger {
  // Determine log level from environment
  const getLogLevel = (): LogLevel => {
    if (isBrowser) {
      // Check localStorage for browser debug mode
      try {
        const debugMode = localStorage.getItem('protozoa-debug') === 'true'
        return debugMode ? 'debug' : 'info'
      } catch {
        return 'info'
      }
    } else if (isNode) {
      // Check NODE_ENV for Node.js
      return process.env.NODE_ENV === 'development' ? 'debug' : 'info'
    }
    return 'info'
  }

  const logLevel = getLogLevel()

  // Use browser logger in browser environment, Node logger in Node.js
  if (isBrowser) {
    return new BrowserLogger(service, logLevel)
  } else if (isNode) {
    return new NodeLogger(service)
  } else {
    // Fallback for unknown environments
    return new BrowserLogger(service, logLevel)
  }
}

/**
 * Creates a performance-specific logger
 * @param service - Service name (defaults to 'performance')
 * @returns Performance logger instance
 */
export function createPerformanceLogger(service: string = 'performance'): Logger {
  return createServiceLogger(service)
}

/**
 * Creates an error-specific logger
 * @param service - Service name (defaults to 'error-handler')
 * @returns Error logger instance
 */
export function createErrorLogger(service: string = 'error-handler'): Logger {
  return createServiceLogger(service)
}

/**
 * Default logger instance for general use
 */
export const logger = createServiceLogger('protozoa')

/**
 * Enable debug mode in browser (utility function)
 * Call this in browser console: enableDebugLogging()
 */
export function enableDebugLogging(): void {
  if (isBrowser) {
    try {
      localStorage.setItem('protozoa-debug', 'true')
      console.info('ðŸ› Debug logging enabled. Refresh page to apply.')
    } catch (error) {
      console.warn('Failed to enable debug logging:', error)
    }
  }
}

/**
 * Disable debug mode in browser (utility function)
 */
export function disableDebugLogging(): void {
  if (isBrowser) {
    try {
      localStorage.removeItem('protozoa-debug')
      console.info('ðŸ› Debug logging disabled. Refresh page to apply.')
    } catch (error) {
      console.warn('Failed to disable debug logging:', error)
    }
  }
}
