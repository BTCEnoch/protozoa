/**
 * traitEnhancements.ts - Genetic inheritance and mutation system
 * Provides trait inheritance logic and mutation mechanics for organisms
 */
import { TraitService } from './TraitService'
import { RNGService } from '@/domains/rng/services/RNGService'
import { createServiceLogger } from '@/shared/lib/logger'
import { TraitCategory, TraitValue, OrganismTraits, VisualTraits, BehavioralTraits, PhysicalTraits, EvolutionaryTraits } from '../types/trait.types'

/**
 * Genetic inheritance service for trait evolution
 */
export class GeneticInheritanceService {
    private static instance: GeneticInheritanceService
    private traitService: TraitService
    private rngService: RNGService
    private logger = createServiceLogger('GeneticInheritanceService')

    private constructor() {
        this.traitService = TraitService.getInstance()
        this.rngService = RNGService.getInstance()
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
        this.logger.debug('Starting trait inheritance process')
        
        // Create proper child traits structure
        const childTraits: OrganismTraits = {
            organismId: 'inherited_' + Date.now(),
            parentIds: [parentA.organismId, parentB.organismId],
            blockNumber: parentA.blockNumber,
            visual: this.inheritVisualTraits(parentA.visual, parentB.visual),
            behavioral: this.inheritBehavioralTraits(parentA.behavioral, parentB.behavioral),
            physical: this.inheritPhysicalTraits(parentA.physical, parentB.physical),
            evolutionary: this.inheritEvolutionaryTraits(parentA.evolutionary, parentB.evolutionary),
            generatedAt: Date.now(),
            mutationHistory: []
        }

        this.logger.info('Trait inheritance completed successfully')
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
            this.logger.debug('Applying mutation to trait: ' + traitKey)
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

    // Helper methods for trait inheritance
    private inheritVisualTraits(parentA: VisualTraits, parentB: VisualTraits): VisualTraits {
        return {
            primaryColor: this.selectParentTrait(parentA.primaryColor, parentB.primaryColor) as string,
            secondaryColor: this.selectParentTrait(parentA.secondaryColor, parentB.secondaryColor) as string,
            size: this.selectParentTrait(parentA.size, parentB.size) as number,
            opacity: this.selectParentTrait(parentA.opacity, parentB.opacity) as number,
            shape: this.selectParentTrait(parentA.shape, parentB.shape) as string,
            particleDensity: this.selectParentTrait(parentA.particleDensity, parentB.particleDensity) as number,
            glowIntensity: this.selectParentTrait(parentA.glowIntensity, parentB.glowIntensity) as number
        }
    }

    private inheritBehavioralTraits(parentA: BehavioralTraits, parentB: BehavioralTraits): BehavioralTraits {
        return {
            speed: this.selectParentTrait(parentA.speed, parentB.speed) as number,
            aggression: this.selectParentTrait(parentA.aggression, parentB.aggression) as number,
            sociability: this.selectParentTrait(parentA.sociability, parentB.sociability) as number,
            curiosity: this.selectParentTrait(parentA.curiosity, parentB.curiosity) as number,
            efficiency: this.selectParentTrait(parentA.efficiency, parentB.efficiency) as number,
            adaptability: this.selectParentTrait(parentA.adaptability, parentB.adaptability) as number
        }
    }

    private inheritPhysicalTraits(parentA: PhysicalTraits, parentB: PhysicalTraits): PhysicalTraits {
        return {
            mass: this.selectParentTrait(parentA.mass, parentB.mass) as number,
            collisionRadius: this.selectParentTrait(parentA.collisionRadius, parentB.collisionRadius) as number,
            energyCapacity: this.selectParentTrait(parentA.energyCapacity, parentB.energyCapacity) as number,
            durability: this.selectParentTrait(parentA.durability, parentB.durability) as number,
            regeneration: this.selectParentTrait(parentA.regeneration, parentB.regeneration) as number
        }
    }

    private inheritEvolutionaryTraits(parentA: EvolutionaryTraits, parentB: EvolutionaryTraits): EvolutionaryTraits {
        return {
            generation: Math.max(parentA.generation, parentB.generation) + 1,
            fitness: this.selectParentTrait(parentA.fitness, parentB.fitness) as number,
            stability: this.selectParentTrait(parentA.stability, parentB.stability) as number,
            reproductivity: this.selectParentTrait(parentA.reproductivity, parentB.reproductivity) as number,
            longevity: this.selectParentTrait(parentA.longevity, parentB.longevity) as number
        }
    }
}

// Export singleton instance
export const geneticInheritanceService = GeneticInheritanceService.getInstance()
