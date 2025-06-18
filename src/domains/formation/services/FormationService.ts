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
import { formationBlendingService } from "./formationBlendingService";
import { createServiceLogger, createPerformanceLogger, createErrorLogger } from "@/shared/lib/logger";

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
  #errorLog = createErrorLogger("FORMATION_SERVICE");

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
      this.#errorLog.logError(error as Error, { context: "FormationService initialization" });
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
      this.#errorLog.logError(error as Error, { context: "Loading default patterns" });
      throw error;
    }
  }

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
      this.#errorLog.logError(error as Error, { patternId, context: "getFormationPattern" });
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
      this.#errorLog.logError(error as Error, {
        patternId: pattern?.id,
        context: "registerFormationPattern"
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
      this.#errorLog.logError(error as Error, { patternId, context: "unregisterFormationPattern" });
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
      this.#errorLog.logError(error as Error, { context: "listAvailablePatterns" });
      return [];
    }
  }

  /**
   * Applies a formation pattern to a set of particles
   * @param patternId - Identifier of the formation pattern to apply
   * @param particleIds - Array of particle IDs to arrange in formation
   * @param config - Optional configuration for formation application
   * @returns Result of formation application including success status and positions
   */
  public applyFormation(patternId: string, particleIds: string[], config?: IFormationConfig): IFormationResult {
    const startTime = performance.now();

    try {
      // Get the formation pattern
      const pattern = this.getFormationPattern(patternId);
      if (!pattern) {
        const error = `Formation pattern "${patternId}" not found`;
        this.#log.error(error, { patternId, particleCount: particleIds.length });
        return {
          success: false,
          error,
          patternId,
          particleCount: particleIds.length,
          positions: []
        };
      }

      // Validate particle count against pattern limits
      if (particleIds.length > pattern.maxParticles) {
        const error = `Too many particles (${particleIds.length}) for pattern "${patternId}" (max: ${pattern.maxParticles})`;
        this.#log.warn(error, { patternId, requested: particleIds.length, max: pattern.maxParticles });
        return {
          success: false,
          error,
          patternId,
          particleCount: particleIds.length,
          positions: []
        };
      }

      // Calculate positions for particles
      const positions = this.calculateFormationPositions(pattern, particleIds.length, config);

      // Apply any transformations if specified in config
      const finalPositions = config?.transform
        ? this.applyTransformations(positions, config.transform)
        : positions;

      // Update metrics
      this.#metrics.formationsApplied++;
      const executionTime = performance.now() - startTime;

      this.#perfLog.info("Formation applied successfully", {
        patternId,
        particleCount: particleIds.length,
        executionTimeMs: executionTime,
        positionsGenerated: finalPositions.length
      });

      return {
        success: true,
        patternId,
        particleCount: particleIds.length,
        positions: finalPositions,
        executionTimeMs: executionTime
      };

    } catch (error) {
      const executionTime = performance.now() - startTime;
      this.#errorLog.logError(error as Error, {
        patternId,
        particleCount: particleIds.length,
        executionTimeMs: executionTime,
        context: "applyFormation"
      });

      return {
        success: false,
        error: (error as Error).message,
        patternId,
        particleCount: particleIds.length,
        positions: [],
        executionTimeMs: executionTime
      };
    }
  }

  /**
   * Creates a smooth transition between two formation patterns
   * @param fromPatternId - Source formation pattern ID
   * @param toPatternId - Target formation pattern ID
   * @param particleIds - Array of particle IDs to transition
   * @param transitionConfig - Configuration for the transition
   * @returns Promise that resolves when transition is complete
   */
  public async transitionFormation(
    fromPatternId: string,
    toPatternId: string,
    particleIds: string[],
    transitionConfig?: any
  ): Promise<IFormationResult> {
    try {
      this.#log.info("Starting formation transition", {
        from: fromPatternId,
        to: toPatternId,
        particleCount: particleIds.length
      });

      // Get both patterns
      const fromPattern = this.getFormationPattern(fromPatternId);
      const toPattern = this.getFormationPattern(toPatternId);

      if (!fromPattern || !toPattern) {
        const error = `Missing formation pattern(s): from=${!fromPattern}, to=${!toPattern}`;
        this.#log.error(error, { fromPatternId, toPatternId });
        return {
          success: false,
          error,
          patternId: toPatternId,
          particleCount: particleIds.length,
          positions: []
        };
      }

      // Use FormationBlendingService for smooth transition
      const blendResult = await formationBlendingService.blendFormations(
        fromPattern,
        toPattern,
        particleIds.length,
        transitionConfig
      );

      if (blendResult.success) {
        this.#metrics.formationsApplied++;
        this.#log.info("Formation transition completed successfully", {
          from: fromPatternId,
          to: toPatternId,
          particleCount: particleIds.length,
          duration: blendResult.duration
        });
      }

      return blendResult;

    } catch (error) {
      this.#errorLog.logError(error as Error, {
        fromPatternId,
        toPatternId,
        particleCount: particleIds.length,
        context: "transitionFormation"
      });

      return {
        success: false,
        error: (error as Error).message,
        patternId: toPatternId,
        particleCount: particleIds.length,
        positions: []
      };
    }
  }

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
      this.#errorLog.logError(error as Error, { context: "configureDependencies" });
    }
  }

  /**
   * Calculates particle positions for a given formation pattern
   * @param pattern - Formation pattern to use for calculations
   * @param particleCount - Number of particles to position
   * @param config - Optional configuration for position calculation
   * @returns Array of calculated positions
   * @private
   */
  private calculateFormationPositions(
    pattern: IFormationPattern,
    particleCount: number,
    config?: IFormationConfig
  ): IVector3[] {
    try {
      // Use geometry utilities to calculate positions based on pattern type
      const positions: IVector3[] = [];
      const scale = config?.scale || 1.0;
      const spacing = config?.spacing || pattern.defaultSpacing || 1.0;

      switch (pattern.type) {
        case "sphere":
          return this.calculateSpherePositions(particleCount, scale * spacing);

        case "cube":
          return this.calculateCubePositions(particleCount, scale * spacing);

        case "cylinder":
          return this.calculateCylinderPositions(particleCount, scale * spacing);

        case "helix":
          return this.calculateHelixPositions(particleCount, scale * spacing);

        case "torus":
          return this.calculateTorusPositions(particleCount, scale * spacing);

        case "custom":
          if (pattern.customPositions && pattern.customPositions.length > 0) {
            return this.scalePositions(pattern.customPositions.slice(0, particleCount), scale);
          }
          break;

        default:
          this.#log.warn("Unknown formation pattern type, using default sphere", {
            type: pattern.type,
            patternId: pattern.id
          });
          return this.calculateSpherePositions(particleCount, scale * spacing);
      }

      return positions;

    } catch (error) {
      this.#errorLog.logError(error as Error, {
        patternType: pattern.type,
        particleCount,
        context: "calculateFormationPositions"
      });
      // Fallback to simple sphere formation
      return this.calculateSpherePositions(particleCount, 1.0);
    }
  }

  /**
   * Validates a formation pattern for correctness and completeness
   * @param pattern - Formation pattern to validate
   * @returns Validation result with success status and any errors
   * @private
   */
  private validateFormationPattern(pattern: IFormationPattern): { valid: boolean; errors: string[] } {
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

      if (pattern.defaultSpacing !== undefined &&
          (typeof pattern.defaultSpacing !== "number" || pattern.defaultSpacing <= 0)) {
        errors.push("defaultSpacing must be a positive number if specified");
      }

      // Validate custom positions if provided
      if (pattern.type === "custom") {
        if (!pattern.customPositions || !Array.isArray(pattern.customPositions)) {
          errors.push("Custom pattern type requires customPositions array");
        } else if (pattern.customPositions.length === 0) {
          errors.push("Custom pattern customPositions array cannot be empty");
        }
      }

      return { valid: errors.length === 0, errors };

    } catch (error) {
      this.#errorLog.logError(error as Error, {
        patternId: pattern?.id,
        context: "validateFormationPattern"
      });
      return { valid: false, errors: ["Validation failed due to unexpected error"] };
    }
  }

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
      this.#errorLog.logError(error as Error, { key, context: "addToCache" });
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
      this.#errorLog.logError(error as Error, {
        positionCount: positions.length,
        context: "applyTransformations"
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
      this.#errorLog.logError(error as Error, { context: "dispose" });
    }
  }
}

// Export singleton instance
export const formationService = FormationService.getInstance();
export { FormationService };
