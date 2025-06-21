/**
 * @fileoverview RNG Service Interface Definition (Template)
 * @module @/domains/rng/interfaces/IRNGService
 * @version 1.0.0
 */

/** RNG service configuration */
export interface RNGConfig {
  defaultSeed?: number
  useBitcoinSeeding?: boolean
}

/** Basic RNG state snapshot */
export interface RNGState {
  seed: number
  counter: number
}

/** Random generation options */
export interface RNGOptions {
  min?: number
  max?: number
  count?: number
  seed?: number
}

export interface IRNGService {
  initialize(config?: RNGConfig): Promise<void>
  setSeed(seed: number): void
  seedFromBlock(blockNumber: number): Promise<void>
  random(): number
  randomInt(min: number, max: number): number
  randomFloat(min: number, max: number): number
  randomArray(options: RNGOptions): number[]
  getState(): RNGState
  setState(state: RNGState): void
  reset(): void
  dispose(): void
}