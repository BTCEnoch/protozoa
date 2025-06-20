# generate-group-service-simple.ps1 - Simple Group Service Generation
# Generates complete GroupService with swarm support without utils.psm1 dependency
#Requires -Version 5.1

Write-Host "Enhanced Group Service Generation with Swarm Support" -ForegroundColor Green

try {
    # Create directories
    $groupDomainPath = "src/domains/group"
    $servicesPath = Join-Path $groupDomainPath "services"
    $interfacesPath = Join-Path $groupDomainPath "interfaces"
    $typesPath = Join-Path $groupDomainPath "types"

    @($servicesPath, $interfacesPath, $typesPath) | ForEach-Object {
        New-Item -Path $_ -ItemType Directory -Force | Out-Null
    }

    Write-Host "Group domain directories created" -ForegroundColor Yellow

    # Generate complete IGroupService interface
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

    Set-Content -Path (Join-Path $interfacesPath "IGroupService.ts") -Value $interfaceContent -Encoding UTF8
    Write-Host "Generated enhanced IGroupService interface" -ForegroundColor Green

    Write-Host "Enhanced Group Service generation completed successfully!" -ForegroundColor Green
}
catch {
    Write-Host "Enhanced Group Service Generation failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} 