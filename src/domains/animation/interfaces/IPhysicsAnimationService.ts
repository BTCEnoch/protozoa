export interface IPhysicsAnimationService{
  addSpring(particleId:string,anchor:{x:number,y:number,z:number},k:number,damper:number):void
  update(delta:number):void
  dispose():void
}
