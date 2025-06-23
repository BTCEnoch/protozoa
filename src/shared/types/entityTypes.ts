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

export interface IOrganismTraits {
  visual: {
    size: number
    opacity: number
    color: string
    glowIntensity: number
    particleDensity: number
  }
  behavioral: {
    speed: number
    aggression: number
    sociability: number
    curiosity: number
    efficiency: number
    adaptability: number
  }
  physical: {
    mass: number
    collisionRadius: number
    energyCapacity: number
    durability: number
    regeneration: number
  }
  evolutionary: {
    fitness: number
    stability: number
    reproductivity: number
    longevity: number
  }
}
