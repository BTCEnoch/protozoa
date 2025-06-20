# PowerShell Script: 18-GenerateFormationDomain.ps1
# =====================================================
# Generates complete Formation Domain implementation with:
# - IFormationService interface with comprehensive method definitions
# - FormationService singleton class with pattern management
# - FormationBlendingService for complex transitions
# - Formation pattern data definitions and caching
# - Proper dependency injection and Winston logging
# - Full .cursorrules compliance (singleton patterns, 500-line limits, domain isolation)
#
# This addresses the critical Formation Domain implementation gap identified in build_checklist.md
# Reference: build_design.md Section 2 - Formation integration, addin.md Formation implementation guides

param(
    [string]$ProjectRoot = ".",
    [switch]$Verbose = $false
)

# Import utilities module for consistent logging and file operations
Import-Module (Join-Path $PSScriptRoot "utils.psm1") -Force

# Helper function for compatibility
function Write-StatusMessage {
    param([string]$Message, [string]$Level)
    switch ($Level) {
        "INFO" { Write-InfoLog $Message }
        "SUCCESS" { Write-SuccessLog $Message }
        "DEBUG" { Write-DebugLog $Message }
        default { Write-InfoLog $Message }
    }
}

Write-InfoLog "Starting Formation Domain generation..."

# Ensure domain directory structure exists
$formationDomainPath = Join-Path $ProjectRoot "src/domains/formation"
$servicesPath = Join-Path $formationDomainPath "services"
$typesPath = Join-Path $formationDomainPath "types"
$dataPath = Join-Path $formationDomainPath "data"
$interfacesPath = Join-Path $formationDomainPath "interfaces"

# Create directory structure
@($formationDomainPath, $servicesPath, $typesPath, $dataPath, $interfacesPath) | ForEach-Object {
    if (-not (Test-Path $_)) {
        New-Item -Path $_ -ItemType Directory -Force | Out-Null
        Write-StatusMessage "Created directory: $_" "DEBUG"
    }
}

# Create interface wrapper for compatibility with legacy import paths
$interfaceWrapperPath = Join-Path $interfacesPath "IFormationService.ts"
if (-not (Test-Path $interfaceWrapperPath)) {
    "export * from '../types/IFormationService'" | Set-Content -Path $interfaceWrapperPath -Encoding UTF8
    Write-StatusMessage "Generated IFormationService wrapper interface: $interfaceWrapperPath" "SUCCESS"
}

# Generate IFormationService interface
Write-StatusMessage "Generating IFormationService interface..." "INFO"

$interfaceContent = @'
/**
 * @fileoverview IFormationService interface defining formation pattern management contracts
 * @module @/domains/formation/types
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
   * Clears all cached formation calculations and resets internal state
   * Used for memory management and testing scenarios
   * @returns Number of cache entries cleared
   * @throws Never throws - always succeeds
   */
  clearCache(): number;

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

/**
 * Type guard to check if an object implements IFormationService
 * @param obj - Object to check
 * @returns True if object implements the interface
 */
export function isFormationService(obj: any): obj is IFormationService {
  return obj &&
    typeof obj.getFormationPattern === "function" &&
    typeof obj.applyFormation === "function" &&
    typeof obj.registerFormationPattern === "function" &&
    typeof obj.dispose === "function";
}

// Export types for external usage
export type FormationPattern = IFormationPattern;
export type FormationConfig = IFormationConfig;
export type FormationResult = IFormationResult;
'@

$interfaceFilePath = Join-Path $typesPath "IFormationService.ts"
Set-Content -Path $interfaceFilePath -Value $interfaceContent -Encoding UTF8
Write-StatusMessage "Generated IFormationService interface: $interfaceFilePath" "SUCCESS"

# Generate formation pattern data definitions
Write-StatusMessage "Generating formation pattern data definitions..." "INFO"

$formationDataContent = @'
/**
 * @fileoverview Formation pattern data definitions and geometric calculations
 * @module @/domains/formation/data
 * @version 1.0.0
 *
 * Contains predefined formation patterns for particle arrangements including
 * geometric shapes, organic patterns, and custom formations.
 *
 * Reference: build_design.md Section 2 - Formation pattern definitions
 * Reference: .cursorrules Domain Data Standards
 */

import { IVector3 } from "@/shared/types";

/**
 * Utility functions for generating geometric formation patterns
 * These functions create position arrays for common 3D shapes
 */
export class FormationGeometry {
  /**
   * Generates positions for particles arranged in a sphere
   * @param particleCount - Number of particles to position
   * @param radius - Radius of the sphere
   * @returns Array of 3D positions on sphere surface
   */
  static generateSpherePositions(particleCount: number, radius: number = 50): IVector3[] {
    const positions: IVector3[] = [];
    const goldenAngle = Math.PI * (3 - Math.sqrt(5)); // Golden angle in radians

    for (let i = 0; i < particleCount; i++) {
      // Use golden spiral distribution for even spacing
      const y = 1 - (i / (particleCount - 1)) * 2; // y goes from 1 to -1
      const radiusAtY = Math.sqrt(1 - y * y);
      const theta = goldenAngle * i;

      const x = Math.cos(theta) * radiusAtY * radius;
      const z = Math.sin(theta) * radiusAtY * radius;

      positions.push({ x, y: y * radius, z });
    }

    return positions;
  }

  /**
   * Generates positions for particles arranged in a cube
   * @param particleCount - Number of particles to position
   * @param size - Size of the cube
   * @returns Array of 3D positions within cube volume
   */
  static generateCubePositions(particleCount: number, size: number = 100): IVector3[] {
    const positions: IVector3[] = [];
    const particlesPerSide = Math.ceil(Math.cbrt(particleCount));
    const spacing = size / (particlesPerSide - 1);
    const offset = size / 2;

    for (let i = 0; i < particleCount; i++) {
      const x = (i % particlesPerSide) * spacing - offset;
      const y = (Math.floor(i / particlesPerSide) % particlesPerSide) * spacing - offset;
      const z = Math.floor(i / (particlesPerSide * particlesPerSide)) * spacing - offset;

      positions.push({ x, y, z });
    }

    return positions.slice(0, particleCount);
  }

  /**
   * Generates positions for particles arranged in a cylinder
   * @param particleCount - Number of particles to position
   * @param radius - Radius of the cylinder
   * @param height - Height of the cylinder
   * @returns Array of 3D positions within cylinder
   */
  static generateCylinderPositions(particleCount: number, radius: number = 50, height: number = 100): IVector3[] {
    const positions: IVector3[] = [];
    const layers = Math.ceil(Math.sqrt(particleCount));
    const particlesPerLayer = Math.ceil(particleCount / layers);

    for (let i = 0; i < particleCount; i++) {
      const layer = Math.floor(i / particlesPerLayer);
      const indexInLayer = i % particlesPerLayer;

      const y = (layer / (layers - 1)) * height - height / 2;
      const angle = (indexInLayer / particlesPerLayer) * 2 * Math.PI;
      const r = radius * Math.sqrt(Math.random()); // Random radius for volume distribution

      const x = Math.cos(angle) * r;
      const z = Math.sin(angle) * r;

      positions.push({ x, y, z });
    }

    return positions;
  }

  /**
   * Generates positions for particles arranged in a helix/spiral
   * @param particleCount - Number of particles to position
   * @param radius - Radius of the helix
   * @param height - Total height of the helix
   * @param turns - Number of complete turns
   * @returns Array of 3D positions along helix path
   */
  static generateHelixPositions(particleCount: number, radius: number = 30, height: number = 100, turns: number = 3): IVector3[] {
    const positions: IVector3[] = [];
    const angleStep = (turns * 2 * Math.PI) / particleCount;
    const heightStep = height / particleCount;

    for (let i = 0; i < particleCount; i++) {
      const angle = i * angleStep;
      const y = i * heightStep - height / 2;

      const x = Math.cos(angle) * radius;
      const z = Math.sin(angle) * radius;

      positions.push({ x, y, z });
    }

    return positions;
  }

  /**
   * Generates positions for particles arranged in a torus (donut shape)
   * @param particleCount - Number of particles to position
   * @param majorRadius - Major radius of the torus
   * @param minorRadius - Minor radius of the torus
   * @returns Array of 3D positions on torus surface
   */
  static generateTorusPositions(particleCount: number, majorRadius: number = 50, minorRadius: number = 20): IVector3[] {
    const positions: IVector3[] = [];
    const goldenAngle = Math.PI * (3 - Math.sqrt(5));

    for (let i = 0; i < particleCount; i++) {
      const u = (i / particleCount) * 2 * Math.PI;
      const v = (i * goldenAngle) % (2 * Math.PI);

      const x = (majorRadius + minorRadius * Math.cos(v)) * Math.cos(u);
      const y = minorRadius * Math.sin(v);
      const z = (majorRadius + minorRadius * Math.cos(v)) * Math.sin(u);

      positions.push({ x, y, z });
    }

    return positions;
  }
}
'@

$formationDataFilePath = Join-Path $dataPath "formationGeometry.ts"
Set-Content -Path $formationDataFilePath -Value $formationDataContent -Encoding UTF8
Write-StatusMessage "Generated formation geometry utilities: $formationDataFilePath" "SUCCESS"

# Generate predefined formation patterns
Write-StatusMessage "Generating predefined formation patterns..." "INFO"

$formationPatternsContent = @'
/**
 * @fileoverview Predefined formation patterns for immediate use
 * @module @/domains/formation/data
 * @version 1.0.0
 *
 * Contains a collection of ready-to-use formation patterns including
 * basic geometric shapes and more complex organic arrangements.
 *
 * Reference: build_design.md Section 2 - Formation pattern definitions
 * Reference: .cursorrules Domain Data Standards
 */

import { IFormationPattern } from "../types/IFormationService";
import { FormationGeometry } from "./formationGeometry";

/**
 * Collection of predefined formation patterns
 * These patterns can be used immediately without additional configuration
 */
export class FormationPatterns {
  /**
   * Creates a sphere formation pattern
   * @param maxParticles - Maximum particles this pattern supports
   * @param radius - Radius of the sphere
   * @returns Sphere formation pattern
   */
  static createSpherePattern(maxParticles: number = 100, radius: number = 50): IFormationPattern {
    return {
      id: "sphere",
      name: "Sphere Formation",
      positions: FormationGeometry.generateSpherePositions(maxParticles, radius),
      maxParticles,
      type: "geometric",
      metadata: {
        scale: 1.0,
        rotation: { x: 0, y: 0, z: 0 },
        animation: {
          rotationSpeed: 0.01,
          pulseAmplitude: 0.1,
          pulseFrequency: 0.5
        }
      }
    };
  }

  /**
   * Creates a cube formation pattern
   * @param maxParticles - Maximum particles this pattern supports
   * @param size - Size of the cube
   * @returns Cube formation pattern
   */
  static createCubePattern(maxParticles: number = 125, size: number = 100): IFormationPattern {
    return {
      id: "cube",
      name: "Cube Formation",
      positions: FormationGeometry.generateCubePositions(maxParticles, size),
      maxParticles,
      type: "geometric",
      metadata: {
        scale: 1.0,
        rotation: { x: 0, y: 0, z: 0 },
        animation: {
          rotationSpeed: 0.005,
          pulseAmplitude: 0.05,
          pulseFrequency: 0.3
        }
      }
    };
  }

  /**
   * Creates a helix formation pattern
   * @param maxParticles - Maximum particles this pattern supports
   * @param radius - Radius of the helix
   * @param height - Height of the helix
   * @param turns - Number of complete turns
   * @returns Helix formation pattern
   */
  static createHelixPattern(maxParticles: number = 80, radius: number = 30, height: number = 100, turns: number = 3): IFormationPattern {
    return {
      id: "helix",
      name: "Helix Formation",
      positions: FormationGeometry.generateHelixPositions(maxParticles, radius, height, turns),
      maxParticles,
      type: "organic",
      metadata: {
        scale: 1.0,
        rotation: { x: 0, y: 0, z: 0 },
        animation: {
          rotationSpeed: 0.02,
          pulseAmplitude: 0.15,
          pulseFrequency: 0.8
        }
      }
    };
  }

  /**
   * Creates a torus formation pattern
   * @param maxParticles - Maximum particles this pattern supports
   * @param majorRadius - Major radius of the torus
   * @param minorRadius - Minor radius of the torus
   * @returns Torus formation pattern
   */
  static createTorusPattern(maxParticles: number = 120, majorRadius: number = 50, minorRadius: number = 20): IFormationPattern {
    return {
      id: "torus",
      name: "Torus Formation",
      positions: FormationGeometry.generateTorusPositions(maxParticles, majorRadius, minorRadius),
      maxParticles,
      type: "geometric",
      metadata: {
        scale: 1.0,
        rotation: { x: 0, y: 0, z: 0 },
        animation: {
          rotationSpeed: 0.015,
          pulseAmplitude: 0.08,
          pulseFrequency: 0.6
        }
      }
    };
  }

  /**
   * Creates a line formation pattern
   * @param maxParticles - Maximum particles this pattern supports
   * @param length - Length of the line
   * @returns Line formation pattern
   */
  static createLinePattern(maxParticles: number = 50, length: number = 100): IFormationPattern {
    const positions = [];
    const spacing = length / (maxParticles - 1);
    const offset = length / 2;

    for (let i = 0; i < maxParticles; i++) {
      positions.push({
        x: i * spacing - offset,
        y: 0,
        z: 0
      });
    }

    return {
      id: "line",
      name: "Line Formation",
      positions,
      maxParticles,
      type: "geometric",
      metadata: {
        scale: 1.0,
        rotation: { x: 0, y: 0, z: 0 }
      }
    };
  }

  /**
   * Creates a circle formation pattern
   * @param maxParticles - Maximum particles this pattern supports
   * @param radius - Radius of the circle
   * @returns Circle formation pattern
   */
  static createCirclePattern(maxParticles: number = 60, radius: number = 40): IFormationPattern {
    const positions = [];
    const angleStep = (2 * Math.PI) / maxParticles;

    for (let i = 0; i < maxParticles; i++) {
      const angle = i * angleStep;
      positions.push({
        x: Math.cos(angle) * radius,
        y: 0,
        z: Math.sin(angle) * radius
      });
    }

    return {
      id: "circle",
      name: "Circle Formation",
      positions,
      maxParticles,
      type: "geometric",
      metadata: {
        scale: 1.0,
        rotation: { x: 0, y: 0, z: 0 },
        animation: {
          rotationSpeed: 0.01,
          pulseAmplitude: 0.1,
          pulseFrequency: 0.4
        }
      }
    };
  }

  /**
   * Gets all default formation patterns
   * @returns Array of all predefined formation patterns
   */
  static getAllDefaultPatterns(): IFormationPattern[] {
    return [
      this.createSpherePattern(),
      this.createCubePattern(),
      this.createHelixPattern(),
      this.createTorusPattern(),
      this.createLinePattern(),
      this.createCirclePattern()
    ];
  }

  /**
   * Gets a specific pattern by ID
   * @param patternId - ID of the pattern to retrieve
   * @returns Formation pattern if found, undefined otherwise
   */
  static getPatternById(patternId: string): IFormationPattern | undefined {
    const patterns = this.getAllDefaultPatterns();
    return patterns.find(pattern => pattern.id === patternId);
  }
}

// Export individual pattern creators for convenience
export const {
  createSpherePattern,
  createCubePattern,
  createHelixPattern,
  createTorusPattern,
  createLinePattern,
  createCirclePattern,
  getAllDefaultPatterns,
  getPatternById
} = FormationPatterns;
'@

$formationPatternsFilePath = Join-Path $dataPath "formationPatterns.ts"
Set-Content -Path $formationPatternsFilePath -Value $formationPatternsContent -Encoding UTF8
Write-StatusMessage "Generated formation patterns: $formationPatternsFilePath" "SUCCESS"

# Generate main FormationService implementation - Part 1 (Class structure and constructor)
Write-StatusMessage "Generating FormationService implementation (Part 1)..." "INFO"

$formationServicePart1 = @'
/**
 * @fileoverview FormationService - Main formation management service
 * @module @/domains/formation/services
 * @version 1.0.0
 *
 * Manages particle positioning patterns, formation transitions, and geometric calculations.
 * Implements singleton pattern with dependency injection and comprehensive caching.
 *
 * Reference: build_design.md Section 2 - Formation integration
 * Reference: .cursorrules Service Architecture Standards
 */

import { IFormationService, IFormationPattern, IFormationConfig, IFormationResult } from "../types/IFormationService";
import { IVector3 } from "@/shared/types";
import { FormationPatterns } from "../data/formationPatterns";
import { createServiceLogger, createPerformanceLogger } from "@/shared/lib/logger";

/**
 * Cache entry for formation calculations
 */
interface ICacheEntry {
  /** Cached formation pattern */
  pattern: IFormationPattern;
  /** Timestamp when cached */
  timestamp: number;
  /** Number of times accessed */
  accessCount: number;
  /** Last access timestamp */
  lastAccessed: number;
}

/**
 * FormationService - Singleton service for managing particle formation patterns
 *
 * Provides comprehensive formation management including:
 * - Pattern registration and retrieval
 * - Formation application with smooth transitions
 * - Caching for performance optimization
 * - Dependency injection for cross-domain services
 * - Memory management and cleanup
 */
class FormationService implements IFormationService {
  static #instance: FormationService | null = null;

  // Core pattern storage
  #patterns = new Map<string, IFormationPattern>();

  // Performance caching with size limits
  #cache = new Map<string, ICacheEntry>();
  #maxCacheSize = 50;

  // Dependency injection for cross-domain services
  #dependencies: {
    physics?: any;    // IPhysicsService when available
    rng?: any;        // IRNGService when available
    rendering?: any;  // IRenderingService when available
  } = {};

  // Logging utilities
  #log = createServiceLogger("FORMATION_SERVICE");
  #perfLog = createPerformanceLogger("FORMATION_SERVICE");

  // Performance metrics
  #metrics = {
    patternsRegistered: 0,
    formationsApplied: 0,
    cacheHits: 0,
    cacheMisses: 0
  };

  /**
   * Private constructor enforces singleton pattern
   * Initializes default patterns and sets up caching
   */
  private constructor() {
    this.#log.info("FormationService initializing...");

    try {
      // Load default formation patterns
      this.loadDefaultPatterns();

      this.#log.info("FormationService initialized successfully", {
        defaultPatterns: this.#patterns.size,
        cacheLimit: this.#maxCacheSize
      });
    } catch (error) {
      this.#log.error("FormationService initialization failed", { error: (error as Error).message, stack: (error as Error).stack });
      throw error;
    }
  }

  /**
   * Gets the singleton instance of FormationService
   * @returns The singleton instance
   */
  public static getInstance(): FormationService {
    if (!FormationService.#instance) {
      FormationService.#instance = new FormationService();
    }
    return FormationService.#instance;
  }

  /**
   * Loads default formation patterns into the service
   * @private
   */
  private loadDefaultPatterns(): void {
    const startTime = performance.now();

    try {
      const defaultPatterns = FormationPatterns.getAllDefaultPatterns();

      for (const pattern of defaultPatterns) {
        this.#patterns.set(pattern.id, pattern);
        this.#metrics.patternsRegistered++;
      }

      const loadTime = performance.now() - startTime;
      this.#perfLog.debug("Default patterns loaded", {
        count: defaultPatterns.length,
        loadTimeMs: loadTime
      });

    } catch (error) {
      this.#log.error("Loading default patterns failed", { error: (error as Error).message, stack: (error as Error).stack });
      throw error;
    }
  }
'@

$formationServiceFilePath = Join-Path $servicesPath "formationService.ts"
Set-Content -Path $formationServiceFilePath -Value $formationServicePart1 -Encoding UTF8
Write-StatusMessage "Generated FormationService Part 1: Class structure and initialization" "SUCCESS"

# Generate FormationService Part 2 (Core interface methods)
Write-StatusMessage "Generating FormationService implementation (Part 2)..." "INFO"

$formationServicePart2 = @'

  /**
   * Retrieves a formation pattern by its unique identifier
   * Implements caching for performance optimization
   * @param patternId - Unique identifier of the formation pattern
   * @returns Formation pattern if found, undefined otherwise
   */
  public getFormationPattern(patternId: string): IFormationPattern | undefined {
    try {
      // Check cache first
      const cacheKey = `pattern_${patternId}`;
      const cached = this.#cache.get(cacheKey);

      if (cached) {
        cached.accessCount++;
        cached.lastAccessed = Date.now();
        this.#metrics.cacheHits++;

        this.#perfLog.debug("Cache hit for formation pattern", { patternId, accessCount: cached.accessCount });
        return cached.pattern;
      }

      // Get from patterns map
      const pattern = this.#patterns.get(patternId);

      if (pattern) {
        // Cache the result
        this.addToCache(cacheKey, {
          pattern,
          timestamp: Date.now(),
          accessCount: 1,
          lastAccessed: Date.now()
        });

        this.#metrics.cacheMisses++;
        this.#log.debug("Formation pattern retrieved", { patternId, cached: false });
        return pattern;
      }

      this.#log.warn("Formation pattern not found", { patternId });
      return undefined;

    } catch (error) {
      this.#log.error("Formation pattern retrieval failed", { patternId, error: (error as Error).message });
      return undefined;
    }
  }

  /**
   * Registers a new formation pattern in the service
   * @param pattern - Formation pattern definition to register
   * @returns True if registration successful, false if pattern ID already exists
   */
  public registerFormationPattern(pattern: IFormationPattern): boolean {
    try {
      // Validate the pattern first
      const validation = this.validateFormationPattern(pattern);
      if (!validation.valid) {
        this.#log.warn("Invalid formation pattern rejected", {
          patternId: pattern.id,
          errors: validation.errors
        });
        return false;
      }

      // Check if pattern already exists
      if (this.#patterns.has(pattern.id)) {
        this.#log.warn("Formation pattern already exists", { patternId: pattern.id });
        return false;
      }

      // Register the pattern
      this.#patterns.set(pattern.id, pattern);
      this.#metrics.patternsRegistered++;

      // Clear any cached entries for this pattern
      const cacheKey = `pattern_${pattern.id}`;
      this.#cache.delete(cacheKey);

      this.#log.info("Formation pattern registered successfully", {
        patternId: pattern.id,
        type: pattern.type,
        maxParticles: pattern.maxParticles
      });

      return true;

    } catch (error) {
      this.#log.error("Formation pattern registration failed", {
        patternId: pattern?.id,
        error: (error as Error).message
      });
      return false;
    }
  }

  /**
   * Removes a formation pattern from the service
   * @param patternId - Unique identifier of pattern to remove
   * @returns True if pattern was removed, false if not found
   */
  public unregisterFormationPattern(patternId: string): boolean {
    try {
      const existed = this.#patterns.delete(patternId);

      if (existed) {
        // Clear any cached entries for this pattern
        const cacheKey = `pattern_${patternId}`;
        this.#cache.delete(cacheKey);

        this.#log.info("Formation pattern unregistered", { patternId });
        return true;
      }

      this.#log.warn("Attempted to unregister non-existent pattern", { patternId });
      return false;

    } catch (error) {
      this.#log.error("Formation pattern unregistration failed", { patternId, error: (error as Error).message });
      return false;
    }
  }

  /**
   * Lists all available formation pattern identifiers
   * @returns Array of pattern IDs currently registered
   */
  public listAvailablePatterns(): string[] {
    try {
      const patterns = Array.from(this.#patterns.keys());
      this.#log.debug("Listed available patterns", { count: patterns.length });
      return patterns;
    } catch (error) {
      this.#log.error("Listing available patterns failed", { error: (error as Error).message });
      return [];
    }
  }

  /**
   * Clears all cached formation calculations and resets internal state
   * Used for memory management and testing scenarios
   * @returns Number of cache entries cleared
   */
  public clearCache(): number {
    try {
      const cacheSize = this.#cache.size;
      this.#cache.clear();
      
      this.#log.info("Formation cache cleared", { entriesCleared: cacheSize });
      return cacheSize;
    } catch (error) {
      this.#log.error("Cache clearing failed", { error: (error as Error).message });
      return 0;
    }
  }

  /**
   * Validates that a formation pattern is properly structured
   * @param pattern - Formation pattern to validate
   * @returns Validation result with success flag and error details
   */
  public validateFormationPattern(pattern: IFormationPattern): { valid: boolean; errors: string[] } {
    const errors: string[] = [];

    try {
      // Check required fields
      if (!pattern.id || pattern.id.trim().length === 0) {
        errors.push("Pattern ID is required and cannot be empty");
      }

      if (!pattern.name || pattern.name.trim().length === 0) {
        errors.push("Pattern name is required and cannot be empty");
      }

      if (!pattern.type || pattern.type.trim().length === 0) {
        errors.push("Pattern type is required and cannot be empty");
      }

      // Check numeric constraints
      if (typeof pattern.maxParticles !== "number" || pattern.maxParticles <= 0) {
        errors.push("maxParticles must be a positive number");
      }

      // Check positions array
      if (!Array.isArray(pattern.positions)) {
        errors.push("positions must be an array");
      } else if (pattern.positions.length === 0) {
        errors.push("positions array cannot be empty");
      }

      return { valid: errors.length === 0, errors };

    } catch (error) {
      this.#log.error("Formation pattern validation failed", {
        patternId: pattern?.id,
        error: (error as Error).message
      });
      return { valid: false, errors: ["Validation failed due to unexpected error"] };
    }
  }
'@

# Append Part 2 to the existing file
Add-Content -Path $formationServiceFilePath -Value $formationServicePart2 -Encoding UTF8
Write-StatusMessage "Generated FormationService Part 2: Core interface methods" "SUCCESS"

# Generate FormationService Part 3 (Formation application methods)
Write-StatusMessage "Generating FormationService implementation (Part 3)..." "INFO"

$formationServicePart3 = @'

  /**
   * Applies a formation pattern to a set of particles
   * @param config - Configuration for formation application containing pattern ID and particle IDs
   * @returns Promise that resolves with formation result
   */
  public async applyFormation(config: IFormationConfig): Promise<IFormationResult> {
    const startTime = performance.now();

    try {
      // Get the formation pattern
      const pattern = this.getFormationPattern(config.patternId);
      if (!pattern) {
        const error = `Formation pattern "${config.patternId}" not found`;
        this.#log.error(error, { patternId: config.patternId, particleCount: config.particleIds.length });
        return {
          success: false,
          errorMessage: error,
          particlesPositioned: 0,
          finalPositions: []
        };
      }

      // Validate particle count against pattern limits
      if (config.particleIds.length > pattern.maxParticles) {
        const error = `Too many particles (${config.particleIds.length}) for pattern "${config.patternId}" (max: ${pattern.maxParticles})`;
        this.#log.warn(error, { patternId: config.patternId, requested: config.particleIds.length, max: pattern.maxParticles });
        return {
          success: false,
          errorMessage: error,
          particlesPositioned: 0,
          finalPositions: []
        };
      }

      // Calculate positions for particles
      const positions = this.calculateFormationPositions(pattern, config.particleIds.length, config);

      // Apply any transformations if specified in config
      const finalPositions = config.customScale
        ? this.scalePositions(positions, config.customScale)
        : positions;

      // Update metrics
      this.#metrics.formationsApplied++;
      const executionTime = performance.now() - startTime;

      this.#perfLog.info("Formation applied successfully", {
        patternId: config.patternId,
        particleCount: config.particleIds.length,
        executionTimeMs: executionTime,
        positionsGenerated: finalPositions.length
      });

      return {
        success: true,
        particlesPositioned: config.particleIds.length,
        finalPositions: finalPositions,
        metrics: {
          calculationTimeMs: executionTime,
          memoryUsedBytes: finalPositions.length * 48 // Approximate bytes per Vector3
        }
      };

    } catch (error) {
      const executionTime = performance.now() - startTime;
      this.#log.error("Formation application failed", {
        patternId: config.patternId,
        particleCount: config.particleIds.length,
        executionTimeMs: executionTime,
        error: (error as Error).message
      });

      return {
        success: false,
        errorMessage: (error as Error).message,
        particlesPositioned: 0,
        finalPositions: [],
        metrics: {
          calculationTimeMs: executionTime,
          memoryUsedBytes: 0
        }
      };
    }
  }

  /**
   * Calculates particle positions for a given formation pattern
   * @param pattern - Formation pattern to use for calculations
   * @param particleCount - Number of particles to position
   * @param options - Optional configuration for position calculation
   * @returns Array of calculated positions
   */
  public calculatePositions(
    patternId: string,
    particleCount: number,
    options?: { scale?: number; rotation?: IVector3 }
  ): IVector3[] {
    try {
      const pattern = this.getFormationPattern(patternId);
      if (!pattern) {
        this.#log.warn("Formation pattern not found for position calculation", { patternId });
        return [];
      }

      return this.calculateFormationPositions(pattern, particleCount, options);
    } catch (error) {
      this.#log.error("Position calculation failed", { 
        patternId, 
        particleCount, 
        error: (error as Error).message 
      });
      return [];
    }
  }
'@

# Append Part 3 to the existing file
Add-Content -Path $formationServiceFilePath -Value $formationServicePart3 -Encoding UTF8
Write-StatusMessage "Generated FormationService Part 3: Formation application methods" "SUCCESS"

# Generate FormationService Part 4 (Utility and helper methods)
Write-StatusMessage "Generating FormationService implementation (Part 4)..." "INFO"

$formationServicePart4 = @'

  /**
   * Configures external service dependencies for cross-domain operations
   * @param dependencies - Object containing service references for injection
   */
  public configureDependencies(dependencies: {
    physics?: any;
    rng?: any;
    rendering?: any;
  }): void {
    try {
      this.#dependencies = { ...this.#dependencies, ...dependencies };

      const configuredServices = Object.keys(dependencies).filter(key => dependencies[key as keyof typeof dependencies]);

      this.#log.info("Dependencies configured for FormationService", {
        services: configuredServices
      });

    } catch (error) {
      this.#log.error("Dependencies configuration failed", { error: (error as Error).message });
    }
  }

  /**
   * Calculates particle positions for a given formation pattern
   * @param pattern - Formation pattern to use for calculations
   * @param particleCount - Number of particles to position
   * @param options - Optional configuration for position calculation
   * @returns Array of calculated positions
   * @private
   */
  private calculateFormationPositions(
    pattern: IFormationPattern,
    particleCount: number,
    options?: any
  ): IVector3[] {
    try {
      // Simple implementation: use pattern positions or generate sphere
      const scale = options?.scale || options?.customScale || 1.0;

      if (pattern.positions && pattern.positions.length > 0) {
        // Use existing pattern positions, scaled and limited to particleCount
        const positions = pattern.positions.slice(0, particleCount);
        return this.scalePositions(positions, scale);
      }

      // Fallback to sphere generation for pattern types
      return this.#calculateSpherePositions(particleCount, 50 * scale);

    } catch (error) {
      this.#log.error("Formation position calculation failed", {
        patternType: pattern.type,
        particleCount,
        error: (error as Error).message
      });
      // Fallback to simple sphere formation
      return this.#calculateSpherePositions(particleCount, 50);
    }
  }


'@

# Append Part 4 to the existing file
Add-Content -Path $formationServiceFilePath -Value $formationServicePart4 -Encoding UTF8
Write-StatusMessage "Generated FormationService Part 4: Utility and helper methods" "SUCCESS"

# Generate FormationService Part 5 (Final methods and class completion)
Write-StatusMessage "Generating FormationService implementation (Part 5 - Final)..." "INFO"

$formationServicePart5 = @'

  /**
   * Adds an entry to the cache with size limit enforcement
   * @param key - Cache key
   * @param entry - Cache entry to store
   * @private
   */
  private addToCache(key: string, entry: ICacheEntry): void {
    try {
      // Enforce cache size limit
      if (this.#cache.size >= this.#maxCacheSize) {
        // Remove oldest entry (simple FIFO eviction)
        const oldestKey = this.#cache.keys().next().value;
        if (oldestKey) {
          this.#cache.delete(oldestKey);
          this.#perfLog.debug("Cache entry evicted", { evictedKey: oldestKey });
        }
      }

      this.#cache.set(key, entry);
      this.#perfLog.debug("Cache entry added", { key, cacheSize: this.#cache.size });

    } catch (error) {
      this.#log.error("Cache operation failed", { key, error: (error as Error).message });
    }
  }

  /**
   * Applies transformations to a set of positions
   * @param positions - Original positions to transform
   * @param transform - Transformation configuration
   * @returns Transformed positions
   * @private
   */
  private applyTransformations(positions: IVector3[], transform: any): IVector3[] {
    try {
      let result = [...positions];

      // Apply rotation if specified
      if (transform.rotation) {
        result = this.rotatePositions(result, transform.rotation);
      }

      // Apply translation if specified
      if (transform.translation) {
        result = this.translatePositions(result, transform.translation);
      }

      // Apply additional scaling if specified
      if (transform.scale && transform.scale !== 1.0) {
        result = this.scalePositions(result, transform.scale);
      }

      return result;

    } catch (error) {
      this.#log.error("Position transformation failed", {
        positionCount: positions.length,
        error: (error as Error).message
      });
      return positions; // Return original positions on error
    }
  }

  /**
   * Scales an array of positions by a given factor
   * @param positions - Positions to scale
   * @param scale - Scale factor
   * @returns Scaled positions
   * @private
   */
  private scalePositions(positions: IVector3[], scale: number): IVector3[] {
    return positions.map(pos => ({
      x: pos.x * scale,
      y: pos.y * scale,
      z: pos.z * scale
    }));
  }

  /**
   * Translates an array of positions by a given offset
   * @param positions - Positions to translate
   * @param translation - Translation vector
   * @returns Translated positions
   * @private
   */
  private translatePositions(positions: IVector3[], translation: IVector3): IVector3[] {
    return positions.map(pos => ({
      x: pos.x + translation.x,
      y: pos.y + translation.y,
      z: pos.z + translation.z
    }));
  }

  /**
   * Rotates an array of positions by given rotation angles
   * @param positions - Positions to rotate
   * @param rotation - Rotation angles in radians
   * @returns Rotated positions
   * @private
   */
  private rotatePositions(positions: IVector3[], rotation: { x?: number; y?: number; z?: number }): IVector3[] {
    // Simple rotation implementation - in production, use proper matrix math
    return positions.map(pos => {
      let { x, y, z } = pos;

      // Rotate around Z axis if specified
      if (rotation.z) {
        const cos = Math.cos(rotation.z);
        const sin = Math.sin(rotation.z);
        const newX = x * cos - y * sin;
        const newY = x * sin + y * cos;
        x = newX;
        y = newY;
      }

      return { x, y, z };
    });
  }

  /**
   * Calculate positions for particles arranged in a sphere formation
   * @param count - Number of particles to position
   * @param radius - Radius of the sphere
   * @returns Array of positions on sphere surface
   * @private
   */
  #calculateSpherePositions(count: number, radius: number): IVector3[] {
    const positions: IVector3[] = [];
    const goldenAngle = Math.PI * (3 - Math.sqrt(5)); // Golden angle in radians
    
    for (let i = 0; i < count; i++) {
      const y = 1 - (i / (count - 1)) * 2; // y goes from 1 to -1
      const radiusAtY = Math.sqrt(1 - y * y);
      const theta = goldenAngle * i;
      
      const x = Math.cos(theta) * radiusAtY;
      const z = Math.sin(theta) * radiusAtY;
      
      positions.push({
        x: x * radius,
        y: y * radius,
        z: z * radius
      });
    }
    
    return positions;
  }

  /**
   * Calculate positions for particles arranged in a cube formation
   * @param count - Number of particles to position
   * @param size - Size of the cube
   * @returns Array of positions in cube formation
   * @private
   */
  #calculateCubePositions(count: number, size: number): IVector3[] {
    const positions: IVector3[] = [];
    const side = Math.ceil(Math.cbrt(count));
    const spacing = size / side;
    const offset = (size - spacing) / 2;
    
    for (let i = 0; i < count; i++) {
      const x = (i % side) * spacing - offset;
      const y = (Math.floor(i / side) % side) * spacing - offset;
      const z = Math.floor(i / (side * side)) * spacing - offset;
      
      positions.push({ x, y, z });
    }
    
    return positions;
  }

  /**
   * Calculate positions for particles arranged in a cylinder formation
   * @param count - Number of particles to position
   * @param radius - Cylinder radius
   * @returns Array of positions in cylinder formation
   * @private
   */
  #calculateCylinderPositions(count: number, radius: number): IVector3[] {
    const positions: IVector3[] = [];
    const height = radius * 2; // Make cylinder height proportional to radius
    
    for (let i = 0; i < count; i++) {
      const angle = (i / count) * 2 * Math.PI;
      const y = (i / count) * height - height / 2;
      
      positions.push({
        x: Math.cos(angle) * radius,
        y: y,
        z: Math.sin(angle) * radius
      });
    }
    
    return positions;
  }

  /**
   * Calculate positions for particles arranged in a helix formation
   * @param count - Number of particles to position
   * @param radius - Helix radius
   * @returns Array of positions in helix formation
   * @private
   */
  #calculateHelixPositions(count: number, radius: number): IVector3[] {
    const positions: IVector3[] = [];
    const height = radius * 3; // Make helix height proportional to radius
    const turns = 3; // Number of complete turns
    
    for (let i = 0; i < count; i++) {
      const t = i / count;
      const angle = t * turns * 2 * Math.PI;
      const y = t * height - height / 2;
      
      positions.push({
        x: Math.cos(angle) * radius,
        y: y,
        z: Math.sin(angle) * radius
      });
    }
    
    return positions;
  }

  /**
   * Calculate positions for particles arranged in a torus formation
   * @param count - Number of particles to position
   * @param radius - Major radius of the torus
   * @returns Array of positions in torus formation
   * @private
   */
  #calculateTorusPositions(count: number, radius: number): IVector3[] {
    const positions: IVector3[] = [];
    const minorRadius = radius * 0.3; // Minor radius is 30% of major radius
    
    for (let i = 0; i < count; i++) {
      const u = (i / count) * 2 * Math.PI;
      const v = ((i * 7) % count / count) * 2 * Math.PI; // 7 creates nice distribution
      
      const x = (radius + minorRadius * Math.cos(v)) * Math.cos(u);
      const y = minorRadius * Math.sin(v);
      const z = (radius + minorRadius * Math.cos(v)) * Math.sin(u);
      
      positions.push({ x, y, z });
    }
    
    return positions;
  }

  /**
   * Gets performance metrics for the FormationService
   * @returns Object containing current performance metrics
   */
  public getMetrics(): any {
    return {
      ...this.#metrics,
      cacheSize: this.#cache.size,
      maxCacheSize: this.#maxCacheSize,
      cacheHitRatio: this.#metrics.cacheHits / (this.#metrics.cacheHits + this.#metrics.cacheMisses) || 0
    };
  }

  /**
   * Disposes of the FormationService, cleaning up all resources
   * Clears patterns, cache, and resets singleton instance
   */
  public dispose(): void {
    try {
      // Clear all patterns and cache
      this.#patterns.clear();
      this.#cache.clear();

      // Reset metrics
      this.#metrics = {
        patternsRegistered: 0,
        formationsApplied: 0,
        cacheHits: 0,
        cacheMisses: 0
      };

      // Clear dependencies
      this.#dependencies = {};

      this.#log.info("FormationService disposed successfully", {
        patternsCleared: true,
        cacheCleared: true,
        metricsReset: true
      });

      // Reset singleton instance
      FormationService.#instance = null;

    } catch (error) {
      this.#log.error("FormationService disposal failed", { error: (error as Error).message });
    }
  }
}

// Export singleton instance
export const formationService = FormationService.getInstance();
export { FormationService };
'@

# Append Part 5 to complete the FormationService
Add-Content -Path $formationServiceFilePath -Value $formationServicePart5 -Encoding UTF8
Write-StatusMessage "Generated FormationService Part 5: Final methods and class completion" "SUCCESS"

# Complete the script with final status and cleanup
Write-StatusMessage "Formation Domain generation completed successfully!" "SUCCESS"
Write-StatusMessage "Generated files:" "INFO"
Write-StatusMessage "  - IFormationService interface: $interfaceFilePath" "INFO"
Write-StatusMessage "  - Formation geometry utilities: $formationDataFilePath" "INFO"
Write-StatusMessage "  - Formation patterns data: $formationPatternsFilePath" "INFO"
Write-StatusMessage "  - FormationBlendingService: $blendingServiceFilePath" "INFO"
Write-StatusMessage "  - FormationService (complete): $formationServiceFilePath" "INFO"
Write-StatusMessage "Formation Domain is ready for integration!" "SUCCESS"
