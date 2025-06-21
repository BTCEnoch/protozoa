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
   * @param patternId - Formation pattern to use for calculations
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
   * Disposes of the service and cleans up resources
   * Clears caches, removes patterns, and resets state
   */
  public dispose(): void {
    try {
      // Clear all cached data
      this.#cache.clear();
      
      // Clear all registered patterns
      this.#patterns.clear();
      
      // Reset metrics
      this.#metrics = {
        patternsRegistered: 0,
        formationsApplied: 0,
        cacheHits: 0,
        cacheMisses: 0
      };
      
      // Clear dependencies
      this.#dependencies = {};
      
      this.#log.info("FormationService disposed successfully");
      
    } catch (error) {
      this.#log.error("FormationService disposal failed", { error: (error as Error).message });
    }
  }
}

// Export both class and singleton instance as per .cursorrules
export { FormationService };
export const formationService = FormationService.getInstance(); 