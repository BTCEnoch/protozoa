import { createServiceLogger } from '@/shared/lib/logger';
import { performance } from 'perf_hooks';

export interface PerfSample{ label:string; duration:number }

export class PerformanceRegressionService{
 static #instance:PerformanceRegressionService|null=null
 #log=createServiceLogger('PERF_REGRESSION')
 #samples:PerfSample[]=[]
 private constructor(){}
 static getInstance(){return this.#instance??(this.#instance=new PerformanceRegressionService())}
 start(label:string){return performance.now()}
 end(label:string,startTime:number){const d=performance.now()-startTime;this.#samples.push({label,duration:d});}
 report(){
  this.#log.info('Performance samples',this.#samples)
  return this.#samples
 }
 dispose(){this.#samples=[];PerformanceRegressionService.#instance=null}
}
export const perfRegressionService=PerformanceRegressionService.getInstance()
