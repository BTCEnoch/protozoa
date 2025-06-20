# 25-SetupPhysicsWebWorkers.ps1 - Phase 2 Enhancement
# Sets up WebWorker infrastructure for offloading physics calculations
# Reference: script_checklist.md | build_design.md lines 2100-2150 (WebWorker setup)
#Requires -Version 5.1

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $false)]
    [string]$ProjectRoot = (Split-Path $PSScriptRoot -Parent)
)

try {
    Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop
}
catch {
    Write-Error "Failed to import utilities module: $($_.Exception.Message)"
    exit 1
}

$ErrorActionPreference = "Stop"

try {
    Write-StepHeader "Physics WebWorkers Setup - Phase 2 Enhancement"
    Write-InfoLog "Scaffolding worker pool and base worker for physics domain"

    # Define paths
    $physicsDomainPath = Join-Path $ProjectRoot "src/domains/physics"
    $workersPath       = Join-Path $physicsDomainPath "workers"
    $servicesPath      = Join-Path $physicsDomainPath "services"

    New-Item -Path $workersPath -ItemType Directory -Force | Out-Null

    # Worker TypeScript file
    $workerContent = @'
/* eslint-disable no-restricted-globals */
/**
 * physicsWorker.ts â€“ WebWorker entry for physics calculations
 * The worker listens for messages with { id, task, payload } structure and
 * posts results back using { id, result }.
 * Utilizes minimal imports to keep bundle light.
 */

import { Vector3 } from "three"

/** Simple message contracts */
interface WorkerRequest<T = unknown> { id: number; task: string; payload: T }
interface WorkerResponse<T = unknown> { id: number; result: T }

/** Helper to compute gravity on a vector (example task) */
function applyGravity(pos: Vector3, delta: number): Vector3 {
  const g = -9.81
  return new Vector3(pos.x, pos.y + g * (delta / 1000), pos.z)
}

self.onmessage = (e: MessageEvent<WorkerRequest>) => {
  const { id, task, payload } = e.data
  let result: unknown
  switch (task) {
    case "gravity":
      // payload expected { position: Vector3Plain, delta: number }
      result = applyGravity(new Vector3(payload.position.x, payload.position.y, payload.position.z), payload.delta)
      break
    default:
      result = null
  }
  const response: WorkerResponse = { id, result }
  ;(self as DedicatedWorkerGlobalScope).postMessage(response)
}
'@

    Set-Content -Path (Join-Path $workersPath "physicsWorker.ts") -Value $workerContent -Encoding UTF8
    Write-SuccessLog "physicsWorker.ts generated"

    # Worker manager service (workerPool)
    $managerContent = @'
/**
 * workerManager.ts â€“ Manages a pool of physics WebWorkers
 */

import { createServiceLogger } from "@/shared/lib/logger"

interface TaskRequest { task: string; payload: unknown; resolve: (v: any)=>void; reject: (e: any)=>void }

export class WorkerManager {
  static #instance: WorkerManager | null = null
  #log = createServiceLogger("PHYSICS_WORKER_MANAGER")
  #workers: Worker[] = []
  #availability: boolean[] = []
  #queue: TaskRequest[] = []
  #taskId = 0

  private constructor(workerCount = navigator.hardwareConcurrency || 4) {
    for (let i = 0; i < workerCount; i++) {
      const w = new Worker(new URL("../workers/physicsWorker.ts", import.meta.url), { type: "module" })
      w.onmessage = (e) => this.#handleResponse(e.data)
      this.#workers.push(w)
      this.#availability.push(true)
    }
    this.#log.info("Physics worker pool created", { workerCount })
  }

  public static getInstance(): WorkerManager {
    if (!WorkerManager.#instance) WorkerManager.#instance = new WorkerManager()
    return WorkerManager.#instance
  }

  public enqueue(task: string, payload: unknown): Promise<unknown> {
    return new Promise((resolve, reject) => {
      const req: TaskRequest = { task, payload, resolve, reject }
      this.#queue.push(req)
      this.#dispatch()
    })
  }

  #dispatch() {
    const freeIndex = this.#availability.findIndex(a => a)
    if (freeIndex === -1 || this.#queue.length === 0) {
      this.#log.debug("No available workers or empty queue", { 
        freeIndex, 
        queueLength: this.#queue.length 
      })
      return
    }
    
    const req = this.#queue.shift()
    if (!req) {
      this.#log.warn("Queue shift returned undefined")
      return
    }
    
    const id = ++this.#taskId
    
    try {
      this.#availability[freeIndex] = false
      this.#workers[freeIndex].postMessage({ id, task: req.task, payload: req.payload })
      ;(this.#workers[freeIndex] as any).__currentId = id
      ;(this.#workers[freeIndex] as any).__cb = req
      
      this.#log.debug("Task dispatched to worker", { 
        workerId: freeIndex, 
        taskId: id, 
        task: req.task 
      })
    } catch (error) {
      this.#log.error("Failed to dispatch task to worker", { 
        workerId: freeIndex, 
        error: error.message 
      })
      this.#availability[freeIndex] = true
      req.reject(error)
    }
  }

  #handleResponse(data: { id: number; result: unknown }) {
    const wIndex = this.#workers.findIndex(w => (w as any).__currentId === data.id)
    if (wIndex === -1) return
    const cb: TaskRequest = (this.#workers[wIndex] as any).__cb
    cb.resolve(data.result)
    this.#availability[wIndex] = true
    this.#dispatch()
  }

  public terminateAll() {
    this.#workers.forEach(w => w.terminate())
    this.#workers = []
    this.#availability = []
    this.#queue = []
    this.#log.info("All physics workers terminated")
  }
}
'@

    Set-Content -Path (Join-Path $servicesPath "workerManager.ts") -Value $managerContent -Encoding UTF8
    Write-SuccessLog "workerManager.ts generated"

    Write-SuccessLog "25-SetupPhysicsWebWorkers.ps1 completed successfully"
    exit 0
}
catch {
    Write-ErrorLog "Physics WebWorkers setup failed: $($_.Exception.Message)"
    exit 1
}
