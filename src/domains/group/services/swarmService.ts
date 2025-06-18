import { createServiceLogger } from '@/shared/lib/logger'
import { groupService } from '@/domains/group/services/groupService'
import { physicsService } from '@/domains/physics/services/physicsService'
import type { ISwarmService } from '@/domains/group/interfaces/ISwarmService'

export class SwarmService implements ISwarmService {
  static #instance: SwarmService | null = null
  #log = createServiceLogger('SWARM')
  private constructor () {}
  static getInstance () {
    return this.#instance ?? (this.#instance = new SwarmService())
  }
  update (delta: number) {
    // simple flocking placeholder: iterate groups
    groupService['#groups']?.forEach((g: any) => {
      // placeholder physics influence using physicsService
      physicsService.applyGlobalForces(g)
    })
    this.#log.debug('Swarm update', { delta })
  }
  dispose () {
    SwarmService.#instance = null
  }
}
export const swarmService = SwarmService.getInstance()
