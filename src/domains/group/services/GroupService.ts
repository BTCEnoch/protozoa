import type { IGroupService, ParticleGroup } from '@/domains/group/interfaces/IGroupService'
import type { IRNGService } from '@/domains/rng/interfaces/IRNGService'
import { createServiceLogger } from '@/shared/lib/logger'

class GroupService implements IGroupService {
  static #instance: GroupService | null = null

  #groups: Map<string, ParticleGroup> = new Map()
  #rng?: IRNGService
  #log = createServiceLogger('GROUP_SERVICE')

  private constructor() {
    this.#log.info('GroupService singleton created')
  }

  public static getInstance(): GroupService {
    if (!GroupService.#instance) GroupService.#instance = new GroupService()
    return GroupService.#instance
  }

  /** Inject RNG dependency */
  public configure(rng: IRNGService) {
    this.#rng = rng
    this.#log.debug('RNG injected')
  }

  public formGroup(particleIds: string[]): ParticleGroup {
    const gid = this.#rng
      ? `group-${Math.floor(this.#rng.random() * 1e6).toString(36)}`
      : `group-${Date.now().toString(36)}`
    const group: ParticleGroup = { id: gid, members: [...particleIds] }
    this.#groups.set(gid, group)
    this.#log.info('Group formed', { gid, size: particleIds.length })
    return group
  }

  public getGroup(id: string): ParticleGroup | undefined {
    return this.#groups.get(id)
  }

  public dissolveGroup(id: string): void {
    if (this.#groups.delete(id)) {
      this.#log.info('Group dissolved', { id })
    }
  }

  public dispose(): void {
    this.#groups.clear()
    this.#log.info('GroupService disposed')
    GroupService.#instance = null
  }
}

export const groupService = GroupService.getInstance()
