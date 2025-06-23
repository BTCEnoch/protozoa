'use client'
import React, { useRef, useEffect, useState } from 'react'
import * as THREE from 'three'
import { particleService } from '@/domains/particle/services/ParticleService'
import { renderingService } from '@/domains/rendering/services/RenderingService'
import { rngService } from '@/domains/rng/services/RNGService'
import { traitService } from '@/domains/trait/services/TraitService'
import { ParticleType } from '@/domains/particle/types/particle.types'
import { createServiceLogger } from '@/shared/lib/logger'

// Declare JSX namespace for HTML elements
declare global {
  namespace JSX {
    interface IntrinsicElements {
      div: React.DetailedHTMLProps<React.HTMLAttributes<HTMLDivElement>, HTMLDivElement>
      h3: React.DetailedHTMLProps<React.HTMLAttributes<HTMLHeadingElement>, HTMLHeadingElement>
      p: React.DetailedHTMLProps<React.HTMLAttributes<HTMLParagraphElement>, HTMLParagraphElement>
      pre: React.DetailedHTMLProps<React.HTMLAttributes<HTMLPreElement>, HTMLPreElement>
      button: React.DetailedHTMLProps<React.ButtonHTMLAttributes<HTMLButtonElement>, HTMLButtonElement>
      style: React.DetailedHTMLProps<React.StyleHTMLAttributes<HTMLStyleElement>, HTMLStyleElement>
    }
  }
}

/**
 * SimulationCanvas Component
 * @description Main THREE.js canvas component that renders Bitcoin Ordinals digital organisms
 * @author Protozoa Development Team
 * @version 1.0.0
 */
export function SimulationCanvas() {
  const mountRef = useRef<HTMLDivElement>(null)
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [particleCount, setParticleCount] = useState(0)
  const [fps, setFps] = useState(0)
  
  // Service references
  const animationFrameRef = useRef<number>()
  const lastFrameTimeRef = useRef<number>(0)
  const fpsCounterRef = useRef<number>(0)
  const fpsUpdateTimeRef = useRef<number>(0)
  const isInitializedRef = useRef<boolean>(false)
  
  const logger = createServiceLogger('SimulationCanvas')

  // React effect for simulation initialization
  useEffect(() => {
    // CRITICAL: React StrictMode protection - prevent double initialization
    if (isInitializedRef.current) {
      logger.warn('âš ï¸ [STRICTMODE] Simulation already initialized, skipping duplicate initialization')
      return
    }

    // Immediately mark as initializing to prevent race conditions
    isInitializedRef.current = true

    async function initializeSimulation() {
      try {
        setIsLoading(true)
        setError(null)
        
        logger.info('ðŸš€ Starting Bitcoin Ordinals simulation initialization...')
        
        // Check particle service pool status before starting
        const poolStatus = particleService.getPoolStatus()
        logger.info('ðŸ” Particle pool status before initialization:', poolStatus)
        
        // CRITICAL FIX: Validate and fix pool corruption instead of full reset
        const wasCorrupted = particleService.validateAndFixPool()
        if (wasCorrupted) {
          const fixedPoolStatus = particleService.getPoolStatus()
          logger.info('âœ… Pool corruption fixed:', fixedPoolStatus)
        }
        
        // Initialize services
        await particleService.initialize({
          maxParticles: 10000,
          useInstancing: true,
          useObjectPooling: true
        })
        
        await rngService.initialize({
          defaultSeed: Date.now(),
          algorithm: 'mulberry32'
        })
        
        // Initialize trait service with Bitcoin block data (placeholder)
        await traitService.initialize({
          enableInheritance: true,
          baseMutationRate: 0.1
        })
        
        // Setup THREE.js renderer - CRITICAL FIX
        if (!mountRef.current) {
          throw new Error('Mount point not available')
        }

        // Clear any existing content from mount point
        mountRef.current.innerHTML = ''
        
        // Create canvas for THREE.js renderer
        const canvas = document.createElement('canvas')
        canvas.style.width = '100%'
        canvas.style.height = '100%'
        canvas.style.display = 'block'
        
        // Initialize rendering service with canvas
        renderingService.initialize(canvas)
        
        // CRITICAL: Attach the canvas to the DOM mount point
        mountRef.current.appendChild(canvas)
        logger.info('âœ… THREE.js renderer canvas attached to DOM')
        
        // Create initial particle system (with existence check)
        logger.info('ðŸ§¬ Creating initial particle system...')
        let particleSystem
        try {
          particleSystem = particleService.createSystem({
            id: 'main-organisms',
            name: 'Bitcoin Organisms',
            maxParticles: 500,
            position: { x: 0, y: 0, z: 0 },
            bounds: {
              min: { x: -50, y: -50, z: -50 },
              max: { x: 50, y: 50, z: 50 }
            },
            defaultType: ParticleType.BASIC,
            enablePhysics: true,
            enableCollisions: false
          })
        } catch (systemError) {
          // If system already exists, get the existing one and clean it
          logger.warn('âš ï¸ Particle system already exists, cleaning and reusing...')
          const systems = particleService.getSystems()
          particleSystem = systems.get('main-organisms')
          if (!particleSystem) {
            throw new Error('Failed to create or retrieve particle system')
          }
          
          // Clean existing particles from the system
          if (particleSystem.particles.length > 0) {
            const existingIds = particleSystem.particles.map(p => p.id)
            particleService.removeParticles('main-organisms', existingIds)
            logger.info(`ðŸ§¹ Cleaned ${existingIds.length} existing particles from system`)
          }
        }
        
        // Check pool status after system creation
        const poolStatusAfterSystem = particleService.getPoolStatus()
        logger.info('ðŸ” Particle pool status after system creation:', poolStatusAfterSystem)
        
        // Spawn initial particles (organisms) only if system is empty
        const currentParticleCount = particleSystem.activeParticles || 0
        logger.info(`ðŸ” Current particle count in system: ${currentParticleCount}`)
        
        if (currentParticleCount === 0) {
          logger.info('ðŸŒ± Spawning initial organisms...')
          
          // Spawn particles one by one with detailed logging
          let successfulSpawns = 0
          for (let i = 0; i < 50; i++) {
            const position = new THREE.Vector3(
              (Math.random() - 0.5) * 20,
              (Math.random() - 0.5) * 20,
              (Math.random() - 0.5) * 20
            )
            
            const velocity = new THREE.Vector3(
              (Math.random() - 0.5) * 2,
              (Math.random() - 0.5) * 2,
              (Math.random() - 0.5) * 2
            )
            
            const particleId = particleService.spawnParticle('main-organisms', {
              position,
              velocity,
              lifetime: 30 + Math.random() * 20,
              size: 0.5 + Math.random() * 0.5,
              color: new THREE.Color().setHSL(Math.random(), 0.7, 0.6)
            })
            
            if (particleId) {
              successfulSpawns++
            } else {
              logger.warn(`âŒ Failed to spawn particle ${i + 1}/50`)
              // Check pool status when spawn fails
              const poolStatus = particleService.getPoolStatus()
              logger.warn('ðŸ” Pool status at failure:', poolStatus)
            }
            
            // Log progress every 25 particles instead of every 10 to reduce spam
            if ((i + 1) % 25 === 0 || i === 49) {
              logger.info(`ðŸ“Š Spawned ${successfulSpawns}/${i + 1} particles so far`)
            }
          }
          
          logger.info(`âœ… Particle spawning complete: ${successfulSpawns}/50 particles created`)
          
          // Verify final count
          const finalCount = particleSystem.activeParticles
          logger.info(`ðŸ”¢ Final particle count: ${finalCount}`)
          
          if (finalCount !== successfulSpawns) {
            logger.warn(`âš ï¸ Particle count mismatch! Expected: ${successfulSpawns}, Actual: ${finalCount}`)
          }
        } else {
          logger.info(`ðŸ”„ Using existing organisms (${currentParticleCount} particles)`)
        }
        
        // Setup camera position
        renderingService.camera.position.set(0, 0, 30)
        renderingService.camera.lookAt(0, 0, 0)
        
        // Add some basic lighting
        const ambientLight = new THREE.AmbientLight(0x404040, 0.4)
        renderingService.scene.add(ambientLight)
        
        const directionalLight = new THREE.DirectionalLight(0xffffff, 0.8)
        directionalLight.position.set(10, 10, 5)
        renderingService.scene.add(directionalLight)
        
        // Debug: Log camera and scene info
        logger.info('ðŸŽ¥ Camera setup complete', {
          position: { x: renderingService.camera.position.x, y: renderingService.camera.position.y, z: renderingService.camera.position.z },
          target: { x: 0, y: 0, z: 0 },
          fov: renderingService.camera.fov,
          aspect: renderingService.camera.aspect
        })
        
        logger.info('ðŸ’¡ Lighting setup complete', {
          ambientLight: { color: ambientLight.color.getHex(), intensity: ambientLight.intensity },
          directionalLight: { color: directionalLight.color.getHex(), intensity: directionalLight.intensity }
        })
        
        logger.info('ðŸŽ­ Scene status', {
          sceneChildren: renderingService.scene.children.length,
          canvasSize: { width: renderingService.renderer.domElement.width, height: renderingService.renderer.domElement.height },
          canvasParent: !!renderingService.renderer.domElement.parentElement
        })
        
        // Start animation loop
        startAnimationLoop()
        
        // Mark as successfully initialized AFTER everything succeeds
        setIsLoading(false)
        logger.info('âœ… Simulation initialized successfully')
        
      } catch (err) {
        const errorMsg = err instanceof Error ? err.message : 'Unknown error'
        setError(errorMsg)
        setIsLoading(false)
        // CRITICAL: Reset initialization flag on error so retry is possible
        isInitializedRef.current = false
        logger.error('âŒ Failed to initialize simulation:', errorMsg)
      }
    }

    function startAnimationLoop() {
      function animate(currentTime: number) {
        const deltaTime = (currentTime - lastFrameTimeRef.current) / 1000
        lastFrameTimeRef.current = currentTime
        
        // Update FPS counter
        fpsCounterRef.current++
        if (currentTime - fpsUpdateTimeRef.current >= 1000) {
          setFps(fpsCounterRef.current)
          fpsCounterRef.current = 0
          fpsUpdateTimeRef.current = currentTime
        }
        
        // Update particles
        particleService.update(deltaTime)
        
        // Update particle count
        const systems = particleService.getSystems()
        let totalParticles = 0
        for (const system of systems.values()) {
          totalParticles += system.activeParticles
        }
        setParticleCount(totalParticles)
        
        // Render scene
        particleService.render(renderingService.scene)
        renderingService.renderFrame(deltaTime)
        
        // Continue animation loop
        animationFrameRef.current = requestAnimationFrame(animate)
      }
      
      animationFrameRef.current = requestAnimationFrame(animate)
    }

    initializeSimulation()

    // Cleanup function
    return () => {
      // Only cleanup if we actually initialized
      if (isInitializedRef.current) {
        logger.info('ðŸ§¹ Cleaning up simulation...')
        
        if (animationFrameRef.current) {
          cancelAnimationFrame(animationFrameRef.current)
        }
        
        // Dispose services and clean up systems
        try {
          // Clean up particle systems manually
          const systems = particleService.getSystems()
          const mainSystem = systems.get('main-organisms')
          if (mainSystem) {
            // Remove all particles from the system
            const particleIds = mainSystem.particles.map(p => p.id)
            if (particleIds.length > 0) {
              particleService.removeParticles('main-organisms', particleIds)
              logger.info(`ðŸ§¹ Removed ${particleIds.length} particles from system`)
            }
            // Remove the system from the map
            systems.delete('main-organisms')
            logger.debug('ðŸ§¹ Particle system cleaned up')
          }
          
          // Dispose services
          particleService.dispose()
          logger.info('ðŸ§¹ Services disposed successfully')
          
          // Reset initialization flag
          isInitializedRef.current = false
        } catch (err) {
          logger.error('âš ï¸ Error disposing services:', err)
          // Still reset the flag even if cleanup fails
          isInitializedRef.current = false
        }
      }
    }
  }, []) // Empty dependency array - only run once

  // Handle window resize
  useEffect(() => {
    function handleResize() {
      try {
        renderingService.camera.aspect = window.innerWidth / window.innerHeight
        renderingService.camera.updateProjectionMatrix()
        renderingService.renderer.setSize(window.innerWidth, window.innerHeight)
      } catch (err) {
        logger.warn('Error handling resize:', err)
      }
    }

    window.addEventListener('resize', handleResize)
    return () => window.removeEventListener('resize', handleResize)
  }, [])

  if (error) {
    return (
      <div style={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        height: '100%',
        color: '#ff4444',
        fontFamily: 'monospace',
        textAlign: 'center',
        padding: '20px'
      }}>
        <h3>ðŸŽ® Simulation Error</h3>
        <p>Failed to initialize Bitcoin Ordinals simulation</p>
        <pre style={{ 
          fontSize: '10px', 
          opacity: 0.7, 
          marginTop: '10px',
          background: 'rgba(255, 68, 68, 0.1)',
          padding: '10px',
          borderRadius: '4px',
          maxWidth: '80%',
          overflow: 'auto'
        }}>
          {error}
        </pre>
        <button 
          onClick={() => window.location.reload()} 
          style={{
            marginTop: '20px',
            padding: '10px 20px',
            background: '#ff4444',
            color: 'white',
            border: 'none',
            borderRadius: '4px',
            cursor: 'pointer',
            fontFamily: 'monospace'
          }}
        >
          ðŸ”„ Reload Simulation
        </button>
      </div>
    )
  }

  return (
    <div style={{ width: '100%', height: '100%', position: 'relative', background: '#000' }}>
      <div ref={mountRef} style={{ width: '100%', height: '100%' }} />
      
      {isLoading && (
        <div style={{
          position: 'absolute',
          top: '50%',
          left: '50%',
          transform: 'translate(-50%, -50%)',
          color: '#00ff88',
          fontFamily: 'monospace',
          textAlign: 'center',
          zIndex: 1000
        }}>
          <div style={{
            width: '40px',
            height: '40px',
            border: '3px solid rgba(0, 255, 136, 0.1)',
            borderTop: '3px solid #00ff88',
            borderRadius: '50%',
            animation: 'spin 1s linear infinite',
            margin: '0 auto 20px'
          }} />
          <div style={{ fontSize: '14px', marginBottom: '8px' }}>
            INITIALIZING BITCOIN ORDINALS
          </div>
          <div style={{ fontSize: '12px', opacity: 0.7 }}>
            Loading digital organism simulation...
          </div>
        </div>
      )}
      
      {!isLoading && (
        <>
          {/* Performance HUD */}
          <div style={{
            position: 'absolute',
            top: '20px',
            left: '20px',
            color: '#00ff88',
            fontFamily: 'monospace',
            fontSize: '12px',
            background: 'rgba(0, 0, 0, 0.7)',
            padding: '10px',
            borderRadius: '4px',
            zIndex: 1000
          }}>
            <div>ðŸ§¬ ORGANISMS: {particleCount}</div>
            <div>ðŸ“Š FPS: {fps}</div>
            <div>âš¡ GPU: ACTIVE</div>
          </div>
          
          {/* Bitcoin Ordinals Branding */}
          <div style={{
            position: 'absolute',
            bottom: '20px',
            left: '20px',
            color: '#00ff88',
            fontFamily: 'monospace',
            fontSize: '12px',
            opacity: 0.7,
            zIndex: 1000
          }}>
            ðŸŸ  BITCOIN ORDINALS â€¢ PROTOZOA v0.1.0
          </div>
          
          {/* Controls Info */}
          <div style={{
            position: 'absolute',
            bottom: '20px',
            right: '20px',
            color: '#ffffff',
            fontFamily: 'monospace',
            fontSize: '10px',
            opacity: 0.5,
            textAlign: 'right',
            zIndex: 1000
          }}>
            <div>ðŸ–±ï¸ Mouse: Rotate View</div>
            <div>ðŸ” Scroll: Zoom</div>
            <div>âŒ¨ï¸ WASD: Navigate</div>
          </div>
        </>
      )}
      
      <style>{`
        @keyframes spin {
          0% { transform: rotate(0deg); }
          100% { transform: rotate(360deg); }
        }
      `}</style>
    </div>
  )
}
