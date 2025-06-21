/**
 * traitEnhancements.ts - Genetic inheritance and mutation system
 * Provides trait inheritance logic and mutation mechanics for organisms
 */
import { RngService } from '@/domains/rng/services/RngService'
import { logger } from '@/shared/lib/logger'
import { OrganismTraits, TraitValue } from '../types/trait.types'
import { TraitService } from './TraitService'

/**
 * Genetic inheritance service for trait evolution
 */
export class GeneticInheritanceService {
    private static instance: GeneticInheritanceService
    private traitService: TraitService
    private rngService: RngService

    private constructor() {
        this.traitService = TraitService.getInstance()
        this.rngService = RngService.getInstance()
    }

    public static getInstance(): GeneticInheritanceService {
        if (!GeneticInheritanceService.instance) {
            GeneticInheritanceService.instance = new GeneticInheritanceService()
        }
        return GeneticInheritanceService.instance
    }

    /**
     * Inherit traits from two parent organisms
     */
    public inheritTraits(parentA: OrganismTraits, parentB: OrganismTraits): OrganismTraits {
        logger.debug('Starting trait inheritance process')
        const childTraits: OrganismTraits = {} as OrganismTraits

        // Iterate through all trait categories
        for (const category in parentA) {
            const categoryKey = category as keyof OrganismTraits
            childTraits[categoryKey] = {} as any

            // Inherit each trait in the category
            for (const traitKey in parentA[categoryKey]) {
                const inheritedValue = this.selectParentTrait(
                    parentA[categoryKey][traitKey],
                    parentB[categoryKey][traitKey]
                )
                
                // Apply potential mutation
                childTraits[categoryKey][traitKey] = this.applyMutation(
                    traitKey,
                    inheritedValue
                )
            }
        }

        logger.info('Trait inheritance completed successfully')
        return childTraits
    }

    /**
     * Select trait from one of two parents (50/50 chance)
     */
    private selectParentTrait(valueA: TraitValue, valueB: TraitValue): TraitValue {
        return this.rngService.random() < 0.5 ? valueA : valueB
    }

    /**
     * Apply potential mutation to a trait value
     */
    private applyMutation(traitKey: string, value: TraitValue): TraitValue {
        const mutationRate = this.calculateMutationRate()
        
        if (this.rngService.random() < mutationRate) {
            logger.debug('Applying mutation to trait:', traitKey)
            return this.traitService.mutateTrait(traitKey, value)
        }
        
        return value
    }

    /**
     * Calculate mutation rate based on blockchain difficulty
     */
    private calculateMutationRate(): number {
        // Base mutation rate
        const baseMutationRate = 0.01
        
        // TODO: Integrate with Bitcoin blockchain difficulty
        // Higher difficulty could increase mutation rate
        const difficultyMultiplier = 1.0
        
        return baseMutationRate * difficultyMultiplier
    }
}

// Export singleton instance
export const geneticInheritanceService = GeneticInheritanceService.getInstance()
