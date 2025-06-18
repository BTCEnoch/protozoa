export interface IPersistenceService{
  save(key:string,value:unknown):Promise<void>
  load<T=unknown>(key:string):Promise<T|null>
  dispose():void
}
