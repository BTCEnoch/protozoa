import { createServiceLogger } from '@/shared/lib/logger'
import type { IFormationBlendingService, FormationPattern } from '@/domains/formation/interfaces/IFormationBlendingService'
import { Vector3 } from 'three'

class FormationBlendingService implements IFormationBlendingService {
  static #instance: FormationBlendingService | null = null
  public static getInstance () {
    return this.#instance ?? (this.#instance = new FormationBlendingService())
  }
  private constructor () { this.#log.info('FormationBlendingService ready') }
  #log = createServiceLogger('FORMATION_BLEND')

  blend (from: FormationPattern, to: FormationPattern, alpha: number) {
    const t = Math.max(0, Math.min(1, alpha))
    const count = Math.min(from.positions.length, to.positions.length)
    const result: Vector3[] = []
    for (let i = 0; i < count; i++) {
      const pA = from.positions[i]
      const pB = to.positions[i]
      result.push(new Vector3(
        pA.x + (pB.x - pA.x) * t,
        pA.y + (pB.y - pA.y) * t,
        pA.z + (pB.z - pA.z) * t
      ))
    }
    this.#log.debug('Blend computed', { alpha, count })
    return result
  }
}
export const formationBlendingService = FormationBlendingService.getInstance()
export { FormationBlendingService }