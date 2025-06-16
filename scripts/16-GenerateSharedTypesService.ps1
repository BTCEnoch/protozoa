# 16-GenerateSharedTypesService.ps1
# Generates comprehensive shared types and interfaces for cross-domain communication
# Addresses critical gap: Cross-domain shared types per audit requirements

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

Write-StepHeader "SHARED TYPES AND INTERFACES GENERATION"
Write-InfoLog "Generating cross-domain shared types for type safety and consistency"

# Validate project structure
try {
    Test-ProjectStructure -ProjectRoot $ProjectRoot -ErrorAction Stop
    Write-InfoLog "Project structure validation passed"
} catch {
    Write-ErrorLog "Project structure validation failed: $($_.Exception.Message)"
    exit 1
}

# Define shared types paths
$sharedTypesPath = Join-Path $ProjectRoot "src/shared/types"
$sharedLibPath = Join-Path $ProjectRoot "src/shared/lib"

Write-InfoLog "Shared types paths:"
Write-InfoLog "  Types: $sharedTypesPath"
Write-InfoLog "  Lib: $sharedLibPath"

# Create directories if they don't exist
$directories = @($sharedTypesPath, $sharedLibPath)
foreach ($dir in $directories) {
    if (-not (Test-Path $dir)) {
        Write-InfoLog "Creating directory: $dir"
        if (-not $WhatIf) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }
    }
}

# Generate Vector and Math Types
$vectorTypesContent = @"
/**
 * Vector and Mathematical Types
 * Shared vector and mathematical interfaces used across domains
 * Provides compatibility layer with THREE.js while maintaining domain independence
 */

/**
 * 3D Vector interface compatible with THREE.js Vector3
 * Used throughout particle, physics, formation, and rendering domains
 */
export interface IVector3 {
  x: number;
  y: number;
  z: number;
}

/**
 * 2D Vector interface for UI coordinates and planar calculations
 */
export interface IVector2 {
  x: number;
  y: number;
}

/**
 * Quaternion interface for 3D rotations
 * Compatible with THREE.js Quaternion
 */
export interface IQuaternion {
  x: number;
  y: number;
  z: number;
  w: number;
}

/**
 * Color interface with RGB and optional alpha
 */
export interface IColor {
  r: number;
  g: number;
  b: number;
  a?: number;
}

/**
 * Bounding box interface for collision detection and spatial queries
 */
export interface IBoundingBox {
  min: IVector3;
  max: IVector3;
}

/**
 * Transform interface combining position, rotation, and scale
 */
export interface ITransform {
  position: IVector3;
  rotation: IQuaternion;
  scale: IVector3;
}

/**
 * Range interface for numeric ranges with min/max bounds
 */
export interface IRange {
  min: number;
  max: number;
}

/**
 * Utility type for any vector-like object
 */
export type VectorLike = IVector3 | IVector2;

/**
 * Utility type for transformation matrices
 */
export type Matrix4Like = number[];
"@

Write-InfoLog "Writing vector types..."
if (-not $WhatIf) {
    Set-Content -Path (Join-Path $sharedTypesPath "vectorTypes.ts") -Value $vectorTypesContent -Encoding UTF8
}

# Generate Core Entity Types
$entityTypesContent = @"
/**
 * Core Entity Types
 * Base interfaces and types for all domain entities
 */

import { IVector3, IColor, ITransform } from './vectorTypes';

/**
 * Base entity interface that all domain entities should implement
 */
export interface IEntity {
  /** Unique identifier for the entity */
  id: string;
  /** Creation timestamp */
  createdAt: Date;
  /** Last update timestamp */
  updatedAt: Date;
  /** Entity type identifier */
  type: string;
}

/**
 * Particle entity representing a digital organism
 */
export interface IParticle extends IEntity {
  /** 3D position in world space */
  position: IVector3;
  /** Velocity vector for movement */
  velocity: IVector3;
  /** Visual color properties */
  color: IColor;
  /** Size/radius of the particle */
  size: number;
  /** Organism traits */
  traits: IOrganismTraits;
  /** Current formation group membership */
  groupId?: string;
  /** Active status */
  active: boolean;
}

/**
 * Formation pattern definition
 */
export interface IFormationPattern extends IEntity {
  /** Pattern name for reference */
  name: string;
  /** Array of relative positions for particles */
  positions: IVector3[];
  /** Optional metadata for pattern behavior */
  metadata?: Record<string, any>;
}

/**
 * Organism traits collection
 */
export interface IOrganismTraits {
  /** Visual appearance traits */
  visual: IVisualTraits;
  /** Behavioral characteristics */
  behavioral: IBehavioralTraits;
  /** Evolutionary properties */
  evolutionary: IEvolutionaryTraits;
  /** Mutation capabilities */
  mutation: IMutationTraits;
}

/**
 * Visual traits affecting appearance
 */
export interface IVisualTraits {
  color: string;
  shape: 'sphere' | 'cube' | 'tetrahedron' | 'octahedron';
  size: number;
  luminosity: number;
  pattern?: string;
}

/**
 * Behavioral traits affecting movement and interaction
 */
export interface IBehavioralTraits {
  aggressiveness: number; // 1-10 scale
  sociability: number; // 1-10 scale  
  energy: number; // 1-10 scale
  adaptability: number; // 1-10 scale
  curiosity: number; // 1-10 scale
}

/**
 * Evolutionary traits for organism development
 */
export interface IEvolutionaryTraits {
  generation: number;
  parentIds: string[];
  mutationRate: number;
  fitnessScore: number;
  lineageHash: string;
}

/**
 * Mutation traits controlling evolutionary changes
 */
export interface IMutationTraits {
  visualMutationChance: number;
  behavioralMutationChance: number;
  sizeMutationRange: IRange;
  colorMutationIntensity: number;
}

/**
 * Group entity for particle collections
 */
export interface IParticleGroup extends IEntity {
  /** Name of the group */
  name: string;
  /** Member particle IDs */
  memberIds: string[];
  /** Group formation pattern */
  formationId?: string;
  /** Group behavior settings */
  behavior: IGroupBehavior;
}

/**
 * Group behavior configuration
 */
export interface IGroupBehavior {
  cohesion: number;
  separation: number;
  alignment: number;
  maxSpeed: number;
  maxForce: number;
}
"@

Write-InfoLog "Writing entity types..."
if (-not $WhatIf) {
    Set-Content -Path (Join-Path $sharedTypesPath "entityTypes.ts") -Value $entityTypesContent -Encoding UTF8
}

# Generate Service Configuration Types
$configTypesContent = @"
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
"@

Write-InfoLog "Writing configuration types..."
if (-not $WhatIf) {
    Set-Content -Path (Join-Path $sharedTypesPath "configTypes.ts") -Value $configTypesContent -Encoding UTF8
}

# Generate Logging and Error Types
$loggingTypesContent = @"
/**
 * Logging and Error Types
 * Standardized logging and error handling interfaces
 */

/**
 * Log levels enum
 */
export enum LogLevel {
  DEBUG = 'debug',
  INFO = 'info',
  WARN = 'warn',
  ERROR = 'error'
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
  HEALTHY = 'healthy',
  DEGRADED = 'degraded',
  UNHEALTHY = 'unhealthy',
  UNKNOWN = 'unknown'
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
"@

Write-InfoLog "Writing logging types..."
if (-not $WhatIf) {
    Set-Content -Path (Join-Path $sharedTypesPath "loggingTypes.ts") -Value $loggingTypesContent -Encoding UTF8
}

# Generate Event Types for Domain Communication
$eventTypesContent = @"
/**
 * Event Types for Domain Communication
 * Standardized event interfaces for inter-domain messaging
 */

/**
 * Base event interface
 */
export interface IBaseEvent {
  /** Event type identifier */
  type: string;
  /** Event timestamp */
  timestamp: Date;
  /** Source domain/service */
  source: string;
  /** Event payload */
  payload: Record<string, any>;
  /** Correlation ID for tracking */
  correlationId?: string;
}

/**
 * Particle lifecycle events
 */
export interface IParticleEvent extends IBaseEvent {
  /** Particle ID */
  particleId: string;
}

export interface IParticleCreatedEvent extends IParticleEvent {
  type: 'particle.created';
  payload: {
    particle: import('./entityTypes').IParticle;
  };
}

export interface IParticleUpdatedEvent extends IParticleEvent {
  type: 'particle.updated';
  payload: {
    previousState: Partial<import('./entityTypes').IParticle>;
    currentState: import('./entityTypes').IParticle;
  };
}

export interface IParticleRemovedEvent extends IParticleEvent {
  type: 'particle.removed';
  payload: {
    reason: string;
  };
}

/**
 * Formation events
 */
export interface IFormationEvent extends IBaseEvent {
  /** Formation pattern ID */
  formationId: string;
}

export interface IFormationAppliedEvent extends IFormationEvent {
  type: 'formation.applied';
  payload: {
    particleIds: string[];
    pattern: import('./entityTypes').IFormationPattern;
  };
}

export interface IFormationTransitionEvent extends IFormationEvent {
  type: 'formation.transition';
  payload: {
    fromFormationId: string;
    toFormationId: string;
    progress: number;
  };
}

/**
 * Trait mutation events
 */
export interface ITraitMutationEvent extends IBaseEvent {
  type: 'trait.mutated';
  payload: {
    organismId: string;
    traitType: string;
    oldValue: any;
    newValue: any;
    mutationFactor: number;
  };
}

/**
 * Effect events
 */
export interface IEffectEvent extends IBaseEvent {
  /** Effect name */
  effectName: string;
}

export interface IEffectTriggeredEvent extends IEffectEvent {
  type: 'effect.triggered';
  payload: {
    targetIds: string[];
    duration: number;
    intensity: number;
  };
}

/**
 * Union type for all domain events
 */
export type DomainEvent = 
  | IParticleCreatedEvent
  | IParticleUpdatedEvent
  | IParticleRemovedEvent
  | IFormationAppliedEvent
  | IFormationTransitionEvent
  | ITraitMutationEvent
  | IEffectTriggeredEvent;

/**
 * Event handler function type
 */
export type EventHandler<T extends IBaseEvent = IBaseEvent> = (event: T) => void | Promise<void>;

/**
 * Event bus interface
 */
export interface IEventBus {
  /** Subscribe to events */
  subscribe<T extends IBaseEvent>(eventType: string, handler: EventHandler<T>): void;
  /** Unsubscribe from events */
  unsubscribe<T extends IBaseEvent>(eventType: string, handler: EventHandler<T>): void;
  /** Emit an event */
  emit<T extends IBaseEvent>(event: T): Promise<void>;
  /** Remove all listeners */
  removeAllListeners(): void;
}
"@

Write-InfoLog "Writing event types..."
if (-not $WhatIf) {
    Set-Content -Path (Join-Path $sharedTypesPath "eventTypes.ts") -Value $eventTypesContent -Encoding UTF8
}

# Generate index file for types
$indexContent = @"
/**
 * Shared Types Index
 * Central export point for all shared types and interfaces
 */

// Vector and mathematical types
export * from './vectorTypes';

// Core entity types
export * from './entityTypes';

// Service configuration types
export * from './configTypes';

// Logging and error types
export * from './loggingTypes';

// Event types for domain communication
export * from './eventTypes';
"@

Write-InfoLog "Writing types index..."
if (-not $WhatIf) {
    Set-Content -Path (Join-Path $sharedTypesPath "index.ts") -Value $indexContent -Encoding UTF8
}

Write-SuccessLog "Shared types generation completed!"

if (-not $WhatIf) {
    Write-InfoLog ""
    Write-InfoLog "Generated shared types:"
    Write-InfoLog "  ✅ vectorTypes.ts - Vector and mathematical interfaces"
    Write-InfoLog "  ✅ entityTypes.ts - Core domain entity definitions"
    Write-InfoLog "  ✅ configTypes.ts - Service configuration interfaces"
    Write-InfoLog "  ✅ loggingTypes.ts - Logging and error handling types"
    Write-InfoLog "  ✅ eventTypes.ts - Inter-domain event interfaces"
    Write-InfoLog "  ✅ index.ts - Central export point"
    Write-InfoLog ""
    Write-InfoLog "Critical Gap 'Shared Types/Interfaces Defined' has been RESOLVED!"
} 