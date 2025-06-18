import { perfRegressionService as perf } from '@/shared/services/performanceRegressionService'

async function heavyOperation(){
 let sum=0
 for(let i=0;i<1e6;i++) sum+=i
 return sum
}
(async()=>{
 const t=perf.start('heavy-op')
 await heavyOperation()
 perf.end('heavy-op',t)
 console.log(perf.report())
})()
