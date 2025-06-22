/** Additional formation utilities (Template) */
import { Vector3 } from 'three'
export function scalePattern(positions:Vector3[], factor:number){return positions.map(p=>p.clone().multiplyScalar(factor))}