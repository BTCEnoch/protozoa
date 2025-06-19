// src/domains/formation/services/FormationService.ts
// FormationService implementation - Auto-generated stub
// Referenced from build_design.md Section 4

import { createServiceLogger } from '@/shared/lib/logger';
import { Vector3 } from '@/shared/types';
import { FormationPattern, IFormationService } from '../types';

/**
 * FormationService manages all formation-related operations including
 * pattern registration, retrieval, blending, and cache management.
 * Auto-generated stub following .cursorrules singleton pattern.
 * TODO: Implement actual logic in Phase 4.
 */
class FormationService implements IFormationService {
  static #instance: FormationService | null = null;
  #log = createServiceLogger('FORMATION_SERVICE');

  /** Holds all registered formation patterns keyed by their unique id */
  #patterns: Map<string, FormationPattern> = new Map()

  /** Cache for previously-blended formations (keyed by a deterministic hash) */
  #blendCache: Map<string, FormationPattern> = new Map()

  /** Maximum number of entries allowed in the blend cache */
  #maxCacheSize = 100

  /**
   * Private constructor enforces singleton pattern.
   */
  private constructor() {
    this.#log.info('FormationService initialized');
  }

  /**
   * Singleton accessor - returns existing instance or creates new one.
   */
  public static getInstance(): FormationService {
    if (!FormationService.#instance) {
      FormationService.#instance = new FormationService();
    }
    return FormationService.#instance;
  }

  // ---------------------------------------------------------------------------
  // IFormationService implementation ----------------------------------------
  // ---------------------------------------------------------------------------

  /**
   * Retrieves a formation pattern by id.
   * @param patternId – unique identifier of the pattern
   */
  public getFormationPattern(patternId: string): FormationPattern | undefined {
    this.#log.debug(`getFormationPattern called → ${patternId}`)
    return this.#patterns.get(patternId)
  }

  /**
   * Applies the specified formation pattern to the given particles.  The actual
   * placement/movement logic will be handled by the Animation → Physics domain
   * in Phase 4; for now we only log the intent so that downstream systems can
   * subscribe to the event bus later.
   */
  public applyFormation(patternId: string, particleIds: string[]): void {
    const patternExists = this.#patterns.has(patternId)
    if (!patternExists) {
      this.#log.warn(`applyFormation – patternId '${patternId}' not registered; ignoring request`)
      return
    }
    this.#log.info(`applyFormation → pattern '${patternId}' applied to ${particleIds.length} particles`)
    // TODO(Phase-4): Publish event to EventBus once implemented
  }

  /**
   * Registers / overwrites a formation pattern in the internal registry.
   */
  public registerPattern(pattern: FormationPattern): void {
    const key = this.#extractPatternKey(pattern)
    if (!key) {
      this.#log.error('registerPattern – could not determine unique key for pattern')
      return
    }
    this.#patterns.set(key, pattern)
    this.#log.info(`registerPattern → '${key}' registered`)
  }

  /**
   * Creates a blended formation by linearly interpolating positions across the
   * supplied patterns using the provided weights.
   *
   * NOTE:  For MVP purposes we assume all patterns share the same number of
   * positions and the same ordering.  A more sophisticated spatial blending
   * algorithm will be introduced in a later phase.
   */
  public blendFormations(patterns: FormationPattern[], weights: number[]): FormationPattern {
    if (patterns.length === 0) throw new Error('blendFormations requires at least one pattern')
    if (patterns.length !== weights.length) throw new Error('patterns and weights length mismatch')

    // Generate deterministic cache key → `${id1}:${w1}|${id2}:${w2}|…`
    const cacheKey = patterns
      .map((p, idx) => {
        const keyPart = this.#extractPatternKey(p) ?? `pattern${idx}`
        const safeWeight = weights[idx] ?? 0
        return `${keyPart}:${safeWeight.toFixed(3)}`
      })
      .join('|')

    const cached = this.#blendCache.get(cacheKey)
    if (cached) {
      this.#log.debug(`blendFormations cache-hit → ${cacheKey}`)
      return cached
    }

    this.#log.debug(`blendFormations cache-miss → ${cacheKey}`)

    // Simple positional blend (linear interpolation)
    const basePositions = (patterns[0]! as any).positions as Vector3[]
    const blendedPositions = basePositions.map((__pos: Vector3, idx: number) => {
      const blended = { x: 0, y: 0, z: 0 }
      patterns.forEach((p, pIdx) => {
        const weight = weights[pIdx] ?? 0
        const pos = (p as any).positions?.[idx] as Vector3 | undefined
        if (!pos) return
        blended.x += pos.x * weight
        blended.y += pos.y * weight
        blended.z += pos.z * weight
      })
      return blended
    })

    const blendedPattern = {
      positions: blendedPositions,
      metadata: { cacheKey, timestamp: Date.now() } as any // TODO: refine once IFormationMetadata is defined
    } as FormationPattern

    this.#updateBlendCache(cacheKey, blendedPattern)
    return blendedPattern
  }

  /** Returns a previously-blended formation, or undefined if not cached */
  public getCachedBlend(key: string): FormationPattern | undefined {
    this.#log.debug(`getCachedBlend → ${key}`)
    return this.#blendCache.get(key)
  }

  /** Sets the maximum number of blend cache entries (evicting LRU if needed) */
  public setCacheLimit(maxSize: number): void {
    if (maxSize <= 0) {
      this.#log.warn(`setCacheLimit – invalid size '${maxSize}'; keeping current limit`) 
      return
    }
    this.#log.info(`setCacheLimit → ${maxSize}`)
    this.#maxCacheSize = maxSize
    this.#evictCacheIfNeeded()
  }

  // ---------------------------------------------------------------------------
  // Cache helpers -------------------------------------------------------------
  // ---------------------------------------------------------------------------

  /** Inserts a blended pattern into cache and enforces size policy */
  #updateBlendCache(key: string, value: FormationPattern): void {
    this.#blendCache.set(key, value)
    this.#evictCacheIfNeeded()
  }

  /** Evicts the oldest cache entries until size ≤ maxCacheSize */
  #evictCacheIfNeeded(): void {
    while (this.#blendCache.size > this.#maxCacheSize) {
      const oldestKey = this.#blendCache.keys().next().value as string | undefined
      if (!oldestKey) break
      this.#blendCache.delete(oldestKey)
      this.#log.debug(`Cache eviction → removed '${oldestKey}'`)
    }
  }

  /**
   * Disposes of service resources and resets singleton instance.
   */
  public dispose(): void {
    this.#log.info('FormationService disposed')
    this.#patterns.clear()
    this.#blendCache.clear()
    FormationService.#instance = null
  }

  /** Attempts to derive a unique key from the pattern */
  #extractPatternKey(pattern: FormationPattern): string | undefined {
    const candidate = (pattern as any).id ?? (pattern as any)?.metadata?.id ?? (pattern as any).name
    return typeof candidate === 'string' ? candidate : undefined
  }
}

// Singleton export as required by .cursorrules
export const formationService = FormationService.getInstance();
