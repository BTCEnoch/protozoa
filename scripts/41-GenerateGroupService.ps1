# 41-GenerateGroupService.ps1 - Enhanced Group Service Generation
# Generates comprehensive GroupService with swarm support and formation integration
# Reference: build_design.md lines 1044-1141 | SwarmService requirements
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
    Write-StepHeader "Enhanced Group Service Generation with Swarm Support"
    Write-InfoLog "Generating GroupService with swarm management capabilities"

    # Paths
    $groupDomainPath = Join-Path $ProjectRoot "src/domains/group"
    $servicesPath    = Join-Path $groupDomainPath "services"
    $interfacesPath  = Join-Path $groupDomainPath "interfaces"
    $typesPath       = Join-Path $groupDomainPath "types"

    # Create directory structure
    @($servicesPath, $interfacesPath, $typesPath) | ForEach-Object {
        New-Item -Path $_ -ItemType Directory -Force | Out-Null
    }

    Write-SuccessLog "Group domain directories created"

    # Generate enhanced interface
    $interfaceContent = @'
/**
 * @fileoverview Enhanced IGroupService interface with swarm management capabilities
 * @module @/domains/group/interfaces
 * @version 1.0.0
 * 
 * Defines contracts for particle group management, swarm operations, and formation integration.
 * Supports the SwarmService and other group-based services with proper encapsulation.
 * 
 * Reference: build_design.md Section 8 - Group domain enhancement
 * Reference: .cursorrules Service Architecture Standards
 */

import { IVector3 } from "@/shared/types";

/**
 * Represents a group of particles with metadata
 */
export interface ParticleGroup {
  /** Unique identifier for the group */
  id: string;
  
  /** Array of particle IDs in this group */
  members: string[];
  
  /** Optional group metadata */
  metadata?: {
    /** Group formation pattern if applied */
    formationId?: string;
    /** Group center position */
    center?: IVector3;
    /** Group behavior type */
    behavior?: "flock" | "swarm" | "formation" | "custom";
    /** Creation timestamp */
    createdAt?: number;
  };
}

/**
 * Configuration for group formation operations
 */
export interface GroupFormationConfig {
  /** Formation pattern ID to apply */
  formationId: string;
  /** Scale factor for formation */
  scale?: number;
  /** Center position for formation */
  center?: IVector3;
  /** Transition duration in milliseconds */
  transitionDuration?: number;
}
'@

    Set-Content -Path (Join-Path $interfacesPath "IGroupService.ts") -Value $interfaceContent -Encoding UTF8
    Write-SuccessLog "Generated enhanced IGroupService interface (Part 1)"

    # Step 2: Complete the interface with service methods
    Write-InfoLog "Step 2: Completing IGroupService interface"
    & "$PSScriptRoot\41a-CompleteGroupInterface.ps1" -ProjectRoot $ProjectRoot
    if ($LASTEXITCODE -ne 0) {
        throw "Interface completion failed"
    }

    # Step 3: Generate GroupService implementation
    Write-InfoLog "Step 3: Generating GroupService implementation"
    & "$PSScriptRoot\41b-GenerateGroupServiceImpl.ps1" -ProjectRoot $ProjectRoot
    if ($LASTEXITCODE -ne 0) {
        throw "GroupService implementation failed"
    }

    # Step 4: Complete GroupService methods
    Write-InfoLog "Step 4: Adding remaining GroupService methods"
    & "$PSScriptRoot\41c-CompleteGroupServiceMethods.ps1" -ProjectRoot $ProjectRoot
    if ($LASTEXITCODE -ne 0) {
        throw "GroupService methods completion failed"
    }

    # Step 5: Finalize GroupService
    Write-InfoLog "Step 5: Finalizing GroupService with exports"
    & "$PSScriptRoot\41d-FinalizeGroupService.ps1" -ProjectRoot $ProjectRoot
    if ($LASTEXITCODE -ne 0) {
        throw "GroupService finalization failed"
    }

    Write-SuccessLog "Enhanced Group Service Generation completed successfully"
    Write-InfoLog "Generated complete GroupService with swarm management capabilities"

    exit 0
}
catch {
    Write-ErrorLog "Enhanced Group Service Generation failed: $($_.Exception.Message)"
    exit 1
}
