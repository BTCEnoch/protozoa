/**
 * @fileoverview IGroupService Interface Definition
 * @description Contract for grouping particles and managing group lifecycle.
 */

export interface ParticleGroup {
  id: string
  members: string[]
}

export interface IGroupService {
  formGroup(particleIds: string[]): ParticleGroup
  getGroup(id: string): ParticleGroup | undefined
  dissolveGroup(id: string): void
  dispose(): void
}
