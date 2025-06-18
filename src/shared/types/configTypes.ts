/**
 * Service Configuration Types
 * Configuration interfaces for all domain services
 */

import { IVector3, IRange } from './vectorTypes';

/**
 * Base service configuration interface
 */
export interface IServiceConfig {
  /** Service name identifier */
  name: string;
  /** Enable debug logging */
  debug: boolean;
  /** Performance monitoring enabled */
  monitoring: boolean;
}

/**
 * Bitcoin service configuration
 */
export interface IBitcoinConfig extends IServiceConfig {
  /** API base URL (environment-specific) */
  apiBaseUrl: string;
  /** Rate limit requests per second */
  rateLimit: number;
  /** Cache TTL in milliseconds */
  cacheTtl: number;
  /** Maximum retry attempts */
  maxRetries: number;
  /** Request timeout in milliseconds */
  timeout: number;
}

/**
 * Physics service configuration
 */
export interface IPhysicsConfig extends IServiceConfig {
  /** Gravity acceleration constant */
  gravity: number;
  /** Time step for physics calculations */
  timeStep: number;
  /** Maximum velocity for particles */
  maxVelocity: number;
  /** Collision detection enabled */
  collisionDetection: boolean;
  /** Spatial partitioning grid size */
  gridSize: number;
}

/**
 * Rendering service configuration
 */
export interface IRenderingConfig extends IServiceConfig {
  /** Target frame rate */
  targetFps: number;
  /** Anti-aliasing enabled */
  antialias: boolean;
  /** Shadow mapping enabled */
  shadows: boolean;
  /** Maximum draw calls per frame */
  maxDrawCalls: number;
  /** Frustum culling enabled */
  frustumCulling: boolean;
}

/**
 * Animation service configuration
 */
export interface IAnimationConfig extends IServiceConfig {
  /** Default animation duration in milliseconds */
  defaultDuration: number;
  /** Easing function type */
  easingType: 'linear' | 'ease-in' | 'ease-out' | 'ease-in-out';
  /** Maximum concurrent animations */
  maxConcurrent: number;
  /** Animation loop enabled */
  loop: boolean;
}

/**
 * Formation service configuration
 */
export interface IFormationConfig extends IServiceConfig {
  /** Default formation radius */
  defaultRadius: number;
  /** Transition duration between formations */
  transitionDuration: number;
  /** Particle spacing factor */
  spacingFactor: number;
  /** Formation cache size limit */
  cacheLimit: number;
}

/**
 * Environment configuration
 */
export interface IEnvironmentConfig {
  /** Current environment mode */
  mode: 'development' | 'production' | 'test';
  /** API base URLs by environment */
  apiUrls: Record<string, string>;
  /** Feature flags */
  features: Record<string, boolean>;
  /** Debug settings */
  debug: {
    enabled: boolean;
    verbose: boolean;
    performanceLogging: boolean;
  };
}
