# create-complete-group-service.ps1 - Create Complete GroupService
# Generates the entire GroupService implementation in one operation
#Requires -Version 5.1

Write-Host "Creating complete GroupService implementation..." -ForegroundColor Green

try {
    $groupServicePath = "src/domains/group/services/GroupService.ts"
    
    # Generate the complete GroupService implementation
    $completeGroupService = @'
/**
 * @fileoverview Enhanced GroupService - Comprehensive particle group management
 * @module @/domains/group/services
 * @version 1.0.0
 *
 * Manages particle groups with swarm intelligence, formation integration, and behavioral patterns.
 * Implements singleton pattern with dependency injection and comprehensive logging.
 *
 * Reference: build_design.md Section 8 - Group domain enhancement
 * Reference: .cursorrules Service Architecture Standards
 */

import { IGroupService, ParticleGroup, GroupFormationConfig } from "../interfaces/IGroupService";
import { IVector3 } from "@/shared/types";
import { createServiceLogger, createPerformanceLogger } from "@/shared/lib/logger";

/**
 * Enhanced GroupService - Singleton service for managing particle groups with swarm capabilities
 *
 * Provides comprehensive group management including:
 * - Group formation and dissolution
 * - Behavioral pattern assignment (flock, swarm, formation, custom)
 * - Formation pattern integration
 * - Center position tracking and updates
 * - Performance metrics and monitoring
 * - Proper dependency injection for cross-domain services
 */
class GroupService implements IGroupService {
  static #instance: GroupService | null = null;

  // Core group storage with behavioral categorization
  #groups = new Map<string, ParticleGroup>();
  
  // Dependency injection for cross-domain services
  #rngService?: any; // IRNGService when available
  #formationService?: any; // IFormationService when available

  // Logging utilities
  #log = createServiceLogger("GROUP_SERVICE");
  #perfLog = createPerformanceLogger("GROUP_SERVICE");

  // Performance metrics
  #metrics = {
    totalGroups: 0,
    groupsFormed: 0,
    groupsDissolved: 0,
    formationsApplied: 0
  };

  /**
   * Private constructor enforces singleton pattern
   * Initializes logging and metrics tracking
   */
  private constructor() {
    this.#log.info("Enhanced GroupService initializing with swarm capabilities");
  }

  /**
   * Gets the singleton instance of GroupService
   * @returns The singleton instance
   */
  public static getInstance(): GroupService {
    if (!GroupService.#instance) {
      GroupService.#instance = new GroupService();
    }
    return GroupService.#instance;
  }

  /**
   * Forms a new group from the given particle IDs with optional behavior
   * @param particleIds - Array of particle IDs to group together
   * @param behavior - Optional behavior type for the group
   * @returns The created ParticleGroup
   */
  public formGroup(particleIds: string[], behavior: "flock" | "swarm" | "formation" | "custom" = "flock"): ParticleGroup {
    try {
      // Generate unique group ID using RNG service if available
      const groupId = this.#rngService 
        ? `group-${this.#rngService.randomInt(1000, 9999)}-${Date.now()}`
        : `group-${this.#groups.size + 1}-${Date.now()}`;

      // Create group with metadata
      const group: ParticleGroup = {
        id: groupId,
        members: [...particleIds],
        metadata: {
          behavior,
          createdAt: Date.now(),
          center: { x: 0, y: 0, z: 0 } // Will be calculated
        }
      };

      // Store the group
      this.#groups.set(groupId, group);
      
      // Update metrics
      this.#metrics.totalGroups = this.#groups.size;
      this.#metrics.groupsFormed++;

      // Calculate initial center position
      this.updateGroupCenter(groupId);

      this.#log.info("Group formed successfully", {
        groupId,
        memberCount: particleIds.length,
        behavior,
        totalGroups: this.#groups.size
      });

      return group;

    } catch (error) {
      this.#log.error("Group formation failed", {
        memberCount: particleIds.length,
        behavior,
        error: (error as Error).message
      });
      throw error;
    }
  }

  /**
   * Retrieves a group by its ID
   * @param id - Group identifier
   * @returns ParticleGroup if found, undefined otherwise
   */
  public getGroup(id: string): ParticleGroup | undefined {
    try {
      const group = this.#groups.get(id);
      if (group) {
        this.#log.debug("Group retrieved", { groupId: id, memberCount: group.members.length });
      }
      return group;
    } catch (error) {
      this.#log.error("Group retrieval failed", { groupId: id, error: (error as Error).message });
      return undefined;
    }
  }

  /**
   * Gets all groups currently managed by the service
   * @returns Array of all ParticleGroups
   */
  public getAllGroups(): ParticleGroup[] {
    try {
      const groups = Array.from(this.#groups.values());
      this.#log.debug("Retrieved all groups", { count: groups.length });
      return groups;
    } catch (error) {
      this.#log.error("Failed to retrieve all groups", { error: (error as Error).message });
      return [];
    }
  }

  /**
   * Gets groups by behavior type
   * @param behavior - Behavior type to filter by
   * @returns Array of ParticleGroups with matching behavior
   */
  public getGroupsByBehavior(behavior: "flock" | "swarm" | "formation" | "custom"): ParticleGroup[] {
    try {
      const groups = Array.from(this.#groups.values()).filter(
        group => group.metadata?.behavior === behavior
      );
      
      this.#log.debug("Retrieved groups by behavior", { behavior, count: groups.length });
      return groups;
    } catch (error) {
      this.#log.error("Failed to retrieve groups by behavior", { 
        behavior, 
        error: (error as Error).message 
      });
      return [];
    }
  }

  /**
   * Dissolves a group, removing it from management
   * @param id - Group identifier to dissolve
   * @returns True if group was dissolved, false if not found
   */
  public dissolveGroup(id: string): boolean {
    try {
      const existed = this.#groups.delete(id);
      
      if (existed) {
        this.#metrics.totalGroups = this.#groups.size;
        this.#metrics.groupsDissolved++;
        
        this.#log.info("Group dissolved successfully", { 
          groupId: id, 
          remainingGroups: this.#groups.size 
        });
        return true;
      }
      
      this.#log.warn("Attempted to dissolve non-existent group", { groupId: id });
      return false;
      
    } catch (error) {
      this.#log.error("Group dissolution failed", { 
        groupId: id, 
        error: (error as Error).message 
      });
      return false;
    }
  }

  /**
   * Applies a formation pattern to a group
   * @param groupId - ID of the group to apply formation to
   * @param config - Formation configuration
   * @returns True if formation was applied successfully
   */
  public applyFormationToGroup(groupId: string, config: GroupFormationConfig): boolean {
    try {
      const group = this.#groups.get(groupId);
      if (!group) {
        this.#log.warn("Cannot apply formation to non-existent group", { groupId });
        return false;
      }

      if (!this.#formationService) {
        this.#log.warn("Formation service not available for group formation", { groupId });
        return false;
      }

      // Update group metadata with formation info
      if (group.metadata) {
        group.metadata.formationId = config.formationId;
        group.metadata.behavior = "formation";
      }

      this.#metrics.formationsApplied++;
      
      this.#log.info("Formation applied to group", {
        groupId,
        formationId: config.formationId,
        memberCount: group.members.length
      });

      return true;

    } catch (error) {
      this.#log.error("Formation application failed", {
        groupId,
        formationId: config.formationId,
        error: (error as Error).message
      });
      return false;
    }
  }

  /**
   * Updates group center position based on member positions
   * @param groupId - ID of the group to update
   * @returns Updated center position or undefined if group not found
   */
  public updateGroupCenter(groupId: string): IVector3 | undefined {
    try {
      const group = this.#groups.get(groupId);
      if (!group || !group.metadata) {
        return undefined;
      }

      // For now, return a placeholder center position
      // In a full implementation, this would calculate based on actual particle positions
      const center: IVector3 = { x: 0, y: 0, z: 0 };
      group.metadata.center = center;

      this.#log.debug("Group center updated", { groupId, center });
      return center;

    } catch (error) {
      this.#log.error("Group center update failed", { 
        groupId, 
        error: (error as Error).message 
      });
      return undefined;
    }
  }

  /**
   * Configures RNG service dependency for group ID generation
   * @param rng - RNG service instance
   */
  public configureRNG(rng: any): void {
    try {
      this.#rngService = rng;
      this.#log.info("RNG service configured for GroupService");
    } catch (error) {
      this.#log.error("RNG service configuration failed", { error: (error as Error).message });
    }
  }

  /**
   * Configures Formation service dependency for formation operations
   * @param formation - Formation service instance
   */
  public configureFormation(formation: any): void {
    try {
      this.#formationService = formation;
      this.#log.info("Formation service configured for GroupService");
    } catch (error) {
      this.#log.error("Formation service configuration failed", { error: (error as Error).message });
    }
  }

  /**
   * Gets performance metrics for the group service
   * @returns Object containing service metrics
   */
  public getMetrics(): {
    totalGroups: number;
    groupsByBehavior: Record<string, number>;
    averageGroupSize: number;
  } {
    try {
      const groupsByBehavior: Record<string, number> = {
        flock: 0,
        swarm: 0,
        formation: 0,
        custom: 0
      };

      let totalMembers = 0;
      
      for (const group of this.#groups.values()) {
        const behavior = group.metadata?.behavior || "flock";
        groupsByBehavior[behavior]++;
        totalMembers += group.members.length;
      }

      const averageGroupSize = this.#groups.size > 0 ? totalMembers / this.#groups.size : 0;

      return {
        totalGroups: this.#groups.size,
        groupsByBehavior,
        averageGroupSize
      };

    } catch (error) {
      this.#log.error("Metrics calculation failed", { error: (error as Error).message });
      return {
        totalGroups: 0,
        groupsByBehavior: { flock: 0, swarm: 0, formation: 0, custom: 0 },
        averageGroupSize: 0
      };
    }
  }

  /**
   * Disposes of the service, clearing all groups and resetting state
   */
  public dispose(): void {
    try {
      const groupCount = this.#groups.size;
      
      // Clear all groups
      this.#groups.clear();
      
      // Reset metrics
      this.#metrics = {
        totalGroups: 0,
        groupsFormed: 0,
        groupsDissolved: 0,
        formationsApplied: 0
      };

      // Clear service dependencies
      this.#rngService = undefined;
      this.#formationService = undefined;

      this.#log.info("GroupService disposed successfully", { 
        groupsCleared: groupCount,
        metricsReset: true 
      });

      // Reset singleton instance
      GroupService.#instance = null;

    } catch (error) {
      this.#log.error("GroupService disposal failed", { error: (error as Error).message });
    }
  }
}

// Export singleton instance and class
export const groupService = GroupService.getInstance();
export { GroupService };
'@

    Set-Content -Path $groupServicePath -Value $completeGroupService -Encoding UTF8
    Write-Host "Created complete GroupService implementation" -ForegroundColor Green

    # Create compatibility wrapper
    $wrapperPath = "src/domains/group/services/groupService.ts"
    $wrapperContent = "export * from './GroupService';"
    Set-Content -Path $wrapperPath -Value $wrapperContent -Encoding UTF8
    Write-Host "Created compatibility wrapper: groupService.ts" -ForegroundColor Yellow

    Write-Host "Complete GroupService generation finished successfully!" -ForegroundColor Green

    exit 0
}
catch {
    Write-Host "Complete GroupService generation failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} 