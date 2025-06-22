/**
 * Performance monitoring utilities for Protozoa application
 * Provides metrics collection and performance tracking
 * 
 * @author Protozoa Automation Suite
 * @generated 29-SetupOpenTelemetry.ps1
 */

import { getTracer, withSpan } from './tracing'
import { logger } from '../lib/logger'

/**
 * Performance metrics interface
 */
export interface PerformanceMetrics {
  timestamp: number
  frameRate: number
  memoryUsage: number
  particleCount: number
  renderTime: number
  physicsTime: number
}

/**
 * Performance monitor class
 */
export class PerformanceMonitor {
  private metrics: PerformanceMetrics[] = []
  private readonly maxMetrics = 1000
  private lastFrameTime = 0
  private frameCount = 0

  /**
   * Record frame performance metrics
   */
  recordFrame(particleCount: number, renderTime: number, physicsTime: number): void {
    const now = performance.now()
    const deltaTime = now - this.lastFrameTime
    const frameRate = deltaTime > 0 ? 1000 / deltaTime : 0
    
    const metrics: PerformanceMetrics = {
      timestamp: now,
      frameRate,
      memoryUsage: this.getMemoryUsage(),
      particleCount,
      renderTime,
      physicsTime
    }

    this.metrics.push(metrics)
    
    // Keep only recent metrics
    if (this.metrics.length > this.maxMetrics) {
      this.metrics.shift()
    }

    this.lastFrameTime = now
    this.frameCount++

    // Log performance warnings
    if (frameRate < 30) {
      logger.warn('Low frame rate detected', { frameRate, particleCount })
    }
    
    if (renderTime > 16.67) { // > 60fps budget
      logger.warn('High render time detected', { renderTime, particleCount })
    }
  }

  /**
   * Get memory usage in MB
   */
  private getMemoryUsage(): number {
    if (typeof performance !== 'undefined' && (performance as any).memory) {
      return (performance as any).memory.usedJSHeapSize / 1024 / 1024
    }
    return 0
  }

  /**
   * Get performance statistics
   */
  getStats(): { avgFrameRate: number; avgMemory: number; maxParticles: number } {
    if (this.metrics.length === 0) {
      return { avgFrameRate: 0, avgMemory: 0, maxParticles: 0 }
    }

    const avgFrameRate = this.metrics.reduce((sum, m) => sum + m.frameRate, 0) / this.metrics.length
    const avgMemory = this.metrics.reduce((sum, m) => sum + m.memoryUsage, 0) / this.metrics.length
    const maxParticles = Math.max(...this.metrics.map(m => m.particleCount))

    return { avgFrameRate, avgMemory, maxParticles }
  }

  /**
   * Create a traced performance measurement
   */
  measurePerformance<T>(name: string, fn: () => T): T {
    return withSpan(`performance.${name}`, fn, {
      'protozoa.measurement.type': 'performance',
      'protozoa.measurement.name': name
    })
  }
}

// Global performance monitor instance
export const performanceMonitor = new PerformanceMonitor()
