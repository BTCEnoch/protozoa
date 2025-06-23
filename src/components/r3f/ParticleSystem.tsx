/**
 * React Three Fiber Particle System component
 * Declarative particle rendering using R3F patterns
 * 
 * @author Protozoa Automation Suite
 * @generated from template
 */

import React, { useRef, useMemo } from 'react'
import { useFrame } from '@react-three/fiber'
import * as THREE from 'three'
import { useParticleStore } from '@/shared/state'
import { logger } from '@/shared/lib/logger'

/**
 * Individual particle component
 */
export interface ParticleProps {
  particle: {
    id: string
    position: { x: number; y: number; z: number }
    velocity: { x: number; y: number; z: number }
    size: number
    color: string
    opacity: number
    age: number
  }
  showWireframe: boolean
}

function Particle({ particle, showWireframe }: ParticleProps) {
  const meshRef = useRef<THREE.Mesh>(null)
  const materialRef = useRef<THREE.Material>(null)

  useFrame((state, delta) => {
    if (!meshRef.current) return

    // Update position
    meshRef.current.position.set(
      particle.position.x,
      particle.position.y,
      particle.position.z
    )

    // Update material opacity based on age
    if (materialRef.current && 'opacity' in materialRef.current) {
      materialRef.current.opacity = particle.opacity
    }

    // Rotate for visual interest
    meshRef.current.rotation.x += delta * 0.5
    meshRef.current.rotation.y += delta * 0.3
  })

  return (
    <mesh ref={meshRef} castShadow receiveShadow>
      <sphereGeometry args={[particle.size, 8, 8]} />
      <meshStandardMaterial
        ref={materialRef}
        color={particle.color}
        opacity={particle.opacity}
        transparent={particle.opacity < 1}
        wireframe={showWireframe}
      />
    </mesh>
  )
}

/**
 * Instanced particle system for better performance
 */
export interface InstancedParticleSystemProps {
  maxParticles?: number
  showWireframe?: boolean
}

function InstancedParticleSystem({ 
  maxParticles = 1000, 
  showWireframe = false 
}: InstancedParticleSystemProps) {
  const meshRef = useRef<THREE.InstancedMesh>(null)
  const { particles, particleSize, particleColor, particleOpacity } = useParticleStore()
  
  const dummy = useMemo(() => new THREE.Object3D(), [])
  
  useFrame(() => {
    if (!meshRef.current) return

    // Update instance matrices
    particles.forEach((particle, index) => {
      if (index >= maxParticles) return

      dummy.position.set(
        particle.position.x,
        particle.position.y,
        particle.position.z
      )
      
      dummy.scale.setScalar(particle.size || particleSize)
      dummy.updateMatrix()
      
      meshRef.current!.setMatrixAt(index, dummy.matrix)
    })

    // Set instance count
    meshRef.current.count = Math.min(particles.length, maxParticles)
    meshRef.current.instanceMatrix.needsUpdate = true
  })

  return (
    <instancedMesh
      ref={meshRef}
      args={[null as any, null as any, maxParticles]}
      castShadow
      receiveShadow
    >
      <sphereGeometry args={[1, 8, 8]} />
      <meshStandardMaterial
        color={particleColor}
        opacity={particleOpacity}
        transparent={particleOpacity < 1}
        wireframe={showWireframe}
      />
    </instancedMesh>
  )
}

/**
 * Main particle system component
 */
export interface ParticleSystemProps {
  useInstancing?: boolean
  maxParticles?: number
  showWireframe?: boolean
}

export function ParticleSystem({ 
  useInstancing = true, 
  maxParticles = 1000,
  showWireframe = false 
}: ParticleSystemProps) {
  const { particles, isInitialized } = useParticleStore()

  React.useEffect(() => {
    logger.debug('R3F ParticleSystem mounted', { 
      particleCount: particles.length,
      useInstancing,
      maxParticles 
    })
  }, [particles.length, useInstancing, maxParticles])

  if (!isInitialized) {
    return null
  }

  if (useInstancing) {
    return (
      <InstancedParticleSystem 
        maxParticles={maxParticles} 
        showWireframe={showWireframe}
      />
    )
  }

  return (
    <group>
      {particles.map((particle) => (
        <Particle 
          key={particle.id} 
          particle={particle} 
          showWireframe={showWireframe}
        />
      ))}
    </group>
  )
}

export default ParticleSystem 