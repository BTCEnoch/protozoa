/**
 * @fileoverview RNG Domain Exports
 * @description Main export file for RNG domain
 * @author Protozoa Development Team
 * @version 1.0.0
 */

// Service exports
export { RNGService, rngService } from './services/rngService';

// Interface exports
export type { IRNGService, RNGConfig } from './interfaces/IRNGService';

// Type exports
export type { 
  RNGState, 
  RNGMetrics, 
  BlockHashSeed, 
  RNGAlgorithm, 
  SeedSource 
} from './types/rng.types';
