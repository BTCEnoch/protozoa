/* eslint-disable no-restricted-globals */
/**
 * physicsWorker.ts – WebWorker entry for physics calculations
 * The worker listens for messages with { id, task, payload } structure and
 * posts results back using { id, result }.
 * Utilizes minimal imports to keep bundle light.
 */

import { Vector3 } from 'three';

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
    case 'gravity':
      // payload expected { position: Vector3Plain, delta: number }
      result = applyGravity(new Vector3(payload.position.x, payload.position.y, payload.position.z), payload.delta)
      break
    default:
      result = null
  }
  const response: WorkerResponse = { id, result }
  ;(self as DedicatedWorkerGlobalScope).postMessage(response)
}
