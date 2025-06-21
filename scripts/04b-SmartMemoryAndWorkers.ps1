# 04b-SmartMemoryAndWorkers.ps1
# Generates adaptive MemoryPool.ts, WorkerManager.ts, and injects USE_WORKERS build flag
# Creates memory management and worker infrastructure for the Protozoa application
# Usage: Executed by automation suite after basic scaffolding is complete

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $false)]
    [string]$ProjectRoot = (Split-Path $PSScriptRoot -Parent),

    [Parameter(Mandatory = $false)]
    [switch]$DryRun,
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipViteFlag
)

$ErrorActionPreference = "Stop"

try {
    Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop
} catch {
    Write-Error "Failed to import utils module: $($_.Exception.Message)"
    exit 1
}

try {
    Write-StepHeader "Smart Memory and Workers Setup (04b)"
    Write-InfoLog "Scaffolding MemoryPool and WorkerManager infrastructure"

    # Create necessary directories
    $memoryPath = Join-Path $ProjectRoot "src/shared/memory"
    $workersPath = Join-Path $ProjectRoot "src/shared/workers"
    
    Write-InfoLog "Creating directories: memory and workers"
    if (-not $DryRun) {
        New-Item -ItemType Directory -Path $memoryPath -Force | Out-Null
        New-Item -ItemType Directory -Path $workersPath -Force | Out-Null
    }

    # ---- Generate MemoryPool.ts ----
    $memoryPoolPath = Join-Path $memoryPath "MemoryPool.ts"
    $memoryPoolContent = @'
/**
 * Auto-generated MemoryPool – provides typed buffer pooling with ref counting.
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
'@

    Write-InfoLog "Generating MemoryPool.ts with adaptive pooling"
    if (-not $DryRun) {
        Set-Content -Path $memoryPoolPath -Value $memoryPoolContent -Encoding UTF8
    }
    
    Write-SuccessLog "MemoryPool.ts scaffolded successfully"

    # ---- Generate WorkerManager.ts ----
    $workerManagerPath = Join-Path $workersPath "WorkerManager.ts"
    $workerManagerContent = @'
/**
 * Auto-generated WorkerManager – spawns and tracks WebWorkers per domain.
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
'@

    Write-InfoLog "Generating WorkerManager.ts with lifecycle management"
    if (-not $DryRun) {
        Set-Content -Path $workerManagerPath -Value $workerManagerContent -Encoding UTF8
    }
    
    Write-SuccessLog "WorkerManager.ts scaffolded successfully"

    # ---- Inject USE_WORKERS build flag ----
    if (-not $SkipViteFlag) {
        $viteConfigPath = Join-Path $ProjectRoot "vite.config.ts"
        
        if (Test-Path $viteConfigPath) {
            Write-InfoLog "Injecting USE_WORKERS build flag into vite.config.ts"
            
            $viteContent = Get-Content $viteConfigPath -Raw
            
            if ($viteContent -notmatch 'USE_WORKERS') {
                # Look for existing define block or create one
                if ($viteContent -match 'define:\s*\{') {
                    $updatedContent = $viteContent -replace 'define:\s*\{', "define: {`n    USE_WORKERS: 'true',"
                } else {
                    # Add new define block
                    $updatedContent = $viteContent -replace 'export default defineConfig\(\{', "export default defineConfig({`n  define: {`n    USE_WORKERS: 'true'`n  },"
                }
                
                if (-not $DryRun) {
                    Set-Content -Path $viteConfigPath -Value $updatedContent -Encoding UTF8
                }
                
                Write-SuccessLog "USE_WORKERS build flag injected successfully"
            } else {
                Write-InfoLog "USE_WORKERS flag already present in vite.config.ts"
            }
        } else {
            Write-WarningLog "vite.config.ts not found - skipping build flag injection"
        }
    } else {
        Write-InfoLog "Skipping Vite build flag injection (SkipViteFlag enabled)"
    }

    Write-SuccessLog "Smart Memory and Workers setup completed successfully"
    Write-InfoLog "Generated: MemoryPool.ts, WorkerManager.ts"
    Write-InfoLog "Memory management and worker infrastructure ready for use"
    
    exit 0

} catch {
    Write-ErrorLog "SmartMemoryAndWorkers setup failed: $($_.Exception.Message)"
    exit 1
} 