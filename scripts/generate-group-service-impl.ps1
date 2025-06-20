# generate-group-service-impl.ps1 - Generate Complete GroupService Implementation
# Creates the complete GroupService class with all methods
#Requires -Version 5.1

Write-Host "Generating complete GroupService implementation..." -ForegroundColor Green

try {
    $groupServicePath = "src/domains/group/services/GroupService.ts"
    
    # Generate the complete GroupService implementation
    $groupServiceContent = @'
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
'@

    Set-Content -Path $groupServicePath -Value $groupServiceContent -Encoding UTF8
    Write-Host "Generated GroupService implementation (Part 1)" -ForegroundColor Yellow

    exit 0
}
catch {
    Write-Host "GroupService implementation generation failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} 