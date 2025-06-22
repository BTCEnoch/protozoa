/**
 * @fileoverview Trait Definitions Data
 * @description Core trait definitions, ranges, and mutation probabilities for organism evolution
 * @author Protozoa Development Team
 * @version 1.0.0
 */

import { TraitCategory, TraitType, TraitRange, MutationProbability } from '../types/trait.types'
import { createServiceLogger } from '@/shared/lib/logger'

const logger = createServiceLogger('TraitDefinitions')

/**
 * Visual trait definitions with ranges and constraints
 */
export const VISUAL_TRAIT_DEFINITIONS = {
  primaryColor: {
    type: 'color' as TraitType,
    category: 'visual' as TraitCategory,
    range: { min: '#000000', max: '#FFFFFF', default: '#4A90E2' } as TraitRange,
    default: '#4A90E2',
    mutationRate: 0.15,
    description: 'Primary color of the organism particle'
  },
  secondaryColor: {
    type: 'color' as TraitType,
    category: 'visual' as TraitCategory,
    range: { min: '#000000', max: '#FFFFFF', default: '#7ED321' } as TraitRange,
    default: '#7ED321',
    mutationRate: 0.12,
    description: 'Secondary accent color'
  },
  size: {
    type: 'numeric' as TraitType,
    category: 'visual' as TraitCategory,
    range: { min: 0.5, max: 3.0 } as TraitRange,
    default: 1.0,
    mutationRate: 0.08,
    description: 'Overall size multiplier for the organism'
  },
  opacity: {
    type: 'numeric' as TraitType,
    category: 'visual' as TraitCategory,
    range: { min: 0.3, max: 1.0 } as TraitRange,
    default: 0.85,
    mutationRate: 0.06,
    description: 'Transparency level of the organism'
  },
  particleDensity: {
    type: 'numeric' as TraitType,
    category: 'visual' as TraitCategory,
    range: { min: 50, max: 500 } as TraitRange,
    default: 150,
    mutationRate: 0.10,
    description: 'Number of particles composing the organism'
  },
  glowIntensity: {
    type: 'numeric' as TraitType,
    category: 'visual' as TraitCategory,
    range: { min: 0.0, max: 2.0 } as TraitRange,
    default: 0.5,
    mutationRate: 0.07,
    description: 'Intensity of particle glow effect'
  }
} as const

/**
 * Behavioral trait definitions with ranges and constraints
 */
export const BEHAVIORAL_TRAIT_DEFINITIONS = {
  speed: {
    type: 'numeric' as TraitType,
    category: 'behavioral' as TraitCategory,
    range: { min: 0.1, max: 5.0 } as TraitRange,
    default: 1.0,
    mutationRate: 0.12,
    description: 'Movement speed of the organism'
  },
  aggression: {
    type: 'numeric' as TraitType,
    category: 'behavioral' as TraitCategory,
    range: { min: 0.0, max: 1.0 } as TraitRange,
    default: 0.3,
    mutationRate: 0.09,
    description: 'Tendency to engage in competitive behaviors'
  },
  sociability: {
    type: 'numeric' as TraitType,
    category: 'behavioral' as TraitCategory,
    range: { min: 0.0, max: 1.0 } as TraitRange,
    default: 0.5,
    mutationRate: 0.08,
    description: 'Preference for group formations'
  },
  curiosity: {
    type: 'numeric' as TraitType,
    category: 'behavioral' as TraitCategory,
    range: { min: 0.0, max: 1.0 } as TraitRange,
    default: 0.4,
    mutationRate: 0.11,
    description: 'Exploration and learning tendency'
  },
  efficiency: {
    type: 'numeric' as TraitType,
    category: 'behavioral' as TraitCategory,
    range: { min: 0.2, max: 2.0 } as TraitRange,
    default: 1.0,
    mutationRate: 0.07,
    description: 'Energy efficiency in movements and actions'
  },
  adaptability: {
    type: 'numeric' as TraitType,
    category: 'behavioral' as TraitCategory,
    range: { min: 0.1, max: 1.5 } as TraitRange,
    default: 0.7,
    mutationRate: 0.06,
    description: 'Ability to adapt to environmental changes'
  }
} as const

/**
 * Physical trait definitions with ranges and constraints
 */
export const PHYSICAL_TRAIT_DEFINITIONS = {
  mass: {
    type: 'numeric' as TraitType,
    category: 'physical' as TraitCategory,
    range: { min: 0.5, max: 10.0 } as TraitRange,
    default: 2.0,
    mutationRate: 0.08,
    description: 'Physical mass affecting physics interactions'
  },
  collisionRadius: {
    type: 'numeric' as TraitType,
    category: 'physical' as TraitCategory,
    range: { min: 0.3, max: 2.5 } as TraitRange,
    default: 0.8,
    mutationRate: 0.09,
    description: 'Radius for collision detection'
  },
  energyCapacity: {
    type: 'numeric' as TraitType,
    category: 'physical' as TraitCategory,
    range: { min: 50, max: 500 } as TraitRange,
    default: 150,
    mutationRate: 0.10,
    description: 'Maximum energy the organism can store'
  },
  durability: {
    type: 'numeric' as TraitType,
    category: 'physical' as TraitCategory,
    range: { min: 0.3, max: 2.0 } as TraitRange,
    default: 1.0,
    mutationRate: 0.07,
    description: 'Resistance to environmental damage'
  },
  regeneration: {
    type: 'numeric' as TraitType,
    category: 'physical' as TraitCategory,
    range: { min: 0.0, max: 1.0 } as TraitRange,
    default: 0.2,
    mutationRate: 0.05,
    description: 'Rate of energy/health regeneration'
  }
} as const

/**
 * Evolutionary trait definitions with ranges and constraints
 */
export const EVOLUTIONARY_TRAIT_DEFINITIONS = {
  fitness: {
    type: 'numeric' as TraitType,
    category: 'evolutionary' as TraitCategory,
    range: { min: 0.0, max: 2.0 } as TraitRange,
    default: 1.0,
    mutationRate: 0.03,
    description: 'Overall evolutionary fitness score'
  },
  stability: {
    type: 'numeric' as TraitType,
    category: 'evolutionary' as TraitCategory,
    range: { min: 0.1, max: 1.0 } as TraitRange,
    default: 0.7,
    mutationRate: 0.04,
    description: 'Genetic stability and mutation resistance'
  },
  reproductivity: {
    type: 'numeric' as TraitType,
    category: 'evolutionary' as TraitCategory,
    range: { min: 0.0, max: 1.5 } as TraitRange,
    default: 0.5,
    mutationRate: 0.06,
    description: 'Ability to reproduce and create offspring'
  },
  longevity: {
    type: 'numeric' as TraitType,
    category: 'evolutionary' as TraitCategory,
    range: { min: 0.5, max: 3.0 } as TraitRange,
    default: 1.2,
    mutationRate: 0.05,
    description: 'Expected lifespan multiplier'
  }
} as const

/**
 * Mutation probability tables based on environmental factors
 */
export const MUTATION_PROBABILITIES: Record<string, MutationProbability> = {
  // Base mutation rates for different trait categories
  visual: {
    baseRate: 0.08,
    activityModifier: 0.02,
    maxRate: 0.25,
    minRate: 0.01
  },
  behavioral: {
    baseRate: 0.09,
    activityModifier: 0.03,
    maxRate: 0.30,
    minRate: 0.015
  },
  physical: {
    baseRate: 0.07,
    activityModifier: 0.025,
    maxRate: 0.20,
    minRate: 0.01
  },
  evolutionary: {
    baseRate: 0.04,
    activityModifier: 0.015,
    maxRate: 0.15,
    minRate: 0.008
  }
}

/**
 * Trait compatibility matrix for crossover breeding
 */
export const TRAIT_COMPATIBILITY_MATRIX = {
  // High compatibility traits (inherit well together)
  compatible: [
    ['speed', 'efficiency'],
    ['aggression', 'durability'],
    ['sociability', 'curiosity'],
    ['size', 'mass'],
    ['primaryColor', 'secondaryColor'],
    ['fitness', 'longevity']
  ],
  // Conflicting traits (rarely inherit together)
  conflicting: [
    ['aggression', 'sociability'],
    ['speed', 'mass'],
    ['stability', 'adaptability']
  ]
}

/**
 * Helper functions for trait manipulation
 */
export const TraitDefinitionHelpers = {
  /**
   * Get all trait definitions combined
   */
  getAllTraitDefinitions() {
    logger.debug('Retrieving all trait definitions')
    return {
      ...VISUAL_TRAIT_DEFINITIONS,
      ...BEHAVIORAL_TRAIT_DEFINITIONS,
      ...PHYSICAL_TRAIT_DEFINITIONS,
      ...EVOLUTIONARY_TRAIT_DEFINITIONS
    }
  },

  /**
   * Get trait definition by name
   */
  getTraitDefinition(traitName: string) {
    const allTraits = this.getAllTraitDefinitions()
    const definition = allTraits[traitName as keyof typeof allTraits]
    
    if (!definition) {
      logger.warn(`Trait definition not found: ${traitName}`)
      return null
    }
    
    logger.debug(`Retrieved trait definition for: ${traitName}`)
    return definition
  },

  /**
   * Get traits by category
   */
  getTraitsByCategory(category: TraitCategory) {
    logger.debug(`Retrieving traits for category: ${category}`)
    
    const categoryMappings = {
      visual: VISUAL_TRAIT_DEFINITIONS,
      behavioral: BEHAVIORAL_TRAIT_DEFINITIONS,
      physical: PHYSICAL_TRAIT_DEFINITIONS,
      evolutionary: EVOLUTIONARY_TRAIT_DEFINITIONS
    }
    
    return categoryMappings[category] || {}
  },

  /**
   * Calculate effective mutation rate based on factors
   */
  calculateEffectiveMutationRate(
    category: TraitCategory,
    activityFactor: number = 1.0
  ): number {
    const baseProbabilities = MUTATION_PROBABILITIES[category]
    if (!baseProbabilities) {
      logger.warn(`Mutation probabilities not found for category: ${category}`)
      return 0.05 // Default fallback
    }
    
    const effectiveRate = 
      baseProbabilities.baseRate +
      (baseProbabilities.activityModifier * activityFactor)
    
    // Cap between min and max rates
    const cappedRate = Math.max(baseProbabilities.minRate, 
                               Math.min(baseProbabilities.maxRate, effectiveRate))
    
    logger.debug(`Calculated effective mutation rate for ${category}: ${cappedRate}`)
    return cappedRate
  },

  /**
   * Check if two traits are compatible for crossover
   */
  areTraitsCompatible(traitA: string, traitB: string): boolean {
    const compatible = TRAIT_COMPATIBILITY_MATRIX.compatible.some(
      pair => (pair[0] === traitA && pair[1] === traitB) ||
             (pair[0] === traitB && pair[1] === traitA)
    )
    
    const conflicting = TRAIT_COMPATIBILITY_MATRIX.conflicting.some(
      pair => (pair[0] === traitA && pair[1] === traitB) ||
             (pair[0] === traitB && pair[1] === traitA)
    )
    
    logger.debug(`Trait compatibility check - ${traitA} & ${traitB}: compatible=${compatible}, conflicting=${conflicting}`)
    return compatible && !conflicting
  }
}

/**
 * Export consolidated trait definitions
 */
export const ALL_TRAIT_DEFINITIONS = TraitDefinitionHelpers.getAllTraitDefinitions()

/**
 * Export trait categories for iteration
 */
export const TRAIT_CATEGORIES: TraitCategory[] = ['visual', 'behavioral', 'physical', 'evolutionary'] 