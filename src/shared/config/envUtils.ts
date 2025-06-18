/**
 * Environment Utilities
 * Helper functions for environment detection and configuration
 */

import { environmentService } from '@/shared/config/environmentService';

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
  const baseUrl = environmentService.getBitcoinApiBaseUrl()

  // Production builds use relative paths (baseUrl is empty)
  if (!baseUrl) return endpoint.startsWith('/') ? endpoint : `/${endpoint}`

  // Dev / test have absolute base – ensure exactly one slash separator
  return `${baseUrl}${endpoint.startsWith('/') ? '' : '/'}${endpoint}`
}

/**
 * Build Ordinals API URL for specific endpoint
 */
export function buildOrdinalsApiUrl(endpoint: string): string {
  const baseUrl = environmentService.getOrdinalsApiBaseUrl()

  if (!baseUrl) return endpoint.startsWith('/') ? endpoint : `/${endpoint}`

  return `${baseUrl}${endpoint.startsWith('/') ? '' : '/'}${endpoint}`
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
