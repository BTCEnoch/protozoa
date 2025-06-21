import { createServiceLogger } from '@/shared/lib/logger'
import type { ITimelineService, Keyframe } from '@/domains/animation/interfaces/ITimelineService'

class TimelineService implements ITimelineService {
  static #instance: TimelineService | null = null
  #log = createServiceLogger('TIMELINE')
  #frames: Keyframe[] = []
  #time = 0
  #running = false
  private constructor () {}
  static getInstance () {
    return this.#instance ?? (this.#instance = new TimelineService())
  }
  addKeyframe (frame: Keyframe) {
    this.#frames.push(frame)
    this.#frames.sort((a, b) => a.time - b.time)
  }
  play () {
    this.#running = true
    this.#log.info('Timeline play')
  }
  pause () {
    this.#running = false
    this.#log.info('Timeline pause')
  }
  seek (t: number) {
    this.#time = t
    this.#log.debug('Timeline seek', { t })
  }
  update (delta: number) {
    if (!this.#running) return
    this.#time += delta
    while (this.#frames.length > 0 && this.#frames[0] && this.#frames[0].time <= this.#time) {
      const f = this.#frames.shift()!
      try {
        f.action()
      } catch (e) {
        this.#log.error('Keyframe error', e)
      }
    }
  }
  dispose () {
    this.#frames = []
    TimelineService.#instance = null
  }
}
export const timelineService = TimelineService.getInstance()
