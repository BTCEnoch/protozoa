# 40-GenerateAnimationService.ps1 - Phase 6 Core Domain Implementation
# Generates AnimationService and interface for managing particle animations
# Reference: script_checklist.md | build_design.md lines 200-350 (Animation domain)
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
    Write-StepHeader "Animation Service Generation - Phase 6 Core Domain Implementation"
    Write-InfoLog "Generating AnimationService and interfaces"

    # Paths
    $animationDomainPath = Join-Path $ProjectRoot "src/domains/animation"
    $servicesPath        = Join-Path $animationDomainPath "services"
    $interfacesPath      = Join-Path $animationDomainPath "interfaces"

    New-Item -Path $servicesPath   -ItemType Directory -Force | Out-Null
    New-Item -Path $interfacesPath -ItemType Directory -Force | Out-Null

    Write-SuccessLog "Animation domain directories ensured"

    # Interface
    $interfaceContent = @"
/**
 * @fileoverview IAnimationService Interface Definition
 * @description Contract for controlling particle/organism animations.
 */

export interface AnimationConfig {
  duration: number
  easing?: 'linear' | 'ease-in' | 'ease-out' | 'ease-in-out'
  type: 'move' | 'scale' | 'rotation' | 'custom'
  [key: string]: unknown
}

export interface AnimationState {
  role: string
  progress: number
  duration: number
  type: string
}

export interface IAnimationService {
  startAnimation(role: string, config: AnimationConfig): void
  updateAnimations(delta: number): void
  stopAll(): void
  dispose(): void
}
"@

    Set-Content -Path (Join-Path $interfacesPath "IAnimationService.ts") -Value $interfaceContent -Encoding UTF8
    Write-SuccessLog "IAnimationService interface created"

    # Implementation
    $serviceContent = @"
/**
 * @fileoverview AnimationService Implementation
 * @description Singleton managing time-based animations across particle roles.
 */

import { createServiceLogger, createPerformanceLogger } from '@/shared/lib/logger'
import type { IAnimationService, AnimationConfig, AnimationState } from '@/domains/animation/interfaces/IAnimationService'

class AnimationService implements IAnimationService {
  static #instance: AnimationService | null = null

  #animations: Map<string, AnimationState> = new Map()
  #log  = createServiceLogger('ANIMATION_SERVICE')
  #perf = createPerformanceLogger('ANIMATION_SERVICE')

  private constructor() {
    this.#log.info('AnimationService singleton created')
  }

  public static getInstance(): AnimationService {
    if (!AnimationService.#instance) AnimationService.#instance = new AnimationService()
    return AnimationService.#instance
  }

  public startAnimation(role: string, config: AnimationConfig): void {
    const state: AnimationState = { role, progress: 0, duration: config.duration, type: config.type }
    this.#animations.set(role, state)
    this.#log.info('Animation started', { role, config })
  }

  public updateAnimations(delta: number): void {
    const start = performance.now()
    this.#animations.forEach((state, role) => {
      state.progress += delta
      if (state.progress >= state.duration) {
        this.#animations.delete(role)
        this.#log.debug('Animation completed', { role })
      }
    })
    const elapsed = performance.now() - start
    if (this.#animations.size) this.#perf.debug('Animations updated', { count: this.#animations.size, elapsed })
  }

  public stopAll(): void {
    const count = this.#animations.size
    this.#animations.clear()
    this.#log.warn('All animations stopped', { count })
  }

  public dispose(): void {
    this.stopAll()
    this.#log.info('AnimationService disposed')
    AnimationService.#instance = null
  }
}

export const animationService = AnimationService.getInstance()
"@

    Set-Content -Path (Join-Path $servicesPath "animationService.ts") -Value $serviceContent -Encoding UTF8
    Write-SuccessLog "AnimationService implementation created"

    Write-SuccessLog "40-GenerateAnimationService.ps1 completed successfully"
    exit 0
}
catch {
    Write-ErrorLog "Animation Service Generation failed: $($_.Exception.Message)"
    exit 1
}