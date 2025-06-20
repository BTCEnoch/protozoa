# 41c-CompleteGroupServiceMethods.ps1 - Complete GroupService Methods
# Adds remaining methods to GroupService implementation
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
    Write-InfoLog "Completing GroupService methods"

    $groupServicePath = Join-Path $ProjectRoot "src/domains/group/services/GroupService.ts"
    
    # Add the remaining methods to complete the GroupService
    $groupServiceMethods = @'

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
'@

    Add-Content -Path $groupServicePath -Value $groupServiceMethods -Encoding UTF8
    Write-SuccessLog "Added core GroupService methods"

    exit 0
}
catch {
    Write-ErrorLog "GroupService methods completion failed: $($_.Exception.Message)"
    exit 1
} 