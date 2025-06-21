# 31-GenerateParticleService.ps1 - Phase 4 Rendering & Optimization
# Generates complete ParticleService with THREE.js integration and GPU optimization
# ARCHITECTURE: Singleton pattern with object pooling and instanced rendering
# Reference: script_checklist.md lines 31-GenerateParticleService.ps1
# Reference: build_design.md lines 500-650 - Particle service and THREE.js integration
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
    Write-StepHeader "Particle Service Generation - Phase 4 Rendering & Optimization"
    Write-InfoLog "Generating complete ParticleService with THREE.js integration and GPU optimization"

    # Define paths
    $particleDomainPath = Join-Path $ProjectRoot "src/domains/particle"
    $servicesPath = Join-Path $particleDomainPath "services"
    $typesPath = Join-Path $particleDomainPath "types"
    $interfacesPath = Join-Path $particleDomainPath "interfaces"
    $utilsPath = Join-Path $particleDomainPath "utils"

    # Ensure directories exist
    Write-InfoLog "Creating Particle domain directory structure"
    New-Item -Path $servicesPath -ItemType Directory -Force | Out-Null
    New-Item -Path $typesPath -ItemType Directory -Force | Out-Null
    New-Item -Path $interfacesPath -ItemType Directory -Force | Out-Null
    New-Item -Path $utilsPath -ItemType Directory -Force | Out-Null

    Write-SuccessLog "Particle domain directories created successfully"

    # Generate Particle service interface
    Write-InfoLog "Generating IParticleService interface"
    $interfaceContent = @'
/**
 * @fileoverview Particle Service Interface Definition
 * @description Defines the contract for particle system management services
 * @author Protozoa Development Team
 * @version 1.0.0
 */

import { Vector3, Scene, BufferGeometry, Material } from "three";
import { 
  ParticleType, 
  ParticleSystemConfig, 
  ParticleCreationData, 
  ParticleMetrics 
} from "../types/particle.types";

/**
 * Configuration options for Particle service initialization
 */
export interface ParticleConfig {
  /** Maximum number of particles in the system */
  maxParticles?: number;
  /** Enable GPU instancing for performance */
  useInstancing?: boolean;
  /** Enable object pooling */
  useObjectPooling?: boolean;
  /** Default particle material type */
  defaultMaterial?: string;
  /** Enable LOD (Level of Detail) optimization */
  enableLOD?: boolean;
  /** Culling distance for particles */
  cullingDistance?: number;
}

/**
 * Particle instance data
 */
export interface ParticleInstance {
  /** Unique particle identifier */
  id: string;
  /** Particle position */
  position: Vector3;
  /** Particle velocity */
  velocity: Vector3;
  /** Particle scale */
  scale: Vector3;
  /** Particle rotation */
  rotation: number;
  /** Particle color (RGB) */
  color: { r: number; g: number; b: number };
  /** Particle opacity */
  opacity: number;
  /** Particle age in seconds */
  age: number;
  /** Particle lifetime in seconds */
  lifetime: number;
  /** Whether particle is active */
  active: boolean;
  /** Particle type identifier */
  type: ParticleType;
  /** Custom particle data */
  userData: Record<string, any>;
}

/**
 * Particle system definition
 */
export interface ParticleSystem {
  /** System identifier */
  id: string;
  /** System name */
  name: string;
  /** Maximum particles in this system */
  maxParticles: number;
  /** Active particles count */
  activeParticles: number;
  /** Particles array */
  particles: ParticleInstance[];
  /** System position */
  position: Vector3;
  /** System bounds */
  bounds: Vector3;
  /** Whether system is active */
  active: boolean;
  /** System creation timestamp */
  createdAt: number;
}

/**
 * Particle service interface defining particle system management
 * Provides high-performance particle rendering with THREE.js integration
 */
export interface IParticleService {
  /**
   * Initialize the Particle service with configuration
   * @param config - Particle service configuration
   */
  initialize(config?: ParticleConfig): Promise<void>;

  /**
   * Create a new particle system
   * @param systemConfig - System configuration
   * @returns Created particle system
   */
  createSystem(systemConfig: ParticleSystemConfig): ParticleSystem;

  /**
   * Add particles to a system
   * @param systemId - System identifier
   * @param particleData - Particle creation data
   * @returns Array of created particle IDs
   */
  addParticles(systemId: string, particleData: ParticleCreationData[]): string[];

  /**
   * Remove particles from a system
   * @param systemId - System identifier
   * @param particleIds - Particle IDs to remove
   */
  removeParticles(systemId: string, particleIds: string[]): void;

  /**
   * Update all particle systems
   * @param deltaTime - Time delta in seconds
   */
  update(deltaTime: number): void;

  /**
   * Render particles to THREE.js scene
   * @param scene - THREE.js scene
   */
  render(scene: Scene): void;

  /**
   * Get particle system by ID
   * @param systemId - System identifier
   * @returns Particle system or undefined
   */
  getSystem(systemId: string): ParticleSystem | undefined;

  /**
   * Get all particle systems
   * @returns Array of all particle systems
   */
  getAllSystems(): ParticleSystem[];

  /**
   * Get particle performance metrics
   * @returns Particle service metrics
   */
  getMetrics(): ParticleMetrics;

  /**
   * Dispose of resources and cleanup
   */
  dispose(): void;
}
'@

    Set-Content -Path (Join-Path $interfacesPath "IParticleService.ts") -Value $interfaceContent -Encoding UTF8
    Write-SuccessLog "IParticleService interface generated successfully"

    # Generate ParticleService from template
    Write-InfoLog "Generating ParticleService from template"
    $serviceTemplate = Join-Path $ProjectRoot "templates/domains/particle/services/ParticleService.ts.template"
    
    if (Test-Path $serviceTemplate) {
        $serviceContent = Get-Content -Path $serviceTemplate -Raw
        Set-Content -Path (Join-Path $servicesPath "ParticleService.ts") -Value $serviceContent -Encoding UTF8
        Write-SuccessLog "ParticleService generated from template successfully"
    } else {
        Write-ErrorLog "ParticleService template not found: $serviceTemplate"
        throw "Template file missing: $serviceTemplate"
    }

    # Generate particle types
    Write-InfoLog "Generating particle types"
    $typesContent = @'
/**
 * @fileoverview Particle System Type Definitions
 * @description Comprehensive type definitions for particle systems and rendering
 * @author Protozoa Development Team
 * @version 1.0.0
 */

import { Vector3, BufferGeometry, Material, Color } from "three";

/**
 * Particle type enumeration
 */
export type ParticleType = "basic" | "enhanced" | "mutated" | "evolved" | "composite";

/**
 * Rendering mode for particles
 */
export type RenderingMode = "points" | "sprites" | "instanced" | "geometry";

/**
 * Blending mode for particle rendering
 */
export type BlendingMode = "normal" | "additive" | "subtractive" | "multiply" | "screen";

/**
 * Particle system configuration
 */
export interface ParticleSystemConfig {
  /** Unique system identifier */
  id: string;
  /** Human-readable system name */
  name: string;
  /** Maximum particles in this system */
  maxParticles: number;
  /** System world position */
  position: Vector3;
  /** System bounding box */
  bounds: Vector3;
  /** Particle type for this system */
  particleType: ParticleType;
  /** Rendering mode */
  renderingMode: RenderingMode;
  /** Blending mode */
  blendingMode: BlendingMode;
  /** Enable physics simulation */
  enablePhysics: boolean;
  /** Enable collision detection */
  enableCollisions: boolean;
  /** System lifetime (-1 for infinite) */
  lifetime: number;
}

/**
 * Data required to create new particles
 */
export interface ParticleCreationData {
  /** Particle spawn position */
  position: Vector3;
  /** Initial velocity */
  velocity?: Vector3;
  /** Particle scale */
  scale?: Vector3;
  /** Particle color */
  color?: Color;
  /** Particle lifetime */
  lifetime?: number;
  /** Particle type */
  type?: ParticleType;
  /** Custom user data */
  userData?: Record<string, any>;
}

/**
 * Data for updating existing particles
 */
export interface ParticleUpdateData {
  /** Particle ID to update */
  id: string;
  /** New position */
  position?: Vector3;
  /** New velocity */
  velocity?: Vector3;
  /** New scale */
  scale?: Vector3;
  /** New color */
  color?: Color;
  /** New opacity */
  opacity?: number;
  /** Custom update data */
  userData?: Record<string, any>;
}

/**
 * Particle performance metrics
 */
export interface ParticleMetrics {
  /** Total particles across all systems */
  totalParticles: number;
  /** Number of active systems */
  activeSystems: number;
  /** Particles updated this frame */
  particlesUpdated: number;
  /** Particles rendered this frame */
  particlesRendered: number;
  /** Average update time (ms) */
  averageUpdateTime: number;
  /** Average render time (ms) */
  averageRenderTime: number;
  /** System memory usage (bytes) */
  memoryUsage: number;
  /** GPU memory usage (bytes) */
  gpuMemoryUsage: number;
  /** Object pool utilization (0-1) */
  poolUtilization: number;
}
'@

    Set-Content -Path (Join-Path $typesPath "particle.types.ts") -Value $typesContent -Encoding UTF8
    Write-SuccessLog "Particle types generated successfully"

    # Generate domain index file
    Write-InfoLog "Generating particle domain index"
    $indexContent = @'
/**
 * @fileoverview Particle Domain Export Index
 * @description Central export point for particle domain components
 * @author Protozoa Development Team
 * @version 1.0.0
 */

// Service exports
export { ParticleService } from "./services/ParticleService";

// Interface exports
export type { IParticleService, ParticleConfig, ParticleInstance, ParticleSystem } from "./interfaces/IParticleService";

// Type exports
export type {
  ParticleType,
  RenderingMode,
  BlendingMode,
  ParticleSystemConfig,
  ParticleCreationData,
  ParticleUpdateData,
  ParticleMetrics
} from "./types/particle.types";
'@

    Set-Content -Path (Join-Path $particleDomainPath "index.ts") -Value $indexContent -Encoding UTF8
    Write-SuccessLog "Particle domain index generated successfully"

    Write-SuccessLog "Particle Service generation completed successfully"
    Write-InfoLog "Generated files:"
    Write-InfoLog "  - IParticleService interface"
    Write-InfoLog "  - ParticleService implementation (from template)"
    Write-InfoLog "  - Particle type definitions"
    Write-InfoLog "  - Domain index file"

    return $true

} catch {
    Write-ErrorLog "Failed to generate Particle Service: $($_.Exception.Message)"
    Write-ErrorLog "Stack trace: $($_.ScriptStackTrace)"
    return $false
} 