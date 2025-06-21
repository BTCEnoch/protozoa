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
