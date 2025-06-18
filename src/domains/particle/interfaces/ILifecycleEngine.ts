export interface ILifecycleEngine{
  birth(count:number): void
  update(delta:number): void
  kill(id:string): void
  dispose():void
}
