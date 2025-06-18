'use client'
import { renderingService } from '@/domains/rendering/services/renderingService'
import { Canvas } from '@react-three/fiber'
import { Suspense } from 'react'

export function SimulationCanvas(){
 return (
  <Canvas>
    <Suspense fallback={null}>
      <primitive object={renderingService.scene} />
    </Suspense>
  </Canvas>
 )
}
