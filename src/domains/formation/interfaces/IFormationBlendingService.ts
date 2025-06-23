/** Formation blending service interface (Template) */
import type { IVector3 } from '@/shared/types/vectorTypes'

export interface FormationPattern { positions: IVector3[] }

export interface IFormationBlendingService {
  /**
   * Calculate intermediate particle positions between two patterns.
   * @param from starting pattern
   * @param to target pattern
   * @param alpha interpolation factor 0..1
   */
  blend(from: FormationPattern, to: FormationPattern, alpha: number): IVector3[]
}
