export class EventBus { static getInstance() { return new EventBus() } emitEvent(event: string, payload?: unknown) { console.log(event, payload) } }
