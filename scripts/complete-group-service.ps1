# complete-group-service.ps1 - Complete GroupService Implementation
# Adds all remaining methods to complete the GroupService
#Requires -Version 5.1

Write-Host "Completing GroupService implementation with all methods..." -ForegroundColor Green

try {
    $groupServicePath = "src/domains/group/services/GroupService.ts"
    
    # Add all remaining methods to complete the GroupService
    $completeMethods = @'

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

    Add-Content -Path $groupServicePath -Value $completeMethods -Encoding UTF8
    Write-Host "Added core GroupService methods" -ForegroundColor Yellow

    exit 0
}
catch {
    Write-Host "GroupService completion failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} 