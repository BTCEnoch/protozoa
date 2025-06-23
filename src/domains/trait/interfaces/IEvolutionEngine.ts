/**
 * Evolution Engine Interface
 * @module @/domains/trait/interfaces/IEvolutionEngine
 */

import type { IOrganismTraits } from '@/shared/types/entityTypes'

export interface IMutationConfig {
  rate: number
  strength: number
  type: 'gaussian' | 'uniform' | 'exponential'
}

export interface IEvolutionEngine {
  mutateTraits(traits: IOrganismTraits, config: IMutationConfig): IOrganismTraits
  crossoverTraits(parent1: IOrganismTraits, parent2: IOrganismTraits): IOrganismTraits
  evaluateFitness(traits: IOrganismTraits): number
  selectForReproduction(population: IOrganismTraits[], count: number): IOrganismTraits[]
}
