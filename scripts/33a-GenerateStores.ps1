# 33a-GenerateStores.ps1
# Creates Zustand stores: useSimulationStore, useParticleStore with devtools
# Provides centralized state management for simulation and particle systems
# Usage: Executed by automation suite to establish state management infrastructure

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
    Write-StepHeader "Generate Zustand Stores (33)"
    Write-InfoLog "Creating Zustand stores with devtools integration"

    # Check for package manager and install Zustand
    $packageManager = "npm"
    if (Test-PnpmInstalled) {
        $packageManager = "pnpm"
        Write-InfoLog "Using pnpm for package installation"
    } else {
        Write-InfoLog "Using npm for package installation"
    }

    # Install Zustand packages
    $zustandPackages = @(
        "zustand@^4.4.7",
        "@types/node@^20.0.0"
    )

    Write-InfoLog "Installing Zustand packages..."
    if (-not $DryRun) {
        $installCmd = "$packageManager add " + ($zustandPackages -join " ")
        Write-DebugLog "Executing: $installCmd"
        
        Invoke-Expression $installCmd
        if ($LASTEXITCODE -ne 0) {
            throw "Package installation failed with exit code $LASTEXITCODE"
        }
    }
    Write-SuccessLog "Zustand packages installed successfully"

    # Create state directory if it doesn't exist
    $statePath = Join-Path $ProjectRoot "src/shared/state"
    if (-not (Test-Path $statePath)) {
        Write-InfoLog "Creating state directory"
        if (-not $DryRun) {
            New-Item -ItemType Directory -Path $statePath -Force | Out-Null
        }
    }

    # Generate useSimulationStore
    $simulationStorePath = Join-Path $statePath "useSimulationStore.ts"
    $simulationStoreContent = @'
/**
 * Zustand store for simulation state management
 * Provides centralized state for simulation control and monitoring
 * 
 * @author Protozoa Automation Suite
 * @generated 33-GenerateStores.ps1
 */

import { create } from 'zustand'
import { devtools } from 'zustand/middleware'
import { logger } from '@/shared/lib/logger'

/**
 * Simulation state interface
 */
export interface SimulationState {
  // Simulation control
  isRunning: boolean
  isPaused: boolean
  speed: number
  timeScale: number
  
  // Performance metrics
  frameRate: number
  totalFrames: number
  renderTime: number
  physicsTime: number
  
  // Simulation settings
  targetFrameRate: number
  enablePhysics: boolean
  enableRendering: boolean
  enableEffects: boolean
  
  // Environment settings
  worldSize: { width: number; height: number; depth: number }
  backgroundColor: string
  ambientLight: number
  
  // Debug settings
  showDebugInfo: boolean
  showPerformanceMetrics: boolean
  showWireframe: boolean
  enableLogging: boolean
}

/**
 * Simulation actions interface
 */
export interface SimulationActions {
  // Simulation control actions
  startSimulation: () => void
  pauseSimulation: () => void
  stopSimulation: () => void
  resetSimulation: () => void
  setSpeed: (speed: number) => void
  setTimeScale: (timeScale: number) => void
  
  // Performance actions
  updateFrameRate: (frameRate: number) => void
  updateRenderTime: (renderTime: number) => void
  updatePhysicsTime: (physicsTime: number) => void
  incrementFrameCount: () => void
  
  // Settings actions
  setTargetFrameRate: (frameRate: number) => void
  togglePhysics: () => void
  toggleRendering: () => void
  toggleEffects: () => void
  
  // Environment actions
  setWorldSize: (size: { width: number; height: number; depth: number }) => void
  setBackgroundColor: (color: string) => void
  setAmbientLight: (intensity: number) => void
  
  // Debug actions
  toggleDebugInfo: () => void
  togglePerformanceMetrics: () => void
  toggleWireframe: () => void
  toggleLogging: () => void
  
  // Utility actions
  getSimulationStats: () => {
    avgFrameRate: number
    totalRunTime: number
    efficiency: number
  }
}

/**
 * Combined simulation store type
 */
export type SimulationStore = SimulationState & SimulationActions

/**
 * Initial simulation state
 */
const initialState: SimulationState = {
  // Simulation control
  isRunning: false,
  isPaused: false,
  speed: 1.0,
  timeScale: 1.0,
  
  // Performance metrics
  frameRate: 0,
  totalFrames: 0,
  renderTime: 0,
  physicsTime: 0,
  
  // Simulation settings
  targetFrameRate: 60,
  enablePhysics: true,
  enableRendering: true,
  enableEffects: true,
  
  // Environment settings
  worldSize: { width: 1000, height: 1000, depth: 1000 },
  backgroundColor: '#000000',
  ambientLight: 0.1,
  
  // Debug settings
  showDebugInfo: false,
  showPerformanceMetrics: false,
  showWireframe: false,
  enableLogging: true
}

/**
 * Zustand simulation store with devtools
 */
export const useSimulationStore = create<SimulationStore>()(
  devtools(
    (set, get) => ({
      ...initialState,
      
      // Simulation control actions
      startSimulation: () => {
        set({ isRunning: true, isPaused: false }, false, 'startSimulation')
        logger.info('Simulation started')
      },
      
      pauseSimulation: () => {
        set({ isPaused: true }, false, 'pauseSimulation')
        logger.info('Simulation paused')
      },
      
      stopSimulation: () => {
        set({ isRunning: false, isPaused: false }, false, 'stopSimulation')
        logger.info('Simulation stopped')
      },
      
      resetSimulation: () => {
        set({ 
          ...initialState,
          totalFrames: 0,
          frameRate: 0,
          renderTime: 0,
          physicsTime: 0
        }, false, 'resetSimulation')
        logger.info('Simulation reset')
      },
      
      setSpeed: (speed: number) => {
        const clampedSpeed = Math.max(0.1, Math.min(5.0, speed))
        set({ speed: clampedSpeed }, false, 'setSpeed')
        logger.debug('Simulation speed changed', { speed: clampedSpeed })
      },
      
      setTimeScale: (timeScale: number) => {
        const clampedTimeScale = Math.max(0.1, Math.min(10.0, timeScale))
        set({ timeScale: clampedTimeScale }, false, 'setTimeScale')
        logger.debug('Time scale changed', { timeScale: clampedTimeScale })
      },
      
      // Performance actions
      updateFrameRate: (frameRate: number) => {
        set({ frameRate }, false, 'updateFrameRate')
      },
      
      updateRenderTime: (renderTime: number) => {
        set({ renderTime }, false, 'updateRenderTime')
      },
      
      updatePhysicsTime: (physicsTime: number) => {
        set({ physicsTime }, false, 'updatePhysicsTime')
      },
      
      incrementFrameCount: () => {
        set((state) => ({ totalFrames: state.totalFrames + 1 }), false, 'incrementFrameCount')
      },
      
      // Settings actions
      setTargetFrameRate: (frameRate: number) => {
        const clampedFrameRate = Math.max(15, Math.min(144, frameRate))
        set({ targetFrameRate: clampedFrameRate }, false, 'setTargetFrameRate')
        logger.info('Target frame rate changed', { targetFrameRate: clampedFrameRate })
      },
      
      togglePhysics: () => {
        set((state) => ({ enablePhysics: !state.enablePhysics }), false, 'togglePhysics')
        logger.info('Physics toggled', { enablePhysics: !get().enablePhysics })
      },
      
      toggleRendering: () => {
        set((state) => ({ enableRendering: !state.enableRendering }), false, 'toggleRendering')
        logger.info('Rendering toggled', { enableRendering: !get().enableRendering })
      },
      
      toggleEffects: () => {
        set((state) => ({ enableEffects: !state.enableEffects }), false, 'toggleEffects')
        logger.info('Effects toggled', { enableEffects: !get().enableEffects })
      },
      
      // Environment actions
      setWorldSize: (size: { width: number; height: number; depth: number }) => {
        set({ worldSize: size }, false, 'setWorldSize')
        logger.info('World size changed', { worldSize: size })
      },
      
      setBackgroundColor: (color: string) => {
        set({ backgroundColor: color }, false, 'setBackgroundColor')
        logger.debug('Background color changed', { backgroundColor: color })
      },
      
      setAmbientLight: (intensity: number) => {
        const clampedIntensity = Math.max(0, Math.min(1, intensity))
        set({ ambientLight: clampedIntensity }, false, 'setAmbientLight')
        logger.debug('Ambient light changed', { ambientLight: clampedIntensity })
      },
      
      // Debug actions
      toggleDebugInfo: () => {
        set((state) => ({ showDebugInfo: !state.showDebugInfo }), false, 'toggleDebugInfo')
      },
      
      togglePerformanceMetrics: () => {
        set((state) => ({ showPerformanceMetrics: !state.showPerformanceMetrics }), false, 'togglePerformanceMetrics')
      },
      
      toggleWireframe: () => {
        set((state) => ({ showWireframe: !state.showWireframe }), false, 'toggleWireframe')
      },
      
      toggleLogging: () => {
        set((state) => ({ enableLogging: !state.enableLogging }), false, 'toggleLogging')
      },
      
      // Utility actions
      getSimulationStats: () => {
        const state = get()
        const avgFrameRate = state.frameRate
        const totalRunTime = state.totalFrames / Math.max(state.frameRate, 1)
        const efficiency = Math.min(state.frameRate / state.targetFrameRate, 1)
        
        return {
          avgFrameRate,
          totalRunTime,
          efficiency
        }
      }
    }),
    {
      name: 'simulation-store',
      enabled: process.env.NODE_ENV === 'development'
    }
  )
)

// Export store selectors for performance optimization
export const useSimulationControls = () => useSimulationStore((state) => ({
  isRunning: state.isRunning,
  isPaused: state.isPaused,
  speed: state.speed,
  timeScale: state.timeScale,
  startSimulation: state.startSimulation,
  pauseSimulation: state.pauseSimulation,
  stopSimulation: state.stopSimulation,
  resetSimulation: state.resetSimulation,
  setSpeed: state.setSpeed,
  setTimeScale: state.setTimeScale
}))

export const useSimulationMetrics = () => useSimulationStore((state) => ({
  frameRate: state.frameRate,
  totalFrames: state.totalFrames,
  renderTime: state.renderTime,
  physicsTime: state.physicsTime,
  targetFrameRate: state.targetFrameRate,
  updateFrameRate: state.updateFrameRate,
  updateRenderTime: state.updateRenderTime,
  updatePhysicsTime: state.updatePhysicsTime,
  incrementFrameCount: state.incrementFrameCount
}))

export const useSimulationSettings = () => useSimulationStore((state) => ({
  enablePhysics: state.enablePhysics,
  enableRendering: state.enableRendering,
  enableEffects: state.enableEffects,
  worldSize: state.worldSize,
  backgroundColor: state.backgroundColor,
  ambientLight: state.ambientLight,
  togglePhysics: state.togglePhysics,
  toggleRendering: state.toggleRendering,
  toggleEffects: state.toggleEffects,
  setWorldSize: state.setWorldSize,
  setBackgroundColor: state.setBackgroundColor,
  setAmbientLight: state.setAmbientLight
}))

export const useSimulationDebug = () => useSimulationStore((state) => ({
  showDebugInfo: state.showDebugInfo,
  showPerformanceMetrics: state.showPerformanceMetrics,
  showWireframe: state.showWireframe,
  enableLogging: state.enableLogging,
  toggleDebugInfo: state.toggleDebugInfo,
  togglePerformanceMetrics: state.togglePerformanceMetrics,
  toggleWireframe: state.toggleWireframe,
  toggleLogging: state.toggleLogging
}))
'@

    Write-InfoLog "Generating useSimulationStore with devtools"
    if (-not $DryRun) {
        Set-Content -Path $simulationStorePath -Value $simulationStoreContent -Encoding UTF8
    }
    Write-SuccessLog "useSimulationStore.ts created successfully"

    # Generate useParticleStore
    $particleStorePath = Join-Path $statePath "useParticleStore.ts"
    $particleStoreContent = @'
/**
 * Zustand store for particle system state management
 * Provides centralized state for particle control and monitoring
 * 
 * @author Protozoa Automation Suite
 * @generated 33-GenerateStores.ps1
 */

import { create } from 'zustand'
import { devtools } from 'zustand/middleware'
import { logger } from '@/shared/lib/logger'

/**
 * Particle system state interface
 */
export interface ParticleState {
  // Particle collections
  particles: any[]
  activeParticles: number
  maxParticles: number
  pooledParticles: any[]
  
  // System status
  isInitialized: boolean
  isUpdating: boolean
  needsReset: boolean
  
  // Performance metrics
  updateTime: number
  allocationsPerFrame: number
  totalAllocations: number
  poolUtilization: number
  
  // Configuration
  particleSize: number
  particleLifetime: number
  spawnRate: number
  enablePhysics: boolean
  enableCollisions: boolean
  
  // Visual settings
  particleColor: string
  particleOpacity: number
  enableTrails: boolean
  trailLength: number
}

/**
 * Particle actions interface
 */
export interface ParticleActions {
  // System management
  initializeSystem: (maxParticles: number) => void
  resetSystem: () => void
  disposeSystem: () => void
  
  // Particle management
  addParticle: (particle: any) => void
  removeParticle: (id: string) => void
  updateParticles: (deltaTime: number) => void
  clearParticles: () => void
  
  // Pool management
  getParticleFromPool: () => any | null
  returnParticleToPool: (particle: any) => void
  optimizePool: () => void
  
  // Performance tracking
  updatePerformanceMetrics: (updateTime: number, allocations: number) => void
  getPoolStats: () => {
    totalParticles: number
    activeParticles: number
    pooledParticles: number
    utilization: number
  }
  
  // Configuration
  setMaxParticles: (max: number) => void
  setParticleSize: (size: number) => void
  setParticleLifetime: (lifetime: number) => void
  setSpawnRate: (rate: number) => void
  togglePhysics: () => void
  toggleCollisions: () => void
  
  // Visual settings
  setParticleColor: (color: string) => void
  setParticleOpacity: (opacity: number) => void
  toggleTrails: () => void
  setTrailLength: (length: number) => void
}

/**
 * Combined particle store type
 */
export type ParticleStore = ParticleState & ParticleActions

/**
 * Initial particle state
 */
const initialState: ParticleState = {
  // Particle collections
  particles: [],
  activeParticles: 0,
  maxParticles: 500,
  pooledParticles: [],
  
  // System status
  isInitialized: false,
  isUpdating: false,
  needsReset: false,
  
  // Performance metrics
  updateTime: 0,
  allocationsPerFrame: 0,
  totalAllocations: 0,
  poolUtilization: 0,
  
  // Configuration
  particleSize: 1.0,
  particleLifetime: 5.0,
  spawnRate: 10,
  enablePhysics: true,
  enableCollisions: false,
  
  // Visual settings
  particleColor: '#ffffff',
  particleOpacity: 1.0,
  enableTrails: false,
  trailLength: 10
}

/**
 * Zustand particle store with devtools
 */
export const useParticleStore = create<ParticleStore>()(
  devtools(
    (set, get) => ({
      ...initialState,
      
      // System management
      initializeSystem: (maxParticles: number) => {
        set({ 
          maxParticles,
          isInitialized: true,
          particles: [],
          pooledParticles: [],
          activeParticles: 0
        }, false, 'initializeSystem')
        logger.info('Particle system initialized', { maxParticles })
      },
      
      resetSystem: () => {
        const state = get()
        set({ 
          ...initialState,
          maxParticles: state.maxParticles,
          isInitialized: true,
          particles: [],
          pooledParticles: [],
          activeParticles: 0,
          totalAllocations: 0
        }, false, 'resetSystem')
        logger.info('Particle system reset')
      },
      
      disposeSystem: () => {
        set({ 
          ...initialState,
          isInitialized: false
        }, false, 'disposeSystem')
        logger.info('Particle system disposed')
      },
      
      // Particle management
      addParticle: (particle: any) => {
        const state = get()
        if (state.activeParticles >= state.maxParticles) {
          logger.warn('Cannot add particle - maximum limit reached', { 
            activeParticles: state.activeParticles,
            maxParticles: state.maxParticles 
          })
          return
        }
        
        set((state) => ({
          particles: [...state.particles, particle],
          activeParticles: state.activeParticles + 1,
          totalAllocations: state.totalAllocations + 1
        }), false, 'addParticle')
      },
      
      removeParticle: (id: string) => {
        set((state) => {
          const particles = state.particles.filter(p => p.id !== id)
          return {
            particles,
            activeParticles: particles.length
          }
        }, false, 'removeParticle')
      },
      
      updateParticles: (deltaTime: number) => {
        const startTime = performance.now()
        
        set((state) => {
          const updatedParticles = state.particles.filter(particle => {
            // Update particle lifecycle
            particle.age += deltaTime
            return particle.age < state.particleLifetime
          })
          
          return {
            particles: updatedParticles,
            activeParticles: updatedParticles.length,
            isUpdating: false
          }
        }, false, 'updateParticles')
        
        const updateTime = performance.now() - startTime
        get().updatePerformanceMetrics(updateTime, 0)
      },
      
      clearParticles: () => {
        set({ 
          particles: [],
          activeParticles: 0,
          pooledParticles: []
        }, false, 'clearParticles')
        logger.info('All particles cleared')
      },
      
      // Pool management
      getParticleFromPool: () => {
        const state = get()
        if (state.pooledParticles.length > 0) {
          const particle = state.pooledParticles[state.pooledParticles.length - 1]
          set((state) => ({
            pooledParticles: state.pooledParticles.slice(0, -1)
          }), false, 'getParticleFromPool')
          return particle
        }
        return null
      },
      
      returnParticleToPool: (particle: any) => {
        if (!particle) return
        
        // Reset particle properties
        particle.age = 0
        particle.velocity = { x: 0, y: 0, z: 0 }
        
        set((state) => ({
          pooledParticles: [...state.pooledParticles, particle]
        }), false, 'returnParticleToPool')
      },
      
      optimizePool: () => {
        const state = get()
        const targetPoolSize = Math.min(state.maxParticles * 0.2, 100)
        
        if (state.pooledParticles.length > targetPoolSize) {
          set((state) => ({
            pooledParticles: state.pooledParticles.slice(0, targetPoolSize)
          }), false, 'optimizePool')
          
          logger.debug('Particle pool optimized', { 
            previousSize: state.pooledParticles.length,
            newSize: targetPoolSize 
          })
        }
      },
      
      // Performance tracking
      updatePerformanceMetrics: (updateTime: number, allocations: number) => {
        set((state) => {
          const poolUtilization = state.maxParticles > 0 
            ? state.activeParticles / state.maxParticles 
            : 0
          
          return {
            updateTime,
            allocationsPerFrame: allocations,
            poolUtilization
          }
        }, false, 'updatePerformanceMetrics')
      },
      
      getPoolStats: () => {
        const state = get()
        return {
          totalParticles: state.particles.length + state.pooledParticles.length,
          activeParticles: state.activeParticles,
          pooledParticles: state.pooledParticles.length,
          utilization: state.poolUtilization
        }
      },
      
      // Configuration
      setMaxParticles: (max: number) => {
        const clampedMax = Math.max(1, Math.min(10000, max))
        set({ maxParticles: clampedMax }, false, 'setMaxParticles')
        logger.info('Max particles changed', { maxParticles: clampedMax })
      },
      
      setParticleSize: (size: number) => {
        const clampedSize = Math.max(0.1, Math.min(10.0, size))
        set({ particleSize: clampedSize }, false, 'setParticleSize')
      },
      
      setParticleLifetime: (lifetime: number) => {
        const clampedLifetime = Math.max(0.1, Math.min(60.0, lifetime))
        set({ particleLifetime: clampedLifetime }, false, 'setParticleLifetime')
      },
      
      setSpawnRate: (rate: number) => {
        const clampedRate = Math.max(0, Math.min(1000, rate))
        set({ spawnRate: clampedRate }, false, 'setSpawnRate')
      },
      
      togglePhysics: () => {
        set((state) => ({ enablePhysics: !state.enablePhysics }), false, 'togglePhysics')
        logger.info('Particle physics toggled', { enablePhysics: !get().enablePhysics })
      },
      
      toggleCollisions: () => {
        set((state) => ({ enableCollisions: !state.enableCollisions }), false, 'toggleCollisions')
        logger.info('Particle collisions toggled', { enableCollisions: !get().enableCollisions })
      },
      
      // Visual settings
      setParticleColor: (color: string) => {
        set({ particleColor: color }, false, 'setParticleColor')
      },
      
      setParticleOpacity: (opacity: number) => {
        const clampedOpacity = Math.max(0, Math.min(1, opacity))
        set({ particleOpacity: clampedOpacity }, false, 'setParticleOpacity')
      },
      
      toggleTrails: () => {
        set((state) => ({ enableTrails: !state.enableTrails }), false, 'toggleTrails')
      },
      
      setTrailLength: (length: number) => {
        const clampedLength = Math.max(1, Math.min(100, length))
        set({ trailLength: clampedLength }, false, 'setTrailLength')
      }
    }),
    {
      name: 'particle-store',
      enabled: process.env.NODE_ENV === 'development'
    }
  )
)

// Export store selectors for performance optimization
export const useParticleSystem = () => useParticleStore((state) => ({
  particles: state.particles,
  activeParticles: state.activeParticles,
  maxParticles: state.maxParticles,
  isInitialized: state.isInitialized,
  initializeSystem: state.initializeSystem,
  resetSystem: state.resetSystem,
  disposeSystem: state.disposeSystem
}))

export const useParticleManagement = () => useParticleStore((state) => ({
  addParticle: state.addParticle,
  removeParticle: state.removeParticle,
  updateParticles: state.updateParticles,
  clearParticles: state.clearParticles,
  getParticleFromPool: state.getParticleFromPool,
  returnParticleToPool: state.returnParticleToPool,
  optimizePool: state.optimizePool
}))

export const useParticleConfig = () => useParticleStore((state) => ({
  particleSize: state.particleSize,
  particleLifetime: state.particleLifetime,
  spawnRate: state.spawnRate,
  enablePhysics: state.enablePhysics,
  enableCollisions: state.enableCollisions,
  setParticleSize: state.setParticleSize,
  setParticleLifetime: state.setParticleLifetime,
  setSpawnRate: state.setSpawnRate,
  togglePhysics: state.togglePhysics,
  toggleCollisions: state.toggleCollisions
}))

export const useParticleVisuals = () => useParticleStore((state) => ({
  particleColor: state.particleColor,
  particleOpacity: state.particleOpacity,
  enableTrails: state.enableTrails,
  trailLength: state.trailLength,
  setParticleColor: state.setParticleColor,
  setParticleOpacity: state.setParticleOpacity,
  toggleTrails: state.toggleTrails,
  setTrailLength: state.setTrailLength
}))

export const useParticleMetrics = () => useParticleStore((state) => ({
  updateTime: state.updateTime,
  allocationsPerFrame: state.allocationsPerFrame,
  totalAllocations: state.totalAllocations,
  poolUtilization: state.poolUtilization,
  getPoolStats: state.getPoolStats,
  updatePerformanceMetrics: state.updatePerformanceMetrics
}))
'@

    Write-InfoLog "Generating useParticleStore with devtools"
    if (-not $DryRun) {
        Set-Content -Path $particleStorePath -Value $particleStoreContent -Encoding UTF8
    }
    Write-SuccessLog "useParticleStore.ts created successfully"

    # Create store index file
    $storeIndexPath = Join-Path $statePath "index.ts"
    $storeIndexContent = @'
/**
 * Zustand stores index exports
 * 
 * @author Protozoa Automation Suite
 * @generated 33-GenerateStores.ps1
 */

export * from './useSimulationStore'
export * from './useParticleStore'
'@

    if (-not $DryRun) {
        Set-Content -Path $storeIndexPath -Value $storeIndexContent -Encoding UTF8
    }

    Write-SuccessLog "Zustand stores setup completed successfully"
    Write-InfoLog "Generated: useSimulationStore.ts, useParticleStore.ts, index.ts"
    Write-InfoLog "State management infrastructure ready with devtools integration"
    
    exit 0

} catch {
    Write-ErrorLog "Generate Stores failed: $($_.Exception.Message)"
    exit 1
} 