import { EventEmitter } from 'events'
export interface IEventBus extends EventEmitter {
  emitEvent(event:string,payload?:unknown):void
}
