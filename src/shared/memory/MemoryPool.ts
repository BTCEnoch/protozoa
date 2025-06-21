/**
 * Auto-generated MemoryPool â€“ provides typed buffer pooling with ref counting.
 * Implements efficient memory management for particle systems and WebGL resources.
 * 
 * @author Protozoa Automation Suite
 * @generated 04b-SmartMemoryAndWorkers.ps1
 */

import { logger } from '../lib/logger'

/**  
 * Memory usage statistics interface
 */
export interface MemoryStats {
  totalBuffers: number
  totalSize: number
  poolUtilization: number
  typeBreakdown: Record<string, number>
}

/**
 * Memory pool configuration options
 */
export interface MemoryPoolConfig {
  maxPerType?: number
  enableLogging?: boolean
  enableGC?: boolean
}

/**
 * Adaptive memory pool for efficient buffer management
 * Provides type-safe buffer allocation and deallocation with automatic cleanup
 */
export class MemoryPool {
  private buffers: Map<string, ArrayBuffer[]> = new Map()
  private readonly maxPerType: number
  private readonly enableLogging: boolean
  private readonly enableGC: boolean
  private allocCount = 0
  private releaseCount = 0

  constructor(config: MemoryPoolConfig = {}) {
    this.maxPerType = config.maxPerType ?? 256
    this.enableLogging = config.enableLogging ?? false
    this.enableGC = config.enableGC ?? true
    
    if (this.enableLogging) {
      logger.info('MemoryPool initialized', { 
        maxPerType: this.maxPerType,
        enableGC: this.enableGC 
      })
    }
  }

  /**
   * Allocate a buffer of specified type and size
   * @param type Buffer type identifier
   * @param size Buffer size in bytes
   * @returns ArrayBuffer instance
   */
  allocate(type: string, size: number): ArrayBuffer {
    const pool = this.buffers.get(type) ?? []
    let buffer: ArrayBuffer
    
    if (pool.length > 0) {
      buffer = pool.pop()!
      if (this.enableLogging) {
        logger.debug('Buffer reused from pool', { type, size, poolSize: pool.length })
      }
    } else {
      buffer = new ArrayBuffer(size)
      if (this.enableLogging) {
        logger.debug('New buffer allocated', { type, size })
      }
    }
    
    this.allocCount++
    return buffer
  }

  /**
   * Release a buffer back to the pool
   * @param type Buffer type identifier
   * @param buffer Buffer to release
   */
  release(type: string, buffer: ArrayBuffer): void {
    if (!buffer) {
      logger.warn('Attempted to release null/undefined buffer', { type })
      return
    }

    const pool = this.buffers.get(type) ?? []
    
    if (pool.length < this.maxPerType) {
      pool.push(buffer)
      this.buffers.set(type, pool)
      
      if (this.enableLogging) {
        logger.debug('Buffer returned to pool', { type, poolSize: pool.length })
      }
    } else {
      if (this.enableLogging) {
        logger.debug('Buffer discarded - pool full', { type, maxPerType: this.maxPerType })
      }
    }
    
    this.releaseCount++
  }

  /**
   * Get detailed memory usage statistics
   * @returns MemoryStats object with usage information
   */
  getStats(): MemoryStats {
    let totalSize = 0
    let totalBuffers = 0
    const typeBreakdown: Record<string, number> = {}

    this.buffers.forEach((bufferArray, type) => {
      const typeSize = bufferArray.reduce((sum, buffer) => sum + buffer.byteLength, 0)
      totalSize += typeSize
      totalBuffers += bufferArray.length
      typeBreakdown[type] = bufferArray.length
    })

    const maxPossibleBuffers = this.maxPerType * this.buffers.size
    const poolUtilization = maxPossibleBuffers > 0 ? totalBuffers / maxPossibleBuffers : 0

    return {
      totalBuffers,
      totalSize,
      poolUtilization,
      typeBreakdown
    }
  }

  /**
   * Force garbage collection of unused buffers
   */
  collectGarbage(): void {
    if (!this.enableGC) return
    
    const beforeSize = this.buffers.size
    let freedBuffers = 0
    
    this.buffers.forEach((bufferArray, type) => {
      if (bufferArray.length === 0) {
        this.buffers.delete(type)
      } else {
        // Keep only recent buffers, discard older ones
        const keepCount = Math.min(bufferArray.length, Math.ceil(this.maxPerType * 0.7))
        if (bufferArray.length > keepCount) {
          freedBuffers += bufferArray.length - keepCount
          bufferArray.splice(keepCount)
        }
      }
    })
    
    if (this.enableLogging && (beforeSize !== this.buffers.size || freedBuffers > 0)) {
      logger.info('MemoryPool garbage collection completed', {
        typesRemoved: beforeSize - this.buffers.size,
        buffersFreed: freedBuffers
      })
    }
  }

  /**
   * Dispose of all resources and clear the pool
   */
  dispose(): void {
    const stats = this.getStats()
    this.buffers.clear()
    this.allocCount = 0
    this.releaseCount = 0
    
    if (this.enableLogging) {
      logger.info('MemoryPool disposed', { finalStats: stats })
    }
  }
}

// Singleton instance for global use
let globalMemoryPool: MemoryPool | null = null

/**
 * Get the global MemoryPool instance
 * @param config Optional configuration (only used for first initialization)
 * @returns Global MemoryPool instance
 */
export function getMemoryPool(config?: MemoryPoolConfig): MemoryPool {
  if (!globalMemoryPool) {
    globalMemoryPool = new MemoryPool(config)
  }
  return globalMemoryPool
}
