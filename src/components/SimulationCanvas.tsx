'use client'
import { Canvas } from '@react-three/fiber'
import { Suspense } from 'react'
import { renderingService } from '@/domains/rendering/services/renderingService'

export function SimulationCanvas () {
  return (
    <Canvas>
      <Suspense fallback={null}>
        {/* Rendering existing Three.js scene graph */}
        <primitive object={renderingService.scene} />
      </Suspense>
    </Canvas>
  )
}
