/** Core entity interfaces (Template) */
import type { IVector3, IColor } from "./vectorTypes"

export interface IEntity { id: string; createdAt: Date; updatedAt: Date; type: string }

export interface IParticle extends IEntity {
  position: IVector3
  velocity: IVector3
  color: IColor
  size: number
  active: boolean
}