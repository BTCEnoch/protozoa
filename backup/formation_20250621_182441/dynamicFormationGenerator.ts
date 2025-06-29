import { createServiceLogger } from '@/shared/lib/logger'
import { rngService } from '@/domains/rng'
import type { Vector3 } from 'three'

export type FormationPattern = { id: string; positions: Vector3[] }

export class DynamicFormationGenerator {
  #log = createServiceLogger('DYN_FORMATION')

  generatePattern (id: string, count: number): FormationPattern {
    const positions: any[] = []
    switch (id) {
      case 'fibonacci': {
        const phi = (1 + Math.sqrt(5)) / 2
        for (let i = 0; i < count; i++) {
          const angle = (2 * Math.PI * i) / phi
          const r = Math.sqrt(i / count)
          positions.push({ x: r * Math.cos(angle) * 50, y: r * Math.sin(angle) * 50, z: 0 })
        }
        break
      }
      default:
        for (let i = 0; i < count; i++) {
          positions.push({
            x: rngService.random() * 100 - 50,
            y: rngService.random() * 100 - 50,
            z: rngService.random() * 100 - 50
          })
        }
    }
    this.#log.info('Pattern generated', { id, count })
    return { id, positions }
  }
}