export interface Keyframe{ time:number; action:()=>void }
export interface ITimelineService{
  addKeyframe(frame:Keyframe):void
  play():void
  pause():void
  seek(time:number):void
  update(delta:number):void
  dispose():void
}
