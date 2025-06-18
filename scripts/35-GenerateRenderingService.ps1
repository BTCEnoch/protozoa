# 35-GenerateRenderingService.ps1 - Phase 5 Core Domain Implementation
# Generates RenderingService for THREE.js scene management and associated interface
# Reference: script_checklist.md | build_design.md lines 60-300 (Rendering domain)
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
    Write-StepHeader "Rendering Service Generation - Phase 5 Core Domain Implementation"
    Write-InfoLog "Generating RenderingService and interfaces"

    # Define paths
    $renderingDomainPath = Join-Path $ProjectRoot "src/domains/rendering"
    $servicesPath       = Join-Path $renderingDomainPath "services"
    $interfacesPath     = Join-Path $renderingDomainPath "interfaces"

    # Ensure directories exist
    New-Item -Path $servicesPath   -ItemType Directory -Force | Out-Null
    New-Item -Path $interfacesPath -ItemType Directory -Force | Out-Null

    Write-SuccessLog "Rendering domain directories ensured"

    # Create IRenderingService interface
    $interfaceContent = @"

/**
 * @fileoverview IRenderingService Interface Definition
 * @description Contract for THREE.js rendering operations used across the application.
 */

import type { Object3D, PerspectiveCamera, Scene, WebGLRenderer } from 'three'
import type { IFormationService } from '@/domains/formation/interfaces/IFormationService'
import type { IEffectService }    from '@/domains/effect/interfaces/IEffectService'

export interface IRenderingService {
  /** Attach renderer to canvas and wire optional domain dependencies */
  initialize(canvas: HTMLCanvasElement, deps?: { formation?: IFormationService; effect?: IEffectService }): void
  /** Render one animation frame */
  renderFrame(delta: number): void
  /** Add an Object3D to the scene graph */
  addObject(obj: Object3D): void
  /** Remove an Object3D from the scene graph */
  removeObject(obj: Object3D): void
  /** Apply a formation pattern to current particle system */
  applyFormation(patternId: string): void
  /** Trigger a visual effect */
  applyEffect(effectName: string, options?: unknown): void
  /** Access underlying Three.js objects (for advanced usage) */
  readonly scene: Scene
  readonly camera: PerspectiveCamera
  readonly renderer: WebGLRenderer
  /** Cleanup GPU resources and detach event listeners */
  dispose(): void
}
"@

    Set-Content -Path (Join-Path $interfacesPath "IRenderingService.ts") -Value $interfaceContent -Encoding UTF8
    Write-SuccessLog "IRenderingService interface created"

    # Create RenderingService implementation
    $serviceContent = @"

/**
 * @fileoverview RenderingService Implementation
 * @description Singleton THREE.js renderer orchestrating scene, camera, and domain integrations.
 */

import { Scene, PerspectiveCamera, WebGLRenderer, Object3D } from 'three'
import { createServiceLogger, createPerformanceLogger, createErrorLogger } from '@/shared/lib/logger'
import type { IRenderingService }  from '@/domains/rendering/interfaces/IRenderingService'
import type { IFormationService }  from '@/domains/formation/interfaces/IFormationService'
import type { IEffectService }     from '@/domains/effect/interfaces/IEffectService'

class RenderingService implements IRenderingService {
  /** Singleton instance */
  static #instance: RenderingService | null = null

  // THREE.js core
  #scene = new Scene()
  #camera: PerspectiveCamera
  #renderer: WebGLRenderer

  // Injected domain services
  #formationService?: IFormationService
  #effectService?: IEffectService

  // Loggers
  #log  = createServiceLogger('RENDERING_SERVICE')
  #perf = createPerformanceLogger('RENDERING_SERVICE')
  #err  = createErrorLogger('RENDERING_SERVICE')

  private constructor() {
    // Camera init
    this.#camera = new PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000)
    this.#camera.position.z = 50
    // Renderer init
    this.#renderer = new WebGLRenderer({ antialias: true })
    this.#renderer.setSize(window.innerWidth, window.innerHeight)
    this.#log.info('RenderingService constructor complete')
  }

  /** Get singleton */
  public static getInstance(): RenderingService {
    if (!RenderingService.#instance) RenderingService.#instance = new RenderingService()
    return RenderingService.#instance
  }

  /** Public getters for low-level access (read-only) */
  get scene()     { return this.#scene }
  get camera()    { return this.#camera }
  get renderer()  { return this.#renderer }

  /** Initialize renderer on canvas and wire dependencies */
  public initialize(canvas: HTMLCanvasElement, deps: { formation?: IFormationService; effect?: IEffectService } = {}): void {
    // Attach DOM element
    if (canvas && this.#renderer.domElement.parentElement -ne $null) {
      this.#renderer.domElement.remove()
    }
    canvas.appendChild(this.#renderer.domElement)

    // Dependency injection
    this.#formationService = deps.formation
    this.#effectService    = deps.effect

    this.#log.info('RenderingService initialized with dependencies', { hasFormation: !!deps.formation, hasEffect: !!deps.effect })
  }

  /** Render a single frame */
  public renderFrame(delta: number): void {
    this.#renderer.render(this.#scene, this.#camera)
    this.#perf.debug(`Frame rendered in ${delta}ms`)
  }

  public addObject(obj: Object3D): void {
    this.#scene.add(obj)
    this.#log.debug('Object added', { id: obj.id })
  }

  public removeObject(obj: Object3D): void {
    this.#scene.remove(obj)
    this.#log.debug('Object removed', { id: obj.id })
  }

  public applyFormation(patternId: string): void {
    if (!this.#formationService) {
      this.#err.logError(new Error('FormationService unavailable'), { patternId })
      return
    }
    const pattern = this.#formationService.getFormationPattern(patternId)
    if (!pattern) {
      this.#log.warn('Formation pattern not found', { patternId })
      return
    }
    // Actual particle repositioning delegated outside; log for now.
    this.#log.info('Formation applied', { patternId, positions: pattern.positions?.length })
  }

  public applyEffect(effectName: string, options?: unknown): void {
    if (!this.#effectService) {
      this.#err.logError(new Error('EffectService unavailable'), { effectName })
      return
    }
    this.#effectService.triggerEffect(effectName, options)
    this.#log.info('Effect triggered', { effectName })
  }

  /** Dispose GPU resources and detach */
  public dispose(): void {
    this.#scene.clear()
    this.#renderer.dispose()
    this.#log.info('RenderingService disposed')
    RenderingService.#instance = null
  }
}

export const renderingService = RenderingService.getInstance()
"@

    Set-Content -Path (Join-Path $servicesPath "renderingService.ts") -Value $serviceContent -Encoding UTF8
    Write-SuccessLog "RenderingService implementation created"

    Write-SuccessLog "35-GenerateRenderingService.ps1 completed successfully"
    exit 0
}
catch {
    Write-ErrorLog "Rendering Service Generation failed: $($_.Exception.Message)"
    exit 1
}
