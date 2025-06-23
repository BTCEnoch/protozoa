import { createServiceLogger } from '@/shared/lib/logger'
import type { IGroupService, ParticleGroup } from '@/domains/group/interfaces/IGroupService'
import type { IRNGService } from '@/domains/rng/interfaces/IRNGService'

class GroupService implements IGroupService {
  static #instance: GroupService | null = null
  #groups: Map<string, ParticleGroup> = new Map()
  #rng?: IRNGService
  #log = createServiceLogger('GROUP_SERVICE')
  private constructor () {}
  static getInstance () {
    return this.#instance ?? (this.#instance = new GroupService())
  }
  configure (rng: IRNGService) {
    this.#rng = rng
  }
  formGroup (particleIds: string[]): ParticleGroup {
    const gid = this.#rng ? `group-${this.#rng.randomInt(1000, 9999)}` : `group-${this.#groups.size + 1}`
    const group: ParticleGroup = { id: gid, members: [...particleIds] }
    this.#groups.set(gid, group)
    this.#log.info('Group formed', { gid, size: particleIds.length })
    return group
  }
  getGroup (id: string) {
    return this.#groups.get(id)
  }
  getAllGroups (): ParticleGroup[] {
    return Array.from(this.#groups.values())
  }
  dissolveGroup (id: string) {
    if (this.#groups.delete(id)) this.#log.info('Group dissolved', { id })
  }
  dispose (): void {
    this.#groups.clear()
    GroupService.#instance = null
  }
}

// Export both class and singleton instance as per .cursorrules
export { GroupService }
export const groupService = GroupService.getInstance()
