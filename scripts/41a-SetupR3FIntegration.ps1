# 41a-SetupR3FIntegration.ps1
# Replaces imperative Three.js usage with React Three Fiber components scaffold
# Converts rendering system to declarative React patterns for better integration
# Usage: Executed by automation suite to establish React Three Fiber infrastructure

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $false)]
    [string]$ProjectRoot = (Split-Path $PSScriptRoot -Parent),

    [Parameter(Mandatory = $false)]
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

try {
    Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop
} catch {
    Write-Error "Failed to import utils module: $($_.Exception.Message)"
    exit 1
}

try {
    Write-StepHeader "Setup React Three Fiber Integration (41)"
    Write-InfoLog "Installing R3F packages and converting imperative Three.js to declarative"

    # Check for package manager
    $packageManager = "npm"
    if (Test-PnpmInstalled) {
        $packageManager = "pnpm"
        Write-InfoLog "Using pnpm for package installation"
    } else {
        Write-InfoLog "Using npm for package installation"
    }

    # Install React Three Fiber packages
    $r3fPackages = @(
        "@react-three/fiber@^8.15.0",
        "@react-three/drei@^9.88.0",
        "@react-three/postprocessing@^2.15.0",
        "three@^0.158.0",
        "@types/three@^0.158.0",
        "leva@^0.9.35"
    )

    Write-InfoLog "Installing React Three Fiber packages..."
    if (-not $DryRun) {
        $installCmd = "$packageManager add " + ($r3fPackages -join " ")
        Write-DebugLog "Executing: $installCmd"
        
        Invoke-Expression $installCmd
        if ($LASTEXITCODE -ne 0) {
            throw "Package installation failed with exit code $LASTEXITCODE"
        }
    }
    Write-SuccessLog "React Three Fiber packages installed successfully"

    # Create R3F components directory
    $r3fComponentsPath = Join-Path $ProjectRoot "src/components/r3f"
    if (-not (Test-Path $r3fComponentsPath)) {
        Write-InfoLog "Creating R3F components directory"
        if (-not $DryRun) {
            New-Item -ItemType Directory -Path $r3fComponentsPath -Force | Out-Null
        }
    }

    # Generate R3F Scene component
    $sceneComponentPath = Join-Path $r3fComponentsPath "Scene.tsx"
    $sceneComponentContent = @'
/**
 * React Three Fiber Scene component
 * Provides declarative 3D scene setup with proper camera and lighting
 * 
 * @author Protozoa Automation Suite
 * @generated 41-SetupR3FIntegration.ps1
 */

import React, { Suspense, useRef } from 'react'
import { Canvas, useFrame, useThree } from '@react-three/fiber'
import { OrbitControls, Environment, Html, useProgress } from '@react-three/drei'
import * as THREE from 'three'
import { useSimulationStore } from '@/shared/state'
import { logger } from '@/shared/lib/logger'

/**
 * Loading fallback component
 */
function Loader() {
  const { progress } = useProgress()
  return (
    <Html center>
      <div style={{ color: 'white', fontSize: 14 }}>
        Loading... {progress.toFixed(0)}%
      </div>
    </Html>
  )
}

/**
 * Scene setup component
 */
function SceneSetup() {
  const { camera, gl } = useThree()
  const { backgroundColor, ambientLight } = useSimulationStore()

  React.useEffect(() => {
    // Configure renderer
    gl.setClearColor(backgroundColor)
    gl.shadowMap.enabled = true
    gl.shadowMap.type = THREE.PCFSoftShadowMap
    gl.toneMapping = THREE.ACESFilmicToneMapping
    gl.toneMappingExposure = 1.0
    
    // Configure camera
    if (camera instanceof THREE.PerspectiveCamera) {
      camera.position.set(0, 5, 10)
      camera.lookAt(0, 0, 0)
    }
    
    logger.debug('R3F scene setup completed', { backgroundColor, ambientLight })
  }, [gl, camera, backgroundColor, ambientLight])

  return (
    <>
      <ambientLight intensity={ambientLight} />
      <directionalLight
        position={[10, 10, 5]}
        intensity={1}
        castShadow
        shadow-mapSize-width={2048}
        shadow-mapSize-height={2048}
        shadow-camera-far={50}
        shadow-camera-left={-10}
        shadow-camera-right={10}
        shadow-camera-top={10}
        shadow-camera-bottom={-10}
      />
      <pointLight position={[-10, -10, -10]} intensity={0.5} />
    </>
  )
}

/**
 * Main R3F Scene component
 */
export interface SceneProps {
  children?: React.ReactNode
  enableControls?: boolean
  enableEnvironment?: boolean
  enableShadows?: boolean
  cameraPosition?: [number, number, number]
  onCreated?: (state: any) => void
}

export function Scene({
  children,
  enableControls = true,
  enableEnvironment = true,
  enableShadows = true,
  cameraPosition = [0, 5, 10],
  onCreated
}: SceneProps) {
  const { worldSize, showWireframe } = useSimulationStore()

  return (
    <Canvas
      shadows={enableShadows}
      camera={{ 
        position: cameraPosition,
        fov: 75,
        near: 0.1,
        far: 1000
      }}
      gl={{
        antialias: true,
        alpha: true,
        preserveDrawingBuffer: true
      }}
      onCreated={onCreated}
      style={{ width: '100%', height: '100%' }}
    >
      <Suspense fallback={<Loader />}>
        <SceneSetup />
        
        {enableEnvironment && (
          <Environment preset="city" />
        )}
        
        {enableControls && (
          <OrbitControls
            enablePan={true}
            enableZoom={true}
            enableRotate={true}
            maxPolarAngle={Math.PI / 2}
            minDistance={2}
            maxDistance={50}
          />
        )}
        
        {/* World bounds visualization */}
        {showWireframe && (
          <mesh position={[0, 0, 0]}>
            <boxGeometry args={[worldSize.width, worldSize.height, worldSize.depth]} />
            <meshBasicMaterial color="white" wireframe />
          </mesh>
        )}
        
        {children}
      </Suspense>
    </Canvas>
  )
}

export default Scene
'@

    Write-InfoLog "Generating R3F Scene component"
    if (-not $DryRun) {
        Set-Content -Path $sceneComponentPath -Value $sceneComponentContent -Encoding UTF8
    }
    Write-SuccessLog "Scene.tsx created successfully"

    # Generate R3F Particle System component
    $particleSystemPath = Join-Path $r3fComponentsPath "ParticleSystem.tsx"
    $particleSystemContent = @'
/**
 * React Three Fiber Particle System component
 * Declarative particle rendering using R3F patterns
 * 
 * @author Protozoa Automation Suite
 * @generated 41-SetupR3FIntegration.ps1
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
'@

    Write-InfoLog "Generating R3F ParticleSystem component"
    if (-not $DryRun) {
        Set-Content -Path $particleSystemPath -Value $particleSystemContent -Encoding UTF8
    }
    Write-SuccessLog "ParticleSystem.tsx created successfully"

    # Generate R3F hooks and utilities
    $hooksPath = Join-Path $r3fComponentsPath "hooks.ts"
    $hooksContent = @'
/**
 * React Three Fiber custom hooks
 * Provides reusable R3F functionality and integrations
 * 
 * @author Protozoa Automation Suite
 * @generated 41-SetupR3FIntegration.ps1
 */

import { useRef, useCallback } from 'react'
import { useFrame, useThree } from '@react-three/fiber'
import * as THREE from 'three'
import { useSimulationStore, useParticleStore } from '@/shared/state'
import { logger } from '@/shared/lib/logger'

/**
 * Hook for performance monitoring in R3F
 */
export function useR3FPerformance() {
  const frameTimeRef = useRef(0)
  const lastFrameTimeRef = useRef(performance.now())
  const { updateFrameRate, updateRenderTime } = useSimulationStore()

  useFrame(() => {
    const now = performance.now()
    const deltaTime = now - lastFrameTimeRef.current
    
    if (deltaTime > 0) {
      const frameRate = 1000 / deltaTime
      updateFrameRate(frameRate)
      updateRenderTime(deltaTime)
    }
    
    lastFrameTimeRef.current = now
  })

  return {
    getAverageFrameTime: () => frameTimeRef.current,
    resetStats: () => {
      frameTimeRef.current = 0
      lastFrameTimeRef.current = performance.now()
    }
  }
}

/**
 * Hook for camera controls integration
 */
export function useCameraControls() {
  const { camera } = useThree()
  const { worldSize } = useSimulationStore()

  const focusOnParticles = useCallback(() => {
    const { particles } = useParticleStore.getState()
    
    if (particles.length === 0) return

    // Calculate bounding box of all particles
    const box = new THREE.Box3()
    particles.forEach(particle => {
      box.expandByPoint(new THREE.Vector3(
        particle.position.x,
        particle.position.y,
        particle.position.z
      ))
    })

    // Set camera to view all particles
    const center = box.getCenter(new THREE.Vector3())
    const size = box.getSize(new THREE.Vector3())
    const maxDim = Math.max(size.x, size.y, size.z)
    const distance = maxDim * 2

    if (camera instanceof THREE.PerspectiveCamera) {
      camera.position.copy(center).add(new THREE.Vector3(distance, distance, distance))
      camera.lookAt(center)
    }

    logger.debug('Camera focused on particles', { 
      particleCount: particles.length,
      center: center.toArray(),
      distance 
    })
  }, [camera])

  const resetCamera = useCallback(() => {
    if (camera instanceof THREE.PerspectiveCamera) {
      camera.position.set(0, 5, 10)
      camera.lookAt(0, 0, 0)
    }
  }, [camera])

  return {
    focusOnParticles,
    resetCamera,
    camera
  }
}

/**
 * Hook for R3F scene utilities
 */
export function useSceneUtils() {
  const { gl, scene } = useThree()

  const exportScreenshot = useCallback((filename = 'screenshot.png') => {
    const link = document.createElement('a')
    link.download = filename
    link.href = gl.domElement.toDataURL()
    link.click()
    
    logger.info('Screenshot exported', { filename })
  }, [gl])

  const getSceneStats = useCallback(() => {
    const stats = {
      objects: 0,
      vertices: 0,
      triangles: 0
    }

    scene.traverse((object) => {
      stats.objects++
      
      if (object instanceof THREE.Mesh && object.geometry) {
        const geometry = object.geometry
        if (geometry.attributes.position) {
          stats.vertices += geometry.attributes.position.count
        }
        if (geometry.index) {
          stats.triangles += geometry.index.count / 3
        }
      }
    })

    return stats
  }, [scene])

  return {
    exportScreenshot,
    getSceneStats,
    scene,
    renderer: gl
  }
}
'@

    Write-InfoLog "Generating R3F hooks and utilities"
    if (-not $DryRun) {
        Set-Content -Path $hooksPath -Value $hooksContent -Encoding UTF8
    }
    Write-SuccessLog "hooks.ts created successfully"

    # Create R3F components index
    $r3fIndexPath = Join-Path $r3fComponentsPath "index.ts"
    $r3fIndexContent = @'
/**
 * React Three Fiber components index
 * 
 * @author Protozoa Automation Suite
 * @generated 41-SetupR3FIntegration.ps1
 */

export { Scene } from './Scene'
export type { SceneProps } from './Scene'

export { ParticleSystem } from './ParticleSystem'
export type { ParticleSystemProps, ParticleProps } from './ParticleSystem'

export { 
  useR3FPerformance, 
  useCameraControls, 
  useSceneUtils 
} from './hooks'
'@

    if (-not $DryRun) {
        Set-Content -Path $r3fIndexPath -Value $r3fIndexContent -Encoding UTF8
    }

    # Update main SimulationCanvas to use R3F
    $canvasPath = Join-Path $ProjectRoot "src/components/SimulationCanvas.tsx"
    if (Test-Path $canvasPath) {
        Write-InfoLog "Updating SimulationCanvas.tsx to use R3F components"
        
        $updatedCanvasContent = @'
/**
 * Simulation Canvas component using React Three Fiber
 * Declarative 3D scene rendering with R3F integration
 * 
 * @author Protozoa Automation Suite
 * @updated 41-SetupR3FIntegration.ps1
 */

import React, { useEffect } from 'react'
import { Scene, ParticleSystem, useR3FPerformance } from './r3f'
import { useSimulationStore, useParticleStore } from '@/shared/state'
import { logger } from '@/shared/lib/logger'

/**
 * Performance monitoring component
 */
function PerformanceMonitor() {
  useR3FPerformance()
  return null
}

/**
 * Main simulation canvas component
 */
export function SimulationCanvas() {
  const { isRunning, enableRendering, showPerformanceMetrics } = useSimulationStore()
  const { initializeSystem, isInitialized } = useParticleStore()

  useEffect(() => {
    if (!isInitialized) {
      initializeSystem(500)
      logger.info('Particle system initialized for R3F rendering')
    }
  }, [isInitialized, initializeSystem])

  if (!enableRendering) {
    return (
      <div style={{ 
        width: '100%', 
        height: '100%', 
        display: 'flex', 
        alignItems: 'center', 
        justifyContent: 'center',
        backgroundColor: '#000',
        color: '#fff'
      }}>
        Rendering Disabled
      </div>
    )
  }

  return (
    <div style={{ width: '100%', height: '100%', position: 'relative' }}>
      <Scene 
        enableControls={!isRunning}
        enableShadows={true}
        onCreated={(state) => {
          logger.debug('R3F scene created', { 
            renderer: state.gl.info,
            camera: state.camera.type 
          })
        }}
      >
        <PerformanceMonitor />
        <ParticleSystem 
          useInstancing={true}
          maxParticles={1000}
          showWireframe={false}
        />
      </Scene>
      
      {showPerformanceMetrics && (
        <div style={{
          position: 'absolute',
          top: 10,
          left: 10,
          background: 'rgba(0,0,0,0.7)',
          color: 'white',
          padding: '10px',
          borderRadius: '5px',
          fontFamily: 'monospace',
          fontSize: '12px'
        }}>
          Performance Monitor Active
        </div>
      )}
    </div>
  )
}

export default SimulationCanvas
'@

        if (-not $DryRun) {
            Set-Content -Path $canvasPath -Value $updatedCanvasContent -Encoding UTF8
        }
        Write-SuccessLog "SimulationCanvas.tsx updated for R3F integration"
    } else {
        Write-WarningLog "SimulationCanvas.tsx not found - skipping update"
    }

    Write-SuccessLog "React Three Fiber integration completed successfully"
    Write-InfoLog "Generated: Scene.tsx, ParticleSystem.tsx, hooks.ts, index.ts"
    Write-InfoLog "Updated: SimulationCanvas.tsx for declarative R3F rendering"
    Write-InfoLog "R3F infrastructure ready for high-performance 3D rendering"
    
    exit 0

} catch {
    Write-ErrorLog "React Three Fiber integration setup failed: $($_.Exception.Message)"
    exit 1
} 