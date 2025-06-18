# 36-GenerateEffectService.ps1 - Phase 5 Core Domain Implementation
# Generates EffectService for particle visual effects and preset management
# Reference: script_checklist.md | build_design.md lines 300-500 (Effect domain)
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
    Write-StepHeader "Effect Service Generation - Phase 5 Core Domain Implementation"
    Write-InfoLog "Generating EffectService and interfaces"

    # Define paths
    $effectDomainPath = Join-Path $ProjectRoot "src/domains/effect"
    $servicesPath     = Join-Path $effectDomainPath "services"
    $interfacesPath   = Join-Path $effectDomainPath "interfaces"
    $dataPath         = Join-Path $effectDomainPath "data"

    # Ensure directories exist
    New-Item -Path $servicesPath   -ItemType Directory -Force | Out-Null
    New-Item -Path $interfacesPath -ItemType Directory -Force | Out-Null
    New-Item -Path $dataPath       -ItemType Directory -Force | Out-Null

    Write-SuccessLog "Effect domain directories ensured"

    # Interface definition
    $interfaceContent = @"

/**
 * @fileoverview IEffectService Interface Definition
 * @description Contract for managing visual particle effects.
 */

export interface EffectConfig {
  /** Duration of the effect in milliseconds */
  duration: number
  /** Intensity factor (0.0 – 1.0) */
  intensity: number
  /** Arbitrary extra parameters */
  [key: string]: unknown
}

export interface IEffectService {
  /** Register a reusable effect preset */
  registerEffectPreset(name: string, config: EffectConfig): void
  /** Trigger an effect */
  triggerEffect(name: string, options?: unknown): void
  /** Cleanup and release resources */
  dispose(): void
}
"@

    Set-Content -Path (Join-Path $interfacesPath "IEffectService.ts") -Value $interfaceContent -Encoding UTF8
    Write-SuccessLog "IEffectService interface created"

    # Implementation
    $serviceContent = @"

/**
 * @fileoverview EffectService Implementation
 * @description Singleton service managing particle visual effects and presets.
 */

import { createServiceLogger, createErrorLogger } from '@/shared/lib/logger'
import type { IEffectService, EffectConfig } from '@/domains/effect/interfaces/IEffectService'

class EffectService implements IEffectService {
  /** Singleton instance */
  static #instance: EffectService | null = null

  /** Preset registry */
  #presets: Map<string, EffectConfig> = new Map()

  /** Loggers */
  #log = createServiceLogger('EFFECT_SERVICE')
  #err = createErrorLogger('EFFECT_SERVICE')

  private constructor() {
    this.#log.info('EffectService singleton created')
    // Default presets
    this.registerEffectPreset('nebula', { duration: 5000, intensity: 0.8 })
    this.registerEffectPreset('explosion', { duration: 1000, intensity: 1.0 })
  }

  /** Get singleton instance */
  public static getInstance(): EffectService {
    if (!EffectService.#instance) EffectService.#instance = new EffectService()
    return EffectService.#instance
  }

  public registerEffectPreset(name: string, config: EffectConfig): void {
    this.#presets.set(name, config)
    this.#log.debug('Preset registered', { name, config })
  }

  public triggerEffect(name: string, options: unknown = {}): void {
    const preset = this.#presets.get(name)
    if (!preset) {
      this.#err.logError(new Error('Preset not found'), { name })
      return
    }
    const merged = { ...preset, ...(options as object) }
    this.#log.info('Effect triggered', { name, merged })
    // Placeholder: actual Three.js particle / shader spawning occurs here.
  }

  public dispose(): void {
    this.#presets.clear()
    this.#log.info('EffectService disposed')
    EffectService.#instance = null
  }
}

export const effectService = EffectService.getInstance()
"@

    Set-Content -Path (Join-Path $servicesPath "effectService.ts") -Value $serviceContent -Encoding UTF8
    Write-SuccessLog "EffectService implementation created"

    Write-SuccessLog "36-GenerateEffectService.ps1 completed successfully"
    exit 0
}
catch {
    Write-ErrorLog "Effect Service Generation failed: $($_.Exception.Message)"
    exit 1
}
