// compositionRoot.ts – initializes all domain singletons and wires dependencies
import { animationService } from '@/domains/animation/services/animationService'
import { bitcoinService } from '@/domains/bitcoin/services/bitcoinService'
import { effectService } from '@/domains/effect/services/effectService'
import { formationService } from '@/domains/formation/services/formationService'
import { groupService } from '@/domains/group/services/groupService'
import { lifecycleEngine } from '@/domains/particle/services/lifecycleEngine'
import { particleService } from '@/domains/particle/services/particleService'
import { physicsService } from '@/domains/physics/services/physicsService'
import { renderingService } from '@/domains/rendering/services/renderingService'
import { rngService } from '@/domains/rng/services/rngService'
import { traitService } from '@/domains/trait/services/traitService'

export function initServices(){
  // configure cross dependencies
  traitService.configureDependencies(rngService, bitcoinService)
  particleService.configureDependencies(physicsService, renderingService)
  groupService.configure(rngService)
  renderingService.initialize(document.getElementById('canvas') as HTMLCanvasElement,{formation:formationService,effect:effectService})
  // any other setup
  console.info('Services initialized')
}

export function disposeServices(){
  renderingService.dispose(); physicsService.dispose(); traitService.dispose();
  effectService.dispose(); animationService.dispose(); groupService.dispose();
  lifecycleEngine.dispose();
}

if(typeof window!=='undefined'){(window as any).initServices=initServices}
