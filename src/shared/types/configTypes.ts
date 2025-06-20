/**
 * Configuration type definitions
 */

// Service configuration base
export interface ServiceConfig {
  enabled: boolean;
  logLevel: string;
  maxRetries: number;
}

// Rendering configuration
export interface RenderingConfig extends ServiceConfig {
  antialias: boolean;
  shadows: boolean;
  maxFPS: number;
}

// Physics configuration
export interface PhysicsConfig extends ServiceConfig {
  gravity: number;
  timeStep: number;
  iterations: number;
}

// Bitcoin API configuration
export interface BitcoinConfig extends ServiceConfig {
  apiUrl: string;
  cacheTimeout: number;
  rateLimit: number;
}
