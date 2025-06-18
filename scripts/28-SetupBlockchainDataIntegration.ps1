# 28-SetupBlockchainDataIntegration.ps1 - Phase 3 Enhancement
# Sets up real-time blockchain data integration via WebSocket
# Reference: script_checklist.md | build_design.md lines 2250-2350
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
    Write-StepHeader "Blockchain Data Integration Setup - Phase 3 Enhancement"
    Write-InfoLog "Generating WebSocket client for Bitcoin block stream"

    $bitcoinDomainPath = Join-Path $ProjectRoot "src/domains/bitcoin"
    $servicesPath      = Join-Path $bitcoinDomainPath "services"

    # Ensure directory
    New-Item -Path $servicesPath -ItemType Directory -Force | Out-Null

    $wsContent = @'
/**
 * blockStreamService.ts â€“ Connects to a Bitcoin block stream via WebSocket.
 * Emits "block" events with parsed block info for downstream services.
 */

import { EventEmitter } from "events"
import { createServiceLogger } from "@/shared/lib/logger"
import type { BlockInfo } from "@/domains/bitcoin/types/blockInfo.types"

export class BlockStreamService extends EventEmitter {
  static #instance: BlockStreamService | null = null
  #log = createServiceLogger("BLOCK_STREAM")
  #socket?: WebSocket

  private constructor() { super() }

  public static getInstance(): BlockStreamService {
    if (!BlockStreamService.#instance) BlockStreamService.#instance = new BlockStreamService()
    return BlockStreamService.#instance
  }

  public connect(url = "wss://ordinals.com:443/block-stream"): void {
    if (this.#socket) return
    this.#log.info("Connecting to block stream", { url })
    this.#socket = new WebSocket(url)
    this.#socket.onopen = () => this.#log.info("Block stream connected")
    this.#socket.onmessage = (evt) => {
      try {
        const data: BlockInfo = JSON.parse(evt.data as string)
        this.emit("block", data)
      } catch (err) {
        this.#log.warn("Invalid message from block stream")
      }
    }
    this.#socket.onerror = (e) => this.#log.error("Block stream error", e)
    this.#socket.onclose = () => {
      this.#log.warn("Block stream closed; attempting reconnect in 10s")
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
'@

    Set-Content -Path (Join-Path $servicesPath "blockStreamService.ts") -Value $wsContent -Encoding UTF8
    Write-SuccessLog "blockStreamService.ts generated"

    Write-SuccessLog "28-SetupBlockchainDataIntegration.ps1 completed successfully"
    exit 0
}
catch {
    Write-ErrorLog "Blockchain Data Integration setup failed: $($_.Exception.Message)"
    exit 1
}
