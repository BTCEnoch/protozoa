# 41a-CompleteGroupInterface.ps1 - Complete IGroupService Interface
# Adds the main service contract methods to IGroupService
# Reference: build_design.md lines 1044-1141 | SwarmService requirements
#Requires -Version 5.1

[CmdletBinding()]
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
    Write-InfoLog "Completing IGroupService interface with service methods"

    $interfacePath = Join-Path $ProjectRoot "src/domains/group/interfaces/IGroupService.ts"
    
    # Complete the interface with service methods
    $interfaceMethodsContent = @'

/**
 * Enhanced interface for GroupService with swarm management capabilities
 * Provides methods for group formation, management, and swarm operations
 */
export interface IGroupService {
  /**
   * Forms a new group from the given particle IDs
   * @param particleIds - Array of particle IDs to group together
   * @param behavior - Optional behavior type for the group
   * @returns The created ParticleGroup
   */
  formGroup(particleIds: string[], behavior?: "flock" | "swarm" | "formation" | "custom"): ParticleGroup;

  /**
   * Retrieves a group by its ID
   * @param id - Group identifier
   * @returns ParticleGroup if found, undefined otherwise
   */
  getGroup(id: string): ParticleGroup | undefined;

  /**
   * Gets all groups currently managed by the service
   * @returns Array of all ParticleGroups
   */
  getAllGroups(): ParticleGroup[];

  /**
   * Gets groups by behavior type
   * @param behavior - Behavior type to filter by
   * @returns Array of ParticleGroups with matching behavior
   */
  getGroupsByBehavior(behavior: "flock" | "swarm" | "formation" | "custom"): ParticleGroup[];

  /**
   * Dissolves a group, removing it from management
   * @param id - Group identifier to dissolve
   * @returns True if group was dissolved, false if not found
   */
  dissolveGroup(id: string): boolean;

  /**
   * Applies a formation pattern to a group
   * @param groupId - ID of the group to apply formation to
   * @param config - Formation configuration
   * @returns True if formation was applied successfully
   */
  applyFormationToGroup(groupId: string, config: GroupFormationConfig): boolean;

  /**
   * Updates group center position based on member positions
   * @param groupId - ID of the group to update
   * @returns Updated center position or undefined if group not found
   */
  updateGroupCenter(groupId: string): IVector3 | undefined;

  /**
   * Configures RNG service dependency for group ID generation
   * @param rng - RNG service instance
   */
  configureRNG(rng: any): void;

  /**
   * Configures Formation service dependency for formation operations
   * @param formation - Formation service instance
   */
  configureFormation(formation: any): void;

  /**
   * Gets performance metrics for the group service
   * @returns Object containing service metrics
   */
  getMetrics(): {
    totalGroups: number;
    groupsByBehavior: Record<string, number>;
    averageGroupSize: number;
  };

  /**
   * Disposes of the service, clearing all groups and resetting state
   */
  dispose(): void;
}
'@

    Add-Content -Path $interfacePath -Value $interfaceMethodsContent -Encoding UTF8
    Write-SuccessLog "Completed IGroupService interface with service methods"

    exit 0
}
catch {
    Write-ErrorLog "Interface completion failed: $($_.Exception.Message)"
    exit 1
} 