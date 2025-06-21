/** Simple event bus types (Template) */

export type EventPayload = any

export interface IEvent {
  type: string
  payload: EventPayload
  timestamp: number
}

export interface IEventListener { (event: IEvent): void }