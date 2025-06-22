/**
 * @fileoverview RNG Domain Exports
 * @version 1.0.0
 */

export { RNGService, rngService } from "./services/RNGService"

export type {
  IRNGService,
  RNGConfig,
  RNGState,
  RNGOptions
} from "./interfaces/IRNGService"

export type {
  PRNGAlgorithm,
  SeedSource,
  RNGMetrics
} from "./types/rng.types"
