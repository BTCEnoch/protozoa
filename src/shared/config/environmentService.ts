/**
 * Environment Configuration Service
 * Centralized environment and API endpoint management
 * Provides dev/prod API URL switching and feature flag management
 */

import { createServiceLogger } from '@/shared/lib/logger';
import { IBitcoinConfig, IEnvironmentConfig, IPhysicsConfig, IRenderingConfig } from '@/shared/types/configTypes';

/**
 * Environment modes
 */
export type EnvironmentMode = 'development' | 'production' | 'test';

/**
 * EnvironmentService - singleton service for environment configuration
 * Manages API endpoints, feature flags, and environment-specific settings
 */
class EnvironmentService {
  private static _instance: EnvironmentService | null = null;
  
  private _config: IEnvironmentConfig;
  private _log = createServiceLogger('ENVIRONMENT_SERVICE');
  
  /**
   * Private constructor to enforce singleton pattern
   */
  private constructor() {
    this._config = this.loadConfiguration();
    this._log.info('EnvironmentService initialized', { 
      mode: this._config.mode,
      features: Object.keys(this._config.features).length
    });
  }
  
  /**
   * Get singleton instance
   */
  public static getInstance(): EnvironmentService {
    if (!EnvironmentService._instance) {
      EnvironmentService._instance = new EnvironmentService();
    }
    return EnvironmentService._instance;
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
    
    this._log.debug('Configuration loaded', { mode, apiUrls: config.apiUrls });
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
    
    // Vite environment - check for Vite-specific globals
    if (typeof globalThis !== 'undefined' && (globalThis as any).__VITE_DEV__) {
      return 'development';
    }
    
    // Check for common build environment variables
    if (typeof window !== 'undefined' && window.location.hostname.includes('vercel')) {
      return 'production';
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
    return this._config.mode;
  }
  
  /**
   * Check if running in development mode
   */
  public isDevelopment(): boolean {
    return this._config.mode === 'development';
  }
  
  /**
   * Check if running in production mode
   */
  public isProduction(): boolean {
    return this._config.mode === 'production';
  }
  
  /**
   * Check if running in test mode
   */
  public isTest(): boolean {
    return this._config.mode === 'test';
  }
  
  /**
   * Get API base URL for a service
   */
  public getApiUrl(service: string): string {
    const url = this._config.apiUrls[service];
    if (!url) {
      this._log.warn(`No API URL configured for service: ${service}`);
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
    return this._config.features[feature] ?? false;
  }
  
  /**
   * Get debug configuration
   */
  public getDebugConfig() {
    return this._config.debug;
  }
  
  /**
   * Get Bitcoin service configuration
   */
  public getBitcoinConfig(): IBitcoinConfig {
    return {
      name: 'bitcoin',
      debug: this._config.debug.enabled,
      monitoring: this._config.debug.performanceLogging,
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
      debug: this._config.debug.enabled,
      monitoring: this._config.debug.performanceLogging,
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
      debug: this._config.debug.enabled,
      monitoring: this._config.debug.performanceLogging,
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
    this._log.info('EnvironmentService disposed');
    EnvironmentService._instance = null;
  }
}

// Export singleton instance
export const environmentService = EnvironmentService.getInstance();
export { EnvironmentService };

