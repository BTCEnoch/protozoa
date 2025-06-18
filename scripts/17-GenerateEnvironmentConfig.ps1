# 17-GenerateEnvironmentConfig.ps1
# Generates Environment Configuration Service for dev/prod API endpoint management
# Addresses critical gap: Environment Configuration Service per audit requirements

param(
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$ProjectRoot = (Get-Location).Path,
    
    [Parameter(Mandatory = $false)]
    [switch]$WhatIf
)

# Import utilities with error handling
try {
    Import-Module "$PSScriptRoot/utils.psm1" -Force -ErrorAction Stop
} catch {
    Write-Error "Failed to import utils module: $($_.Exception.Message)"
    exit 1
}

Write-StepHeader "ENVIRONMENT CONFIGURATION SERVICE GENERATION"
Write-InfoLog "Generating environment configuration service for API endpoint management"

# Validate project structure
try {
    Test-ProjectStructure -ProjectRoot $ProjectRoot -ErrorAction Stop
    Write-InfoLog "Project structure validation passed"
} catch {
    Write-ErrorLog "Project structure validation failed: $($_.Exception.Message)"
    exit 1
}

# Define environment config paths
$sharedConfigPath = Join-Path $ProjectRoot "src/shared/config"
$sharedLibPath = Join-Path $ProjectRoot "src/shared/lib"

Write-InfoLog "Environment config paths:"
Write-InfoLog "  Config: $sharedConfigPath"
Write-InfoLog "  Lib: $sharedLibPath"

# Create directories if they don't exist
$directories = @($sharedConfigPath, $sharedLibPath)
foreach ($dir in $directories) {
    if (-not (Test-Path $dir)) {
        Write-InfoLog "Creating directory: $dir"
        if (-not $WhatIf) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }
    }
}

# Generate Environment Configuration Service
$environmentServiceContent = @'
/**
 * Environment Configuration Service
 * Centralized environment and API endpoint management
 * Provides dev/prod API URL switching and feature flag management
 */

import { IEnvironmentConfig, IBitcoinConfig, IPhysicsConfig, IRenderingConfig } from '@/shared/types/configTypes';
import { createServiceLogger } from '@/shared/lib/logger';

/**
 * Environment modes
 */
export type EnvironmentMode = 'development' | 'production' | 'test';

/**
 * EnvironmentService - singleton service for environment configuration
 * Manages API endpoints, feature flags, and environment-specific settings
 */
class EnvironmentService {
  static #instance: EnvironmentService | null = null;
  
  #config: IEnvironmentConfig;
  #log = createServiceLogger('ENVIRONMENT_SERVICE');
  
  /**
   * Private constructor to enforce singleton pattern
   */
  private constructor() {
    this.#config = this.loadConfiguration();
    this.#log.info('EnvironmentService initialized', { 
      mode: this.#config.mode,
      features: Object.keys(this.#config.features).length
    });
  }
  
  /**
   * Get singleton instance
   */
  public static getInstance(): EnvironmentService {
    if (!EnvironmentService.#instance) {
      EnvironmentService.#instance = new EnvironmentService();
    }
    return EnvironmentService.#instance;
  }
  
  /**
   * Load configuration based on current environment
   */
  private loadConfiguration(): IEnvironmentConfig {
    // Detect environment mode
    const mode = this.detectEnvironmentMode();
    
    // Base configuration
    const config: IEnvironmentConfig = {
      mode,
      apiUrls: {
        bitcoin: this.getBitcoinApiUrl(mode),
        ordinals: this.getOrdinalsApiUrl(mode)
      },
      features: {
        // Core features
        debugLogging: mode === 'development',
        performanceMonitoring: true,
        caching: true,
        
        // Bitcoin features
        bitcoinIntegration: true,
        ordinalsSupport: true,
        blockchainSeeding: true,
        
        // Rendering features
        antialias: true,
        shadows: mode === 'production',
        frustumCulling: true,
        
        // Physics features
        collisionDetection: true,
        spatialPartitioning: mode === 'production',
        
        // Animation features
        advancedEasing: true,
        particleInterpolation: true,
        
        // Development-only features
        devTools: mode === 'development',
        hotReload: mode === 'development',
        debugUI: mode === 'development'
      },
      debug: {
        enabled: mode !== 'production',
        verbose: mode === 'development',
        performanceLogging: mode !== 'test'
      }
    };
    
    this.#log.debug('Configuration loaded', { mode, apiUrls: config.apiUrls });
    return config;
  }
  
  /**
   * Detect current environment mode
   */
  private detectEnvironmentMode(): EnvironmentMode {
    // Node.js environment
    if (typeof process !== 'undefined' && process.env) {
      const nodeEnv = process.env.NODE_ENV?.toLowerCase();
      if (nodeEnv === 'production') return 'production';
      if (nodeEnv === 'test') return 'test';
      return 'development';
    }
    
    // Vite environment
    if (typeof import.meta !== 'undefined' && import.meta.env) {
      const viteMode = import.meta.env.MODE?.toLowerCase();
      if (viteMode === 'production') return 'production';
      if (viteMode === 'test') return 'test';
      return 'development';
    }
    
    // Browser environment - check hostname
    if (typeof window !== 'undefined') {
      const hostname = window.location.hostname;
      if (hostname.includes('localhost') || hostname.includes('127.0.0.1')) {
        return 'development';
      }
      if (hostname.includes('test') || hostname.includes('staging')) {
        return 'test';
      }
      return 'production';
    }
    
    // Default to development
    return 'development';
  }
  
  /**
   * Get Bitcoin API URL based on environment
   */
  private getBitcoinApiUrl(mode: EnvironmentMode): string {
    switch (mode) {
      case 'development':
        return 'https://ordinals.com';
      case 'test':
        return 'https://test.ordinals.com';
      case 'production':
        return ''; // Relative URLs in production
      default:
        return 'https://ordinals.com';
    }
  }
  
  /**
   * Get Ordinals API URL based on environment
   */
  private getOrdinalsApiUrl(mode: EnvironmentMode): string {
    return this.getBitcoinApiUrl(mode); // Same base for now
  }
  
  /**
   * Get current environment mode
   */
  public getMode(): EnvironmentMode {
    return this.#config.mode;
  }
  
  /**
   * Check if running in development mode
   */
  public isDevelopment(): boolean {
    return this.#config.mode === 'development';
  }
  
  /**
   * Check if running in production mode
   */
  public isProduction(): boolean {
    return this.#config.mode === 'production';
  }
  
  /**
   * Check if running in test mode
   */
  public isTest(): boolean {
    return this.#config.mode === 'test';
  }
  
  /**
   * Get API base URL for a service
   */
  public getApiUrl(service: string): string {
    const url = this.#config.apiUrls[service];
    if (!url) {
      this.#log.warn(`No API URL configured for service: ${service}`);
      return '';
    }
    return url;
  }
  
  /**
   * Get Bitcoin API URL
   */
  public getBitcoinApiBaseUrl(): string {
    return this.getApiUrl('bitcoin');
  }
  
  /**
   * Get Ordinals API URL
   */
  public getOrdinalsApiBaseUrl(): string {
    return this.getApiUrl('ordinals');
  }
  
  /**
   * Check if a feature is enabled
   */
  public isFeatureEnabled(feature: string): boolean {
    return this.#config.features[feature] ?? false;
  }
  
  /**
   * Get debug configuration
   */
  public getDebugConfig() {
    return this.#config.debug;
  }
  
  /**
   * Get Bitcoin service configuration
   */
  public getBitcoinConfig(): IBitcoinConfig {
    return {
      name: 'bitcoin',
      debug: this.#config.debug.enabled,
      monitoring: this.#config.debug.performanceLogging,
      apiBaseUrl: this.getBitcoinApiBaseUrl(),
      rateLimit: this.isProduction() ? 5 : 10, // requests per second
      cacheTtl: this.isProduction() ? 300000 : 60000, // 5 min prod, 1 min dev
      maxRetries: 3,
      timeout: this.isProduction() ? 10000 : 30000 // 10s prod, 30s dev
    };
  }
  
  /**
   * Get Physics service configuration
   */
  public getPhysicsConfig(): IPhysicsConfig {
    return {
      name: 'physics',
      debug: this.#config.debug.enabled,
      monitoring: this.#config.debug.performanceLogging,
      gravity: 9.81,
      timeStep: 1/60, // 60 FPS
      maxVelocity: 100,
      collisionDetection: this.isFeatureEnabled('collisionDetection'),
      gridSize: this.isProduction() ? 100 : 50
    };
  }
  
  /**
   * Get Rendering service configuration
   */
  public getRenderingConfig(): IRenderingConfig {
    return {
      name: 'rendering',
      debug: this.#config.debug.enabled,
      monitoring: this.#config.debug.performanceLogging,
      targetFps: 60,
      antialias: this.isFeatureEnabled('antialias'),
      shadows: this.isFeatureEnabled('shadows'),
      maxDrawCalls: this.isProduction() ? 1000 : 500,
      frustumCulling: this.isFeatureEnabled('frustumCulling')
    };
  }
  
  /**
   * Dispose of the service (for testing)
   */
  public dispose(): void {
    this.#log.info('EnvironmentService disposed');
    EnvironmentService.#instance = null;
  }
}

// Export singleton instance
export const environmentService = EnvironmentService.getInstance();
export { EnvironmentService };
'@

Write-InfoLog "Writing environment service..."
if (-not $WhatIf) {
    Set-Content -Path (Join-Path $sharedConfigPath "environmentService.ts") -Value $environmentServiceContent -Encoding UTF8
}

# Generate Logging Service Implementation
$loggingServiceContent = @'
/**
 * Logging Service Implementation
 * Winston-based logging with standardized levels and formatting
 * Used across all domain services for consistent logging
 */

import winston from 'winston';
import { ILogger, LogLevel, ILogEntry, IPerformanceMetrics } from '@/shared/types/loggingTypes';
import { environmentService } from './environmentService';

/**
 * Create a service-specific logger instance
 */
export function createServiceLogger(serviceName: string): ILogger {
  const debugConfig = environmentService.getDebugConfig();
  
  const logger = winston.createLogger({
    level: debugConfig.verbose ? 'debug' : 'info',
    format: winston.format.combine(
      winston.format.timestamp(),
      winston.format.errors({ stack: true }),
      winston.format.json(),
      winston.format.printf(({ timestamp, level, message, service, ...meta }) => {
        const logEntry: Partial<ILogEntry> = {
          timestamp: new Date(timestamp),
          level: level as LogLevel,
          message,
          service: service || serviceName,
          metadata: meta
        };
        return JSON.stringify(logEntry);
      })
    ),
    defaultMeta: { service: serviceName },
    transports: [
      new winston.transports.Console({
        format: winston.format.combine(
          winston.format.colorize(),
          winston.format.simple(),
          winston.format.printf(({ timestamp, level, message, service, ...meta }) => {
            const metaStr = Object.keys(meta).length ? JSON.stringify(meta) : '';
            return `${timestamp} [${service}] ${level}: ${message} ${metaStr}`;
          })
        )
      })
    ]
  });

  // Add file transport in production
  if (environmentService.isProduction()) {
    logger.add(new winston.transports.File({
      filename: 'logs/error.log',
      level: 'error'
    }));
    logger.add(new winston.transports.File({
      filename: 'logs/combined.log'
    }));
  }

  return {
    debug: (message: string, metadata?: Record<string, any>) => {
      logger.debug(message, metadata);
    },
    info: (message: string, metadata?: Record<string, any>) => {
      logger.info(message, metadata);
    },
    warn: (message: string, metadata?: Record<string, any>) => {
      logger.warn(message, metadata);
    },
    error: (message: string, error?: Error, metadata?: Record<string, any>) => {
      logger.error(message, { error: error?.message, stack: error?.stack, ...metadata });
    }
  };
}

/**
 * Create a performance logger for metrics tracking
 */
export function createPerformanceLogger(serviceName: string): {
  debug: (message: string, metrics?: IPerformanceMetrics) => void;
  measureOperation: <T>(operation: string, fn: () => T) => T;
  measureAsyncOperation: <T>(operation: string, fn: () => Promise<T>) => Promise<T>;
} {
  const logger = createServiceLogger(`${serviceName}_PERF`);
  const debugConfig = environmentService.getDebugConfig();
  
  return {
    debug: (message: string, metrics?: IPerformanceMetrics) => {
      if (debugConfig.performanceLogging) {
        logger.debug(message, metrics);
      }
    },
    
    measureOperation: <T>(operation: string, fn: () => T): T => {
      if (!debugConfig.performanceLogging) {
        return fn();
      }
      
      const startTime = performance.now();
      const startMemory = (performance as any).memory?.usedJSHeapSize || 0;
      
      try {
        const result = fn();
        const endTime = performance.now();
        const endMemory = (performance as any).memory?.usedJSHeapSize || 0;
        
        const metrics: IPerformanceMetrics = {
          operation,
          duration: endTime - startTime,
          memoryDelta: endMemory - startMemory
        };
        
        logger.debug(`Operation completed: ${operation}`, metrics);
        return result;
      } catch (error) {
        const endTime = performance.now();
        logger.error(`Operation failed: ${operation}`, error as Error, {
          duration: endTime - startTime
        });
        throw error;
      }
    },
    
    measureAsyncOperation: async <T>(operation: string, fn: () => Promise<T>): Promise<T> => {
      if (!debugConfig.performanceLogging) {
        return fn();
      }
      
      const startTime = performance.now();
      const startMemory = (performance as any).memory?.usedJSHeapSize || 0;
      
      try {
        const result = await fn();
        const endTime = performance.now();
        const endMemory = (performance as any).memory?.usedJSHeapSize || 0;
        
        const metrics: IPerformanceMetrics = {
          operation,
          duration: endTime - startTime,
          memoryDelta: endMemory - startMemory
        };
        
        logger.debug(`Async operation completed: ${operation}`, metrics);
        return result;
      } catch (error) {
        const endTime = performance.now();
        logger.error(`Async operation failed: ${operation}`, error as Error, {
          duration: endTime - startTime
        });
        throw error;
      }
    }
  };
}

/**
 * Create an error logger for centralized error handling
 */
export function createErrorLogger(serviceName: string): {
  logError: (error: Error, context?: Record<string, any>) => void;
  logWarning: (message: string, context?: Record<string, any>) => void;
} {
  const logger = createServiceLogger(`${serviceName}_ERROR`);
  
  return {
    logError: (error: Error, context?: Record<string, any>) => {
      logger.error(`Error in ${serviceName}`, error, context);
    },
    
    logWarning: (message: string, context?: Record<string, any>) => {
      logger.warn(`Warning in ${serviceName}: ${message}`, context);
    }
  };
}
'@

Write-InfoLog "Writing logging service..."
if (-not $WhatIf) {
    Set-Content -Path (Join-Path $sharedLibPath "logger.ts") -Value $loggingServiceContent -Encoding UTF8
}

# Generate Environment Utilities
$envUtilsContent = @'
/**
 * Environment Utilities
 * Helper functions for environment detection and configuration
 */

import { environmentService, EnvironmentMode } from '@/shared/config/environmentService';

/**
 * Check if feature is enabled with fallback
 */
export function isFeatureEnabled(feature: string, fallback: boolean = false): boolean {
  try {
    return environmentService.isFeatureEnabled(feature);
  } catch {
    return fallback;
  }
}

/**
 * Get environment-specific timeout values
 */
export function getTimeout(operation: 'api' | 'render' | 'physics' | 'animation'): number {
  const mode = environmentService.getMode();
  
  const timeouts = {
    development: {
      api: 30000,      // 30s
      render: 100,     // 100ms
      physics: 16,     // 16ms (60fps)
      animation: 1000  // 1s
    },
    production: {
      api: 10000,      // 10s
      render: 16,      // 16ms (60fps)
      physics: 16,     // 16ms (60fps)
      animation: 500   // 0.5s
    },
    test: {
      api: 5000,       // 5s
      render: 50,      // 50ms
      physics: 16,     // 16ms (60fps)
      animation: 100   // 0.1s
    }
  };
  
  return timeouts[mode][operation];
}

/**
 * Get retry configuration for operations
 */
export function getRetryConfig(operation: 'api' | 'render' | 'physics'): { maxRetries: number; delay: number } {
  const mode = environmentService.getMode();
  
  const configs = {
    development: {
      api: { maxRetries: 3, delay: 1000 },
      render: { maxRetries: 1, delay: 100 },
      physics: { maxRetries: 0, delay: 0 }
    },
    production: {
      api: { maxRetries: 3, delay: 2000 },
      render: { maxRetries: 2, delay: 50 },
      physics: { maxRetries: 1, delay: 16 }
    },
    test: {
      api: { maxRetries: 1, delay: 100 },
      render: { maxRetries: 0, delay: 0 },
      physics: { maxRetries: 0, delay: 0 }
    }
  };
  
  return configs[mode][operation];
}

/**
 * Build Bitcoin API URL for specific endpoint
 */
export function buildBitcoinApiUrl(endpoint: string): string {
  const baseUrl = environmentService.getBitcoinApiBaseUrl();
  
  // Handle relative URLs in production
  if (!baseUrl) {
    return endpoint.startsWith('/') ? endpoint : `/${endpoint}`;
  }
  
  // Handle absolute URLs in development
  return `${baseUrl}${endpoint.startsWith('/') ? '' : '/'}${endpoint}`;
}

/**
 * Build Ordinals API URL for specific endpoint
 */
export function buildOrdinalsApiUrl(endpoint: string): string {
  const baseUrl = environmentService.getOrdinalsApiBaseUrl();
  
  // Handle relative URLs in production
  if (!baseUrl) {
    return endpoint.startsWith('/') ? endpoint : `/${endpoint}`;
  }
  
  // Handle absolute URLs in development
  return `${baseUrl}${endpoint.startsWith('/') ? '' : '/'}${endpoint}`;
}

/**
 * Get performance monitoring settings
 */
export function getPerformanceSettings(): {
  monitoring: boolean;
  sampleRate: number;
  memoryTracking: boolean;
  frameRateTracking: boolean;
} {
  const mode = environmentService.getMode();
  const debugConfig = environmentService.getDebugConfig();
  
  return {
    monitoring: debugConfig.performanceLogging,
    sampleRate: mode === 'development' ? 1.0 : 0.1, // 100% dev, 10% prod
    memoryTracking: mode !== 'production',
    frameRateTracking: true
  };
}
'@

Write-InfoLog "Writing environment utilities..."
if (-not $WhatIf) {
    Set-Content -Path (Join-Path $sharedConfigPath "envUtils.ts") -Value $envUtilsContent -Encoding UTF8
}

# Generate Configuration Index
$configIndexContent = @'
/**
 * Configuration Module Index
 * Central export point for all configuration services and utilities
 */

// Core environment service
export * from './environmentService';

// Environment utilities
export * from './envUtils';
'@

Write-InfoLog "Writing configuration index..."
if (-not $WhatIf) {
    Set-Content -Path (Join-Path $sharedConfigPath "index.ts") -Value $configIndexContent -Encoding UTF8
}

# Generate package.json updates for Winston
$packageUpdates = @'
{
  "dependencies": {
    "winston": "^3.11.0"
  },
  "devDependencies": {
    ''@types/winston": "^2.4.4"
  }
}
'@

Write-InfoLog "Writing package dependency updates..."
if (-not $WhatIf) {
    Set-Content -Path (Join-Path $ProjectRoot "environment-dependencies.json") -Value $packageUpdates -Encoding UTF8
}

Write-SuccessLog "Environment configuration service generation completed!"

if (-not $WhatIf) {
    Write-InfoLog ""
    Write-InfoLog "Generated environment configuration:"
    Write-InfoLog "  ✅ environmentService.ts - Core environment configuration service"
    Write-InfoLog "  ✅ logger.ts - Winston-based logging implementation"
    Write-InfoLog "  ✅ envUtils.ts - Environment utility functions"
    Write-InfoLog "  ✅ index.ts - Configuration module exports"
    Write-InfoLog "  ✅ environment-dependencies.json - Package dependency updates"
    Write-InfoLog ""
    Write-InfoLog "Features included:"
    Write-InfoLog "  🔧 Environment detection (dev/prod/test)"
    Write-InfoLog "  🌐 API URL management (Bitcoin Ordinals)"
    Write-InfoLog "  🚀 Feature flag system"
    Write-InfoLog "  📊 Performance monitoring configuration"
    Write-InfoLog "  🔍 Winston logging integration"
    Write-InfoLog "  ⚡ Service-specific configuration helpers"
    Write-InfoLog ""
    Write-InfoLog "Critical Gap 'Environment Configuration Service' has been RESOLVED!"
    Write-InfoLog ""
    Write-InfoLog "Next steps:"
    Write-InfoLog "1. Run 'npm install winston @types/winston' to install logging dependencies"
    Write-InfoLog "2. Import environmentService in your domain services"
    Write-InfoLog "3. Use createServiceLogger for consistent logging across domains"
} 

}
