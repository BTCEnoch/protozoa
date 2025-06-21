/**
 * Auto-generated WorkerManager â€“ spawns and tracks WebWorkers per domain.
 * Provides centralized worker lifecycle management with proper disposal.
 * 
 * @author Protozoa Automation Suite
 * @generated 04b-SmartMemoryAndWorkers.ps1
 */

import { logger } from '../lib/logger'

/**
 * Worker status enumeration
 */
export enum WorkerStatus {
  INITIALIZING = 'initializing',
  READY = 'ready',
  BUSY = 'busy',
  ERROR = 'error',
  TERMINATED = 'terminated'
}

/**
 * Worker metadata interface
 */
export interface WorkerMetadata {
  id: string
  scriptURL: string
  status: WorkerStatus
  startTime: number
  lastActivity: number
  taskCount: number
}

/**
 * Worker manager configuration
 */
export interface WorkerManagerConfig {
  maxWorkers?: number
  enableLogging?: boolean
  heartbeatInterval?: number
  idleTimeout?: number
}

/**
 * Centralized WebWorker management system
 * Handles worker lifecycle, monitoring, and cleanup
 */
export class WorkerManager<T extends Worker = Worker> {
  private workers: Map<string, T> = new Map()
  private metadata: Map<string, WorkerMetadata> = new Map()
  private readonly maxWorkers: number
  private readonly enableLogging: boolean
  private readonly heartbeatInterval: number
  private readonly idleTimeout: number
  private heartbeatTimer: number | null = null

  constructor(config: WorkerManagerConfig = {}) {
    this.maxWorkers = config.maxWorkers ?? 8
    this.enableLogging = config.enableLogging ?? false
    this.heartbeatInterval = config.heartbeatInterval ?? 30000 // 30 seconds
    this.idleTimeout = config.idleTimeout ?? 300000 // 5 minutes
    
    if (this.enableLogging) {
      logger.info('WorkerManager initialized', {
        maxWorkers: this.maxWorkers,
        heartbeatInterval: this.heartbeatInterval,
        idleTimeout: this.idleTimeout
      })
    }
    
    this.startHeartbeat()
  }

  /**
   * Spawn a new worker or return existing one
   * @param id Unique worker identifier
   * @param scriptURL Worker script URL
   * @returns Worker instance
   */
  spawn(id: string, scriptURL: string): T {
    // Return existing worker if available
    if (this.workers.has(id)) {
      const existingWorker = this.workers.get(id)!
      const metadata = this.metadata.get(id)!
      metadata.lastActivity = Date.now()
      
      if (this.enableLogging) {
        logger.debug('Reusing existing worker', { id, scriptURL })
      }
      
      return existingWorker
    }

    // Check worker limit
    if (this.workers.size >= this.maxWorkers) {
      throw new Error(`Maximum worker limit reached (${this.maxWorkers}). Terminate unused workers first.`)
    }

    try {
      const worker = new Worker(scriptURL, { type: 'module' }) as T
      const now = Date.now()
      
      // Set up worker metadata
      const metadata: WorkerMetadata = {
        id,
        scriptURL,
        status: WorkerStatus.INITIALIZING,
        startTime: now,
        lastActivity: now,
        taskCount: 0
      }

      // Set up worker event handlers
      worker.onmessage = (event) => {
        const meta = this.metadata.get(id)
        if (meta) {
          meta.lastActivity = Date.now()
          meta.taskCount++
          meta.status = WorkerStatus.READY
        }
        
        if (this.enableLogging) {
          logger.debug('Worker message received', { id, data: event.data })
        }
      }

      worker.onerror = (error) => {
        const meta = this.metadata.get(id)
        if (meta) {
          meta.status = WorkerStatus.ERROR
          meta.lastActivity = Date.now()
        }
        
        logger.error('Worker error', { id, error: error.message })
      }

      worker.onmessageerror = (error) => {
        logger.error('Worker message error', { id, error })
      }

      this.workers.set(id, worker)
      this.metadata.set(id, metadata)

      if (this.enableLogging) {
        logger.info('Worker spawned successfully', { id, scriptURL })
      }

      return worker
    } catch (error) {
      logger.error('Failed to spawn worker', { id, scriptURL, error })
      throw error
    }
  }

  /**
   * Terminate a specific worker
   * @param id Worker identifier
   */
  terminate(id: string): void {
    const worker = this.workers.get(id)
    if (!worker) {
      if (this.enableLogging) {
        logger.warn('Attempted to terminate non-existent worker', { id })
      }
      return
    }

    try {
      worker.terminate()
      this.workers.delete(id)
      this.metadata.delete(id)
      
      if (this.enableLogging) {
        logger.info('Worker terminated successfully', { id })
      }
    } catch (error) {
      logger.error('Error terminating worker', { id, error })
    }
  }

  /**
   * Get worker metadata
   * @param id Worker identifier
   * @returns Worker metadata or undefined
   */
  getWorkerMetadata(id: string): WorkerMetadata | undefined {
    return this.metadata.get(id)
  }

  /**
   * Get all worker metadata
   * @returns Array of all worker metadata
   */
  getAllWorkerMetadata(): WorkerMetadata[] {
    return Array.from(this.metadata.values())
  }

  /**
   * Get worker by ID
   * @param id Worker identifier
   * @returns Worker instance or undefined
   */
  getWorker(id: string): T | undefined {
    return this.workers.get(id)
  }

  /**
   * Check if worker exists
   * @param id Worker identifier
   * @returns True if worker exists
   */
  hasWorker(id: string): boolean {
    return this.workers.has(id)
  }

  /**
   * Get current worker count
   * @returns Number of active workers
   */
  getWorkerCount(): number {
    return this.workers.size
  }

  /**
   * Start heartbeat monitoring
   */
  private startHeartbeat(): void {
    if (this.heartbeatTimer) return

    this.heartbeatTimer = window.setInterval(() => {
      this.checkIdleWorkers()
    }, this.heartbeatInterval)
  }

  /**
   * Check for idle workers and terminate them
   */
  private checkIdleWorkers(): void {
    const now = Date.now()
    const idleWorkers: string[] = []

    this.metadata.forEach((metadata, id) => {
      if (now - metadata.lastActivity > this.idleTimeout) {
        idleWorkers.push(id)
      }
    })

    idleWorkers.forEach(id => {
      if (this.enableLogging) {
        logger.info('Terminating idle worker', { id })
      }
      this.terminate(id)
    })
  }

  /**
   * Dispose of all workers and cleanup resources
   */
  dispose(): void {
    if (this.heartbeatTimer) {
      clearInterval(this.heartbeatTimer)
      this.heartbeatTimer = null
    }

    const workerIds = Array.from(this.workers.keys())
    workerIds.forEach(id => this.terminate(id))

    this.workers.clear()
    this.metadata.clear()

    if (this.enableLogging) {
      logger.info('WorkerManager disposed', { terminatedWorkers: workerIds.length })
    }
  }
}

// Singleton instance for global use
let globalWorkerManager: WorkerManager | null = null

/**
 * Get the global WorkerManager instance
 * @param config Optional configuration (only used for first initialization)
 * @returns Global WorkerManager instance
 */
export function getWorkerManager(config?: WorkerManagerConfig): WorkerManager {
  if (!globalWorkerManager) {
    globalWorkerManager = new WorkerManager(config)
  }
  return globalWorkerManager
}
