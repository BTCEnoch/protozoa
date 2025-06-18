/**
 * blockStreamService.ts – Connects to a Bitcoin block stream via WebSocket.
 * Emits 'block' events with parsed block info for downstream services.
 */

import type { BlockInfo } from '@/domains/bitcoin/types/blockInfo.types'
import { createServiceLogger } from '@/shared/lib/logger'
import { EventEmitter } from 'events'

export class BlockStreamService extends EventEmitter {
  static #instance: BlockStreamService | null = null
  #log = createServiceLogger('BLOCK_STREAM')
  #socket?: WebSocket

  private constructor() { super() }

  public static getInstance(): BlockStreamService {
    if (!BlockStreamService.#instance) BlockStreamService.#instance = new BlockStreamService()
    return BlockStreamService.#instance
  }

  public connect(url = 'wss://ordinals.com:443/block-stream'): void {
    if (this.#socket) return
    this.#log.info('Connecting to block stream', { url })
    this.#socket = new WebSocket(url)
    this.#socket.onopen = () => this.#log.info('Block stream connected')
    this.#socket.onmessage = (evt) => {
      try {
        const data: BlockInfo = JSON.parse(evt.data as string)
        this.emit('block', data)
      } catch (err) {
        this.#log.warn('Invalid message from block stream')
      }
    }
    this.#socket.onerror = (e) => this.#log.error('Block stream error', e)
    this.#socket.onclose = () => {
      this.#log.warn('Block stream closed; attempting reconnect in 10s')
      this.#socket = undefined
      setTimeout(() => this.connect(url), 10000)
    }
  }

  public dispose(): void {
    this.#socket?.close()
    this.removeAllListeners()
    BlockStreamService.#instance = null
  }
}

export const blockStreamService = BlockStreamService.getInstance()
