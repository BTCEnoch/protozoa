/**
 * @fileoverview IFormationService interface defining formation pattern management contracts
 * @module @/domains/formation/interfaces
 * @version 1.0.0
 *
 * Defines the contract for formation services that manage particle positioning patterns,
 * transitions between formations, and geometric calculations for organism arrangements.
 *
 * Reference: build_design.md Section 2 - Formation integration
 * Reference: .cursorrules Service Architecture Standards
 */

import { IVector3 } from "@/shared/types";

/**
 * Formation pattern definition containing positioning data and metadata
 * Used to define how particles should be arranged in 3D space
 */
export interface IFormationPattern {
  /** Unique identifier for the formation pattern */
  id: string;

  /** Human-readable name for the formation */
  name: string;

  /** Array of 3D positions for particle placement */
  positions: IVector3[];

  /** Maximum number of particles this formation supports */
  maxParticles: number;

  /** Formation type category (geometric, organic, custom) */
  type: "geometric" | "organic" | "custom";

  /** Optional metadata for formation behavior */
  metadata?: {
    /** Scaling factor for formation size */
    scale?: number;
    /** Rotation angles in radians */
    rotation?: IVector3;
    /** Animation properties for dynamic formations */
    animation?: {
      rotationSpeed?: number;
      pulseAmplitude?: number;
      pulseFrequency?: number;
    };
  };
}

/**
 * Configuration options for applying formations to particles
 */
export interface IFormationConfig {
  /** Target formation pattern identifier */
  patternId: string;

  /** Array of particle IDs to arrange */
  particleIds: string[];

  /** Transition duration in milliseconds */
  transitionDuration?: number;

  /** Easing function for smooth transitions */
  easingFunction?: "linear" | "easeIn" | "easeOut" | "easeInOut";

  /** Whether to maintain particle relative positions */
  preserveRelativePositions?: boolean;

  /** Custom scaling factor for this application */
  customScale?: number;
}

/**
 * Result of formation application containing success status and positioning data
 */
export interface IFormationResult {
  /** Whether the formation was successfully applied */
  success: boolean;

  /** Number of particles successfully positioned */
  particlesPositioned: number;

  /** Array of final particle positions */
  finalPositions: IVector3[];

  /** Any error messages if application failed */
  errorMessage?: string;

  /** Performance metrics for the operation */
  metrics?: {
    calculationTimeMs: number;
    memoryUsedBytes: number;
  };
}

/**
 * Interface defining the contract for Formation services
 * Manages particle positioning patterns, transitions, and geometric calculations
 *
 * Implements singleton pattern with dependency injection for cross-domain services
 * All methods include comprehensive logging and error handling
 */
export interface IFormationService {
  /**
   * Retrieves a formation pattern by its unique identifier
   * @param patternId - Unique identifier of the formation pattern
   * @returns Formation pattern if found, undefined otherwise
   * @throws Never throws - returns undefined for invalid patterns
   */
  getFormationPattern(patternId: string): IFormationPattern | undefined;

  /**
   * Applies a formation pattern to a set of particles
   * @param config - Configuration object containing pattern ID, particle IDs, and options
   * @returns Result object with success status and positioning data
   * @throws Never throws - errors are captured in result object
   */
  applyFormation(config: IFormationConfig): Promise<IFormationResult>;

  /**
   * Registers a new formation pattern in the service
   * @param pattern - Formation pattern definition to register
   * @returns True if registration successful, false if pattern ID already exists
   * @throws Never throws - duplicate IDs return false
   */
  registerFormationPattern(pattern: IFormationPattern): boolean;

  /**
   * Removes a formation pattern from the service
   * @param patternId - Unique identifier of pattern to remove
   * @returns True if pattern was removed, false if not found
   * @throws Never throws - missing patterns return false
   */
  unregisterFormationPattern(patternId: string): boolean;

  /**
   * Lists all available formation pattern identifiers
   * @returns Array of pattern IDs currently registered
   * @throws Never throws - returns empty array if no patterns
   */
  listAvailablePatterns(): string[];

  /**
   * Calculates optimal positions for a given number of particles in a pattern
   * @param patternId - Formation pattern to use for calculation
   * @param particleCount - Number of particles to position
   * @param options - Optional scaling and rotation parameters
   * @returns Array of calculated positions, empty array if pattern not found
   * @throws Never throws - invalid inputs return empty array
   */
  calculatePositions(
    patternId: string,
    particleCount: number,
    options?: { scale?: number; rotation?: IVector3 }
  ): IVector3[];

  /**
   * Validates that a formation pattern is properly structured
   * @param pattern - Formation pattern to validate
   * @returns Validation result with success flag and error details
   * @throws Never throws - validation errors returned in result
   */
  validateFormationPattern(pattern: IFormationPattern): {
    valid: boolean;
    errors: string[];
  };

  /**
   * Configures external service dependencies via dependency injection
   * @param dependencies - Object containing optional service references
   * @throws Never throws - missing dependencies logged as warnings
   */
  configureDependencies(dependencies: {
    physics?: any; // IPhysicsService when available
    rng?: any;     // IRNGService when available
    rendering?: any; // IRenderingService when available
  }): void;

  /**
   * Disposes of the formation service, clearing all data and resetting singleton
   * Implements proper resource cleanup to prevent memory leaks
   * @throws Never throws - cleanup always attempted
   */
  dispose(): void;
} 
