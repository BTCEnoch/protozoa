# 41-GenerateGroupService.ps1 - Phase 6 Core Domain Implementation
# Generates GroupService and interface for managing particle groups
# Reference: script_checklist.md | build_design.md lines 1100-1250 (Group domain)
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
    Write-StepHeader "Group Service Generation - Phase 6 Core Domain Implementation"
    Write-InfoLog "Generating GroupService and interfaces"

    # Paths
    $groupDomainPath = Join-Path $ProjectRoot "src/domains/group"
    $servicesPath    = Join-Path $groupDomainPath "services"
    $interfacesPath  = Join-Path $groupDomainPath "interfaces"

    New-Item -Path $servicesPath   -ItemType Directory -Force | Out-Null
    New-Item -Path $interfacesPath -ItemType Directory -Force | Out-Null

    Write-SuccessLog "Group domain directories ensured"

    # Interface
    $interfaceContent = @"

/**
 * @fileoverview IGroupService Interface Definition
 * @description Contract for grouping particles and managing group lifecycle.
 */

export interface ParticleGroup {
  id: string
  members: string[]
}

export interface IGroupService {
  formGroup(particleIds: string[]): ParticleGroup
  getGroup(id: string): ParticleGroup | undefined
  dissolveGroup(id: string): void
  dispose(): void
}
"@

    Set-Content -Path (Join-Path $interfacesPath "IGroupService.ts") -Value $interfaceContent -Encoding UTF8
    Write-SuccessLog "IGroupService interface created"

    # Implementation
    $serviceContent = @"

import { createServiceLogger } from '@/shared/lib/logger'
import type { IGroupService, ParticleGroup } from '@/domains/group/interfaces/IGroupService'
import type { IRNGService } from '@/domains/rng/interfaces/IRNGService'

class GroupService implements IGroupService {
  static #instance: GroupService | null = null

  #groups: Map<string, ParticleGroup> = new Map()
  #rng?: IRNGService
  #log = createServiceLogger('GROUP_SERVICE')

  private constructor() {
    this.#log.info('GroupService singleton created')
  }

  public static getInstance(): GroupService {
    if (!GroupService.#instance) GroupService.#instance = new GroupService()
    return GroupService.#instance
  }

  /** Inject RNG dependency */
  public configure(rng: IRNGService) {
    this.#rng = rng
    this.#log.debug('RNG injected')
  }

  public formGroup(particleIds: string[]): ParticleGroup {
    const gid = this.#rng ? `group-${this.#rng.randomInt(1000, 9999)}` : `group-${this.#groups.size + 1}`
    const group: ParticleGroup = { id: gid, members: [...particleIds] }
    this.#groups.set(gid, group)
    this.#log.info('Group formed', { gid, size: particleIds.length })
    return group
  }

  public getGroup(id: string): ParticleGroup | undefined {
    return this.#groups.get(id)
  }

  public dissolveGroup(id: string): void {
    if (this.#groups.delete(id)) {
      this.#log.info('Group dissolved', { id })
    }
  }

  public dispose(): void {
    this.#groups.clear()
    this.#log.info('GroupService disposed')
    GroupService.#instance = null
  }
}

export const groupService = GroupService.getInstance()
"@

    Set-Content -Path (Join-Path $servicesPath "groupService.ts") -Value $serviceContent -Encoding UTF8
    Write-SuccessLog "GroupService implementation created"

    Write-SuccessLog "41-GenerateGroupService.ps1 completed successfully"
    exit 0
}
catch {
    Write-ErrorLog "Group Service Generation failed: $($_.Exception.Message)"
    exit 1
}
