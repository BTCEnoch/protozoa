/**
 * React Three Fiber custom hooks
 * Provides reusable R3F functionality and integrations
 * 
 * @author Protozoa Automation Suite
 * @generated from template
 */

import { useRef, useCallback } from 'react'
import { useFrame, useThree } from '@react-three/fiber'
import * as THREE from 'three'
import { useSimulationStore } from '@/shared/state'
import { logger } from '@/shared/lib/logger'

/**
 * Hook for managing R3F simulation state
 */
export function useSimulation() {
  const { 
    isRunning, 
    isPaused, 
    speed, 
    timeScale,
    startSimulation,
    pauseSimulation,
    stopSimulation,
    setSpeed,
    setTimeScale
  } = useSimulationStore()

  const controls = {
    start: startSimulation,
    pause: pauseSimulation,
    stop: stopSimulation,
    setSpeed,
    setTimeScale
  }

  return {
    isRunning,
    isPaused,
    speed,
    timeScale,
    controls
  }
}

/**
 * Hook for R3F performance monitoring
 */
export function usePerformanceMonitor() {
  const { gl } = useThree()
  const frameCountRef = useRef(0)
  const lastTimeRef = useRef(0)
  const { updateFrameRate, updateRenderTime } = useSimulationStore()

  useFrame((state, delta) => {
    frameCountRef.current++
    
    const currentTime = performance.now()
    
    // Update FPS every second
    if (currentTime - lastTimeRef.current >= 1000) {
      const fps = (frameCountRef.current * 1000) / (currentTime - lastTimeRef.current)
      updateFrameRate(fps)
      
      frameCountRef.current = 0
      lastTimeRef.current = currentTime
    }
    
    // Monitor render time
    const renderTime = gl.info.render.calls
    updateRenderTime(renderTime)
  })

  return { frameCountRef, lastTimeRef }
}

/**
 * Hook for R3F camera controls
 */
export function useCameraControls() {
  const { camera } = useThree()
  
  const moveTo = useCallback((position: [number, number, number], target?: [number, number, number]) => {
    camera.position.set(...position)
    if (target) {
      camera.lookAt(...target)
    }
  }, [camera])

  const reset = useCallback(() => {
    camera.position.set(0, 5, 10)
    camera.lookAt(0, 0, 0)
  }, [camera])

  return { moveTo, reset, camera }
}

/**
 * Hook for R3F scene utilities
 */
export function useSceneUtils() {
  const { scene, gl } = useThree()
  
  const addObject = useCallback((object: THREE.Object3D) => {
    scene.add(object)
    logger.debug('Object added to R3F scene', { type: object.type })
  }, [scene])

  const removeObject = useCallback((object: THREE.Object3D) => {
    scene.remove(object)
    logger.debug('Object removed from R3F scene', { type: object.type })
  }, [scene])

  const clearScene = useCallback(() => {
    while (scene.children.length > 0) {
      scene.remove(scene.children[0])
    }
    logger.info('R3F scene cleared')
  }, [scene])

  const takeScreenshot = useCallback(() => {
    const dataURL = gl.domElement.toDataURL('image/png')
    logger.debug('Screenshot taken from R3F scene')
    return dataURL
  }, [gl])

  return { addObject, removeObject, clearScene, takeScreenshot, scene }
} 