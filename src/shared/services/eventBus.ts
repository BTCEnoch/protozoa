import type { IEventBus } from '@/shared/interfaces/IEventBus'
import { createServiceLogger } from '@/shared/lib/logger'
import { EventEmitter } from 'events'

class EventBus extends EventEmitter implements IEventBus{
 static #instance:EventBus|null=null
 #log=createServiceLogger('EVENT_BUS')
 private constructor(){super()}
 static getInstance(){return this.#instance??(this.#instance=new EventBus())}
 emitEvent(event:string,payload?:unknown){ this.emit(event,payload); this.#log.debug('Event emitted',{event}) }
}
export const eventBus=EventBus.getInstance()
