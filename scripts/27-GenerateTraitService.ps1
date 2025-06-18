# 27-GenerateTraitService.ps1 - Phase 3 Data & Blockchain Integration
# Generates complete TraitService with Bitcoin block-seeded trait generation and mutation algorithms
# ARCHITECTURE: Singleton pattern with genetic inheritance and blockchain-influenced evolution
# Reference: script_checklist.md lines 27-GenerateTraitService.ps1
# Reference: build_design.md lines 600-800 - Trait service and mutation algorithms
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
    Write-StepHeader "Trait Service Generation - Phase 3 Data & Blockchain Integration"
    Write-InfoLog "Generating complete TraitService with Bitcoin block-seeded trait generation"

    # Define paths
    $traitDomainPath = Join-Path $ProjectRoot "src/domains/trait"
    $servicesPath = Join-Path $traitDomainPath "services"
    $typesPath = Join-Path $traitDomainPath "types"
    $interfacesPath = Join-Path $traitDomainPath "interfaces"
    $utilsPath = Join-Path $traitDomainPath "utils"

    # Ensure directories exist
    Write-InfoLog "Creating Trait domain directory structure"
    New-Item -Path $servicesPath -ItemType Directory -Force | Out-Null
    New-Item -Path $typesPath -ItemType Directory -Force | Out-Null
    New-Item -Path $interfacesPath -ItemType Directory -Force | Out-Null
    New-Item -Path $utilsPath -ItemType Directory -Force | Out-Null

    Write-SuccessLog "Trait domain directories created successfully"

    # Generate Trait service interface
    Write-InfoLog "Generating ITraitService interface"
    $interfaceContent = @'
/**
 * @fileoverview Trait Service Interface Definition
 * @description Defines the contract for organism trait management services
 * @author Protozoa Development Team
 * @version 1.0.0
 */

/**
 * Configuration options for Trait service initialization
 */
export interface TraitConfig {
  /** Enable Bitcoin block-based trait seeding */
  useBitcoinSeeding?: boolean;
  /** Base mutation rate (0-1) */
  baseMutationRate?: number;
  /** Enable genetic inheritance */
  enableInheritance?: boolean;
  /** Maximum trait variations */
  maxVariations?: number;
  /** Trait generation cache size */
  cacheSize?: number;
}

/**
 * Organism trait collection
 */
export interface OrganismTraits {
  /** Unique organism identifier */
  organismId: string;
  /** Parent organism IDs for inheritance */
  parentIds?: string[];
  /** Block number used for trait generation */
  blockNumber: number;
  /** Visual appearance traits */
  visual: VisualTraits;
  /** Behavioral pattern traits */
  behavioral: BehavioralTraits;
  /** Physical property traits */
  physical: PhysicalTraits;
  /** Evolutionary traits */
  evolutionary: EvolutionaryTraits;
  /** Generation timestamp */
  generatedAt: number;
  /** Mutation history */
  mutationHistory: MutationRecord[];
}

/**
 * Visual appearance traits
 */
export interface VisualTraits {
  /** Primary color (RGB hex) */
  primaryColor: string;
  /** Secondary color (RGB hex) */
  secondaryColor: string;
  /** Size multiplier (0.5-2.0) */
  size: number;
  /** Opacity (0.0-1.0) */
  opacity: number;
  /** Shape identifier */
  shape: string;
  /** Particle count multiplier */
  particleDensity: number;
  /** Glow intensity (0.0-1.0) */
  glowIntensity: number;
}

/**
 * Behavioral pattern traits
 */
export interface BehavioralTraits {
  /** Movement speed multiplier */
  speed: number;
  /** Aggression level (0.0-1.0) */
  aggression: number;
  /** Social tendency (0.0-1.0) */
  sociability: number;
  /** Exploration drive (0.0-1.0) */
  curiosity: number;
  /** Energy efficiency (0.0-1.0) */
  efficiency: number;
  /** Adaptation rate (0.0-1.0) */
  adaptability: number;
}

/**
 * Physical property traits
 */
export interface PhysicalTraits {
  /** Mass multiplier */
  mass: number;
  /** Collision radius multiplier */
  collisionRadius: number;
  /** Energy capacity multiplier */
  energyCapacity: number;
  /** Durability multiplier */
  durability: number;
  /** Regeneration rate */
  regeneration: number;
}

/**
 * Evolutionary traits
 */
export interface EvolutionaryTraits {
  /** Current generation number */
  generation: number;
  /** Fitness score */
  fitness: number;
  /** Mutation resistance (0.0-1.0) */
  stability: number;
  /** Reproductive success rate */
  reproductivity: number;
  /** Lifespan multiplier */
  longevity: number;
}

/**
 * Trait service interface defining organism trait management
 * Provides Bitcoin block-seeded trait generation and genetic inheritance
 */
export interface ITraitService {
  /**
   * Initialize the Trait service with configuration
   * @param config - Trait service configuration
   */
  initialize(config?: TraitConfig): Promise<void>;

  /**
   * Generate traits for a new organism from Bitcoin block data
   * @param blockNumber - Bitcoin block number for seeding
   * @param parentIds - Optional parent organism IDs for inheritance
   * @returns Promise resolving to generated traits
   */
  generateTraits(blockNumber: number, parentIds?: string[]): Promise<OrganismTraits>;

  /**
   * Mutate existing organism traits
   * @param traits - Current organism traits
   * @param mutationRate - Optional custom mutation rate
   * @returns Mutated traits
   */
  mutateTraits(traits: OrganismTraits, mutationRate?: number): OrganismTraits;

  /**
   * Get trait generation statistics
   * @returns Trait service metrics
   */
  getMetrics(): TraitMetrics;

  /**
   * Dispose of resources and cleanup
   */
  dispose(): void;
}
'@

    Set-Content -Path (Join-Path $interfacesPath "ITraitService.ts") -Value $interfaceContent -Encoding UTF8
    Write-SuccessLog "ITraitService interface generated successfully"

    # Generate Trait types
    Write-InfoLog "Generating Trait types definitions"
    $typesContent = @'
/**
 * @fileoverview Trait Types Definition
 * @description Type definitions for organism trait management domain
 * @author Protozoa Development Team
 * @version 1.0.0
 */

/**
 * Trait categories
 */
export type TraitCategory = "visual" | "behavioral" | "physical" | "evolutionary";

/**
 * Trait data types
 */
export type TraitType = "number" | "string" | "boolean" | "color" | "enum";

/**
 * Mutation record for tracking trait changes
 */
export interface MutationRecord {
  /** Mutation timestamp */
  timestamp: number;
  /** Block number that triggered mutation */
  blockNumber: number;
  /** Trait category that mutated */
  category: TraitCategory;
  /** Specific trait that changed */
  traitName: string;
  /** Previous value */
  previousValue: any;
  /** New value */
  newValue: any;
  /** Mutation strength (0.0-1.0) */
  mutationStrength: number;
}

/**
 * Trait validation result
 */
export interface TraitValidation {
  /** Whether traits are valid */
  isValid: boolean;
  /** Validation errors if any */
  errors: string[];
  /** Warnings for unusual values */
  warnings: string[];
}

/**
 * Trait generation parameters
 */
export interface TraitGenerationParams {
  /** Bitcoin block number for seeding */
  blockNumber: number;
  /** Parent organism traits for inheritance */
  parentTraits?: OrganismTraits[];
  /** Custom mutation rate override */
  mutationRate?: number;
  /** Generation type */
  generationType: GenerationType;
}

/**
 * Generation type
 */
export type GenerationType = "genesis" | "inheritance" | "mutation" | "crossover";

/**
 * Trait service performance metrics
 */
export interface TraitMetrics {
  /** Total traits generated */
  totalGenerated: number;
  /** Total mutations performed */
  totalMutations: number;
  /** Average generation time in milliseconds */
  averageGenerationTime: number;
  /** Cache hit rate percentage */
  cacheHitRate: number;
  /** Unique block numbers used */
  uniqueBlocks: number;
  /** Generation distribution by type */
  generationTypes: Record<GenerationType, number>;
}

/**
 * Color utility type for RGB values
 */
export interface RGBColor {
  /** Red component (0-255) */
  r: number;
  /** Green component (0-255) */
  g: number;
  /** Blue component (0-255) */
  b: number;
}

/**
 * Trait range definition
 */
export interface TraitRange {
  /** Minimum value */
  min: number;
  /** Maximum value */
  max: number;
  /** Default value */
  default: number;
}

/**
 * Genetic inheritance weights
 */
export interface InheritanceWeights {
  /** Parent 1 influence (0.0-1.0) */
  parent1Weight: number;
  /** Parent 2 influence (0.0-1.0) */
  parent2Weight: number;
  /** Random mutation influence (0.0-1.0) */
  mutationWeight: number;
  /** Block data influence (0.0-1.0) */
  blockWeight: number;
}
'@

    Set-Content -Path (Join-Path $typesPath "trait.types.ts") -Value $typesContent -Encoding UTF8
    Write-SuccessLog "Trait types generated successfully"

    # Generate Trait Service implementation - Part 1 (Class structure)
    Write-InfoLog "Generating TraitService implementation - Part 1 (Core structure)"
    $serviceContent1 = @'
/**
 * @fileoverview Trait Service Implementation
 * @description High-performance organism trait generation with Bitcoin block seeding and genetic algorithms
 * @author Protozoa Development Team
 * @version 1.0.0
 */

import {
  ITraitService,
  TraitConfig,
  OrganismTraits,
  VisualTraits,
  BehavioralTraits,
  PhysicalTraits,
  EvolutionaryTraits,
  TraitMetrics
} from "@/domains/trait/interfaces/ITraitService";
import {
  TraitCategory,
  TraitType,
  MutationRecord,
  TraitValidation,
  TraitGenerationParams,
  GenerationType,
  RGBColor,
  TraitRange,
  InheritanceWeights
} from "@/domains/trait/types/trait.types";
import { createServiceLogger } from "@/shared/lib/logger";

/**
 * Trait Service implementing advanced organism trait generation and evolution
 * Uses Bitcoin block data for deterministic yet unique trait generation
 * Follows singleton pattern for application-wide consistency
 */
export class TraitService implements ITraitService {
  /** Singleton instance */
  static #instance: TraitService | null = null;

  /** Service configuration */
  #config: TraitConfig;

  /** Performance metrics */
  #metrics: TraitMetrics;

  /** Winston logger instance */
  #logger = createServiceLogger("TraitService");

  /** Generated traits cache */
  #traitsCache: Map<string, OrganismTraits>;

  /** Trait range definitions */
  #traitRanges: Map<string, TraitRange>;

  /** Shape options for visual traits */
  #availableShapes: string[];

  /**
   * Private constructor enforcing singleton pattern
   * Initializes trait service with genetic algorithms
   */
  private constructor() {
    this.#logger.info("Initializing TraitService singleton instance");

    // Initialize default configuration
    this.#config = {
      useBitcoinSeeding: true,
      baseMutationRate: 0.1,
      enableInheritance: true,
      maxVariations: 1000,
      cacheSize: 500
    };

    // Initialize performance metrics
    this.#metrics = {
      totalGenerated: 0,
      totalMutations: 0,
      averageGenerationTime: 0,
      cacheHitRate: 0,
      uniqueBlocks: 0,
      generationTypes: {
        genesis: 0,
        inheritance: 0,
        mutation: 0,
        crossover: 0
      }
    };

    // Initialize collections
    this.#traitsCache = new Map();
    this.#traitRanges = new Map();
    this.#availableShapes = ["circle", "square", "triangle", "hexagon", "star", "diamond"];

    // Initialize trait ranges
    this.#initializeTraitRanges();

    this.#logger.info("TraitService initialized successfully", {
      useBitcoinSeeding: this.#config.useBitcoinSeeding,
      baseMutationRate: this.#config.baseMutationRate
    });
  }

  /**
   * Get singleton instance of TraitService
   * Creates new instance if none exists
   * @returns TraitService singleton instance
   */
  public static getInstance(): TraitService {
    if (!TraitService.#instance) {
      TraitService.#instance = new TraitService();
    }
    return TraitService.#instance;
  }
}
'@

    Set-Content -Path (Join-Path $servicesPath "traitService.ts") -Value $serviceContent1 -Encoding UTF8
    Write-SuccessLog "TraitService implementation Part 1 generated successfully"

    # Generate Trait Service implementation - Part 2 (Core methods)
    Write-InfoLog "Generating TraitService implementation - Part 2 (Core methods)"
    $serviceContent2 = @'
/**
 * @fileoverview Trait Service Implementation
 * @description High-performance organism trait generation with Bitcoin block seeding and genetic algorithms
 * @author Protozoa Development Team
 * @version 1.0.0
 */

import {
  ITraitService,
  TraitConfig,
  OrganismTraits,
  VisualTraits,
  BehavioralTraits,
  PhysicalTraits,
  EvolutionaryTraits,
  TraitMetrics
} from "@/domains/trait/interfaces/ITraitService";
import {
  TraitCategory,
  TraitType,
  MutationRecord,
  TraitValidation,
  TraitGenerationParams,
  GenerationType,
  RGBColor,
  TraitRange,
  InheritanceWeights
} from "@/domains/trait/types/trait.types";
import { createServiceLogger } from "@/shared/lib/logger";

/**
 * Trait Service implementing advanced organism trait generation and evolution
 * Uses Bitcoin block data for deterministic yet unique trait generation
 * Follows singleton pattern for application-wide consistency
 */
export class TraitService implements ITraitService {
  /** Singleton instance */
  static #instance: TraitService | null = null;

  /** Service configuration */
  #config: TraitConfig;

  /** Performance metrics */
  #metrics: TraitMetrics;

  /** Winston logger instance */
  #logger = createServiceLogger("TraitService");

  /** Generated traits cache */
  #traitsCache: Map<string, OrganismTraits>;

  /** Trait range definitions */
  #traitRanges: Map<string, TraitRange>;

  /** Shape options for visual traits */
  #availableShapes: string[];

  /**
   * Private constructor enforcing singleton pattern
   * Initializes trait service with genetic algorithms
   */
  private constructor() {
    this.#logger.info("Initializing TraitService singleton instance");

    // Initialize default configuration
    this.#config = {
      useBitcoinSeeding: true,
      baseMutationRate: 0.1,
      enableInheritance: true,
      maxVariations: 1000,
      cacheSize: 500
    };

    // Initialize performance metrics
    this.#metrics = {
      totalGenerated: 0,
      totalMutations: 0,
      averageGenerationTime: 0,
      cacheHitRate: 0,
      uniqueBlocks: 0,
      generationTypes: {
        genesis: 0,
        inheritance: 0,
        mutation: 0,
        crossover: 0
      }
    };

    // Initialize collections
    this.#traitsCache = new Map();
    this.#traitRanges = new Map();
    this.#availableShapes = ["circle", "square", "triangle", "hexagon", "star", "diamond"];

    // Initialize trait ranges
    this.#initializeTraitRanges();

    this.#logger.info("TraitService initialized successfully", {
      useBitcoinSeeding: this.#config.useBitcoinSeeding,
      baseMutationRate: this.#config.baseMutationRate
    });
  }

  /**
   * Get singleton instance of TraitService
   * Creates new instance if none exists
   * @returns TraitService singleton instance
   */
  public static getInstance(): TraitService {
    if (!TraitService.#instance) {
      TraitService.#instance = new TraitService();
    }
    return TraitService.#instance;
  }

  /**
   * Initialize the Trait service with configuration
   * @param config - Optional trait configuration
   */
  public async initialize(config?: TraitConfig): Promise<void> {
    this.#logger.info("Initializing TraitService with configuration", { config });

    if (config) {
      this.#config = { ...this.#config, ...config };
    }

    this.#logger.info("TraitService initialization completed");
  }

  /**
   * Generate traits for a new organism from Bitcoin block data
   * @param blockNumber - Bitcoin block number for seeding
   * @param parentIds - Optional parent organism IDs for inheritance
   * @returns Promise resolving to generated traits
   */
  public async generateTraits(blockNumber: number, parentIds?: string[]): Promise<OrganismTraits> {
    const startTime = performance.now();
    this.#logger.info("Generating organism traits", { blockNumber, parentIds });

    // Check cache first
    const cacheKey = `${blockNumber}_${parentIds?.join(",") || "genesis"}`;
    const cached = this.#traitsCache.get(cacheKey);
    if (cached) {
      this.#updateCacheHitRate(true);
      return { ...cached, organismId: this.#generateOrganismId(blockNumber) };
    }

    try {
      const generationType: GenerationType = parentIds?.length ? "inheritance" : "genesis";

      // Generate organism ID
      const organismId = this.#generateOrganismId(blockNumber);

      // Generate visual traits
      const visual = this.#generateVisualTraits(blockNumber);

      // Generate behavioral traits
      const behavioral = this.#generateBehavioralTraits(blockNumber);

      // Generate physical traits
      const physical = this.#generatePhysicalTraits(blockNumber);

      // Generate evolutionary traits
      const evolutionary = this.#generateEvolutionaryTraits(blockNumber, generationType);

      const traits: OrganismTraits = {
        organismId,
        parentIds,
        blockNumber,
        visual,
        behavioral,
        physical,
        evolutionary,
        generatedAt: Date.now(),
        mutationHistory: []
      };

      // Cache the result
      this.#traitsCache.set(cacheKey, traits);

      // Update metrics
      this.#updateMetrics(startTime, generationType);
      this.#updateCacheHitRate(false);

      this.#logger.info("Organism traits generated successfully", {
        organismId,
        blockNumber,
        generationType
      });

      return traits;
    } catch (error) {
      this.#logger.error("Failed to generate organism traits", { blockNumber, error });
      throw error;
    }
  }

  /**
   * Mutate existing organism traits
   * @param traits - Current organism traits
   * @param mutationRate - Optional custom mutation rate
   * @returns Mutated traits
   */
  public mutateTraits(traits: OrganismTraits, mutationRate?: number): OrganismTraits {
    const startTime = performance.now();
    const rate = mutationRate || this.#config.baseMutationRate!;

    this.#logger.info("Mutating organism traits", {
      organismId: traits.organismId,
      mutationRate: rate
    });

    const mutatedTraits: OrganismTraits = JSON.parse(JSON.stringify(traits));
    const mutations: MutationRecord[] = [];

    // Mutate visual traits
    this.#mutateVisualTraits(mutatedTraits.visual, rate, mutations);

    // Mutate behavioral traits
    this.#mutateBehavioralTraits(mutatedTraits.behavioral, rate, mutations);

    // Mutate physical traits
    this.#mutatePhysicalTraits(mutatedTraits.physical, rate, mutations);

    // Mutate evolutionary traits
    this.#mutateEvolutionaryTraits(mutatedTraits.evolutionary, rate, mutations);

    // Update mutation history
    mutatedTraits.mutationHistory.push(...mutations);

    // Update metrics
    this.#metrics.totalMutations++;
    this.#updateMetrics(startTime, "mutation");

    this.#logger.info("Organism traits mutated successfully", {
      organismId: traits.organismId,
      mutationsApplied: mutations.length
    });

    return mutatedTraits;
  }

  /**
   * Get trait generation statistics
   * @returns Trait service metrics
   */
  public getMetrics(): TraitMetrics {
    return { ...this.#metrics };
  }

  /**
   * Dispose of resources and cleanup
   */
  public dispose(): void {
    this.#logger.info("Disposing TraitService resources");

    this.#traitsCache.clear();
    this.#traitRanges.clear();

    // Reset singleton instance
    TraitService.#instance = null;

    this.#logger.info("TraitService disposal completed");
  }

  // Private helper methods

  /**
   * Initialize trait range definitions
   */
  #initializeTraitRanges(): void {
    // Visual trait ranges
    this.#traitRanges.set("size", { min: 0.5, max: 2.0, default: 1.0 });
    this.#traitRanges.set("opacity", { min: 0.3, max: 1.0, default: 0.8 });
    this.#traitRanges.set("particleDensity", { min: 0.5, max: 3.0, default: 1.0 });
    this.#traitRanges.set("glowIntensity", { min: 0.0, max: 1.0, default: 0.3 });

    // Behavioral trait ranges
    this.#traitRanges.set("speed", { min: 0.5, max: 2.0, default: 1.0 });
    this.#traitRanges.set("aggression", { min: 0.0, max: 1.0, default: 0.5 });
    this.#traitRanges.set("sociability", { min: 0.0, max: 1.0, default: 0.5 });
    this.#traitRanges.set("curiosity", { min: 0.0, max: 1.0, default: 0.5 });
    this.#traitRanges.set("efficiency", { min: 0.3, max: 1.0, default: 0.7 });
    this.#traitRanges.set("adaptability", { min: 0.0, max: 1.0, default: 0.5 });

    // Physical trait ranges
    this.#traitRanges.set("mass", { min: 0.5, max: 2.0, default: 1.0 });
    this.#traitRanges.set("collisionRadius", { min: 0.7, max: 1.5, default: 1.0 });
    this.#traitRanges.set("energyCapacity", { min: 0.5, max: 2.0, default: 1.0 });
    this.#traitRanges.set("durability", { min: 0.5, max: 2.0, default: 1.0 });
    this.#traitRanges.set("regeneration", { min: 0.1, max: 1.0, default: 0.3 });

    // Evolutionary trait ranges
    this.#traitRanges.set("fitness", { min: 0.0, max: 100.0, default: 50.0 });
    this.#traitRanges.set("stability", { min: 0.0, max: 1.0, default: 0.5 });
    this.#traitRanges.set("reproductivity", { min: 0.0, max: 1.0, default: 0.5 });
    this.#traitRanges.set("longevity", { min: 0.5, max: 2.0, default: 1.0 });
  }

  /**
   * Generate unique organism ID based on block number
   * @param blockNumber - Bitcoin block number
   * @returns Unique organism ID
   */
  #generateOrganismId(blockNumber: number): string {
    const timestamp = Date.now();
    const hash = ((blockNumber * 37) + timestamp) % 1000000;
    return `org_${blockNumber}_${hash}`;
  }

  /**
   * Generate visual traits from block data
   * @param blockNumber - Bitcoin block number for seeding
   * @returns Generated visual traits
   */
  #generateVisualTraits(blockNumber: number): VisualTraits {
    const hash = this.#hashBlock(blockNumber);

    return {
      primaryColor: this.#generateColor(hash, 0),
      secondaryColor: this.#generateColor(hash, 1),
      size: this.#generateTraitValue("size", hash, 2),
      opacity: this.#generateTraitValue("opacity", hash, 3),
      shape: this.#availableShapes[hash[4] % this.#availableShapes.length],
      particleDensity: this.#generateTraitValue("particleDensity", hash, 5),
      glowIntensity: this.#generateTraitValue("glowIntensity", hash, 6)
    };
  }

  /**
   * Generate behavioral traits from block data
   * @param blockNumber - Bitcoin block number for seeding
   * @returns Generated behavioral traits
   */
  #generateBehavioralTraits(blockNumber: number): BehavioralTraits {
    const hash = this.#hashBlock(blockNumber + 1);

    return {
      speed: this.#generateTraitValue("speed", hash, 0),
      aggression: this.#generateTraitValue("aggression", hash, 1),
      sociability: this.#generateTraitValue("sociability", hash, 2),
      curiosity: this.#generateTraitValue("curiosity", hash, 3),
      efficiency: this.#generateTraitValue("efficiency", hash, 4),
      adaptability: this.#generateTraitValue("adaptability", hash, 5)
    };
  }

  /**
   * Generate physical traits from block data
   * @param blockNumber - Bitcoin block number for seeding
   * @returns Generated physical traits
   */
  #generatePhysicalTraits(blockNumber: number): PhysicalTraits {
    const hash = this.#hashBlock(blockNumber + 2);

    return {
      mass: this.#generateTraitValue("mass", hash, 0),
      collisionRadius: this.#generateTraitValue("collisionRadius", hash, 1),
      energyCapacity: this.#generateTraitValue("energyCapacity", hash, 2),
      durability: this.#generateTraitValue("durability", hash, 3),
      regeneration: this.#generateTraitValue("regeneration", hash, 4)
    };
  }

  /**
   * Generate evolutionary traits from block data
   * @param blockNumber - Bitcoin block number for seeding
   * @param generationType - Type of generation
   * @returns Generated evolutionary traits
   */
  #generateEvolutionaryTraits(blockNumber: number, generationType: GenerationType): EvolutionaryTraits {
    const hash = this.#hashBlock(blockNumber + 3);

    return {
      generation: generationType === "genesis" ? 0 : 1,
      fitness: this.#generateTraitValue("fitness", hash, 0),
      stability: this.#generateTraitValue("stability", hash, 1),
      reproductivity: this.#generateTraitValue("reproductivity", hash, 2),
      longevity: this.#generateTraitValue("longevity", hash, 3)
    };
  }

  /**
   * Generate color from hash values
   * @param hash - Hash array
   * @param offset - Offset in hash array
   * @returns RGB color hex string
   */
  #generateColor(hash: number[], offset: number): string {
    const r = hash[offset % hash.length] % 256;
    const g = hash[(offset + 1) % hash.length] % 256;
    const b = hash[(offset + 2) % hash.length] % 256;

    return `#${r.toString(16).padStart(2, "0")}${g.toString(16).padStart(2, "0")}${b.toString(16).padStart(2, "0")}`;
  }

  /**
   * Generate trait value within defined range
   * @param traitName - Name of the trait
   * @param hash - Hash array for randomization
   * @param offset - Offset in hash array
   * @returns Generated trait value
   */
  #generateTraitValue(traitName: string, hash: number[], offset: number): number {
    const range = this.#traitRanges.get(traitName);
    if (!range) return 1.0;

    const normalizedValue = (hash[offset % hash.length] % 1000) / 1000;
    return range.min + (normalizedValue * (range.max - range.min));
  }

  /**
   * Hash block number to array of values
   * @param blockNumber - Bitcoin block number
   * @returns Array of hash values
   */
  #hashBlock(blockNumber: number): number[] {
    const hash: number[] = [];
    let n = blockNumber;

    for (let i = 0; i < 8; i++) {
      n = ((n >> 16) ^ n) * 0x45d9f3b;
      n = ((n >> 16) ^ n) * 0x45d9f3b;
      n = (n >> 16) ^ n;
      hash.push(Math.abs(n));
    }

    return hash;
  }

  /**
   * Mutate visual traits
   * @param visual - Visual traits to mutate
   * @param rate - Mutation rate
   * @param mutations - Mutation records array
   */
  #mutateVisualTraits(visual: VisualTraits, rate: number, mutations: MutationRecord[]): void {
    if (Math.random() < rate) {
      const oldSize = visual.size;
      visual.size = this.#mutateNumericTrait(visual.size, "size", 0.1);
      mutations.push(this.#createMutationRecord("visual", "size", oldSize, visual.size, rate));
    }

    if (Math.random() < rate) {
      const oldOpacity = visual.opacity;
      visual.opacity = this.#mutateNumericTrait(visual.opacity, "opacity", 0.05);
      mutations.push(this.#createMutationRecord("visual", "opacity", oldOpacity, visual.opacity, rate));
    }
  }

  /**
   * Mutate behavioral traits
   * @param behavioral - Behavioral traits to mutate
   * @param rate - Mutation rate
   * @param mutations - Mutation records array
   */
  #mutateBehavioralTraits(behavioral: BehavioralTraits, rate: number, mutations: MutationRecord[]): void {
    if (Math.random() < rate) {
      const oldSpeed = behavioral.speed;
      behavioral.speed = this.#mutateNumericTrait(behavioral.speed, "speed", 0.1);
      mutations.push(this.#createMutationRecord("behavioral", "speed", oldSpeed, behavioral.speed, rate));
    }
  }

  /**
   * Mutate physical traits
   * @param physical - Physical traits to mutate
   * @param rate - Mutation rate
   * @param mutations - Mutation records array
   */
  #mutatePhysicalTraits(physical: PhysicalTraits, rate: number, mutations: MutationRecord[]): void {
    if (Math.random() < rate) {
      const oldMass = physical.mass;
      physical.mass = this.#mutateNumericTrait(physical.mass, "mass", 0.1);
      mutations.push(this.#createMutationRecord("physical", "mass", oldMass, physical.mass, rate));
    }
  }

  /**
   * Mutate evolutionary traits
   * @param evolutionary - Evolutionary traits to mutate
   * @param rate - Mutation rate
   * @param mutations - Mutation records array
   */
  #mutateEvolutionaryTraits(evolutionary: EvolutionaryTraits, rate: number, mutations: MutationRecord[]): void {
    evolutionary.generation++;

    if (Math.random() < rate) {
      const oldFitness = evolutionary.fitness;
      evolutionary.fitness = this.#mutateNumericTrait(evolutionary.fitness, "fitness", 5.0);
      mutations.push(this.#createMutationRecord("evolutionary", "fitness", oldFitness, evolutionary.fitness, rate));
    }
  }

  /**
   * Mutate numeric trait within bounds
   * @param currentValue - Current trait value
   * @param traitName - Name of the trait
   * @param variance - Mutation variance
   * @returns Mutated value
   */
  #mutateNumericTrait(currentValue: number, traitName: string, variance: number): number {
    const range = this.#traitRanges.get(traitName);
    if (!range) return currentValue;

    const mutation = (Math.random() - 0.5) * variance * 2;
    const newValue = currentValue + mutation;

    return Math.max(range.min, Math.min(range.max, newValue));
  }

  /**
   * Create mutation record
   * @param category - Trait category
   * @param traitName - Trait name
   * @param oldValue - Previous value
   * @param newValue - New value
   * @param strength - Mutation strength
   * @returns Mutation record
   */
  #createMutationRecord(category: TraitCategory, traitName: string, oldValue: any, newValue: any, strength: number): MutationRecord {
    return {
      timestamp: Date.now(),
      blockNumber: 0, // Will be set by caller
      category,
      traitName,
      previousValue: oldValue,
      newValue,
      mutationStrength: strength
    };
  }

  /**
   * Update performance metrics
   * @param startTime - Operation start time
   * @param generationType - Type of generation performed
   */
  #updateMetrics(startTime: number, generationType: GenerationType): void {
    const duration = performance.now() - startTime;

    this.#metrics.totalGenerated++;
    this.#metrics.generationTypes[generationType]++;

    // Update average generation time
    const total = this.#metrics.totalGenerated;
    this.#metrics.averageGenerationTime =
      ((this.#metrics.averageGenerationTime * (total - 1)) + duration) / total;
  }

  /**
   * Update cache hit rate
   * @param hit - Whether this was a cache hit
   */
  #updateCacheHitRate(hit: boolean): void {
    // Simple cache hit rate calculation
    const totalOperations = this.#metrics.totalGenerated + 1;
    if (hit) {
      this.#metrics.cacheHitRate = ((this.#metrics.cacheHitRate * (totalOperations - 1)) + 100) / totalOperations;
    } else {
      this.#metrics.cacheHitRate = (this.#metrics.cacheHitRate * (totalOperations - 1)) / totalOperations;
    }
  }
}
'@

    # Append Part 2 to the service file
    Add-Content -Path (Join-Path $servicesPath "traitService.ts") -Value $serviceContent2 -Encoding UTF8
    Write-SuccessLog "TraitService implementation Part 2 generated successfully"

    # Generate Trait Service implementation - Part 3 (Helper methods and completion)
    Write-InfoLog "Generating TraitService implementation - Part 3 (Helper methods and completion)"
    $serviceContent3 = @'
/**
 * @fileoverview Trait Service Implementation
 * @description High-performance organism trait generation with Bitcoin block seeding and genetic algorithms
 * @author Protozoa Development Team
 * @version 1.0.0
 */

import {
  ITraitService,
  TraitConfig,
  OrganismTraits,
  VisualTraits,
  BehavioralTraits,
  PhysicalTraits,
  EvolutionaryTraits,
  TraitMetrics
} from "@/domains/trait/interfaces/ITraitService";
import {
  TraitCategory,
  TraitType,
  MutationRecord,
  TraitValidation,
  TraitGenerationParams,
  GenerationType,
  RGBColor,
  TraitRange,
  InheritanceWeights
} from "@/domains/trait/types/trait.types";
import { createServiceLogger } from "@/shared/lib/logger";

/**
 * Trait Service implementing advanced organism trait generation and evolution
 * Uses Bitcoin block data for deterministic yet unique trait generation
 * Follows singleton pattern for application-wide consistency
 */
export class TraitService implements ITraitService {
  /** Singleton instance */
  static #instance: TraitService | null = null;

  /** Service configuration */
  #config: TraitConfig;

  /** Performance metrics */
  #metrics: TraitMetrics;

  /** Winston logger instance */
  #logger = createServiceLogger("TraitService");

  /** Generated traits cache */
  #traitsCache: Map<string, OrganismTraits>;

  /** Trait range definitions */
  #traitRanges: Map<string, TraitRange>;

  /** Shape options for visual traits */
  #availableShapes: string[];

  /**
   * Private constructor enforcing singleton pattern
   * Initializes trait service with genetic algorithms
   */
  private constructor() {
    this.#logger.info("Initializing TraitService singleton instance");

    // Initialize default configuration
    this.#config = {
      useBitcoinSeeding: true,
      baseMutationRate: 0.1,
      enableInheritance: true,
      maxVariations: 1000,
      cacheSize: 500
    };

    // Initialize performance metrics
    this.#metrics = {
      totalGenerated: 0,
      totalMutations: 0,
      averageGenerationTime: 0,
      cacheHitRate: 0,
      uniqueBlocks: 0,
      generationTypes: {
        genesis: 0,
        inheritance: 0,
        mutation: 0,
        crossover: 0
      }
    };

    // Initialize collections
    this.#traitsCache = new Map();
    this.#traitRanges = new Map();
    this.#availableShapes = ["circle", "square", "triangle", "hexagon", "star", "diamond"];

    // Initialize trait ranges
    this.#initializeTraitRanges();

    this.#logger.info("TraitService initialized successfully", {
      useBitcoinSeeding: this.#config.useBitcoinSeeding,
      baseMutationRate: this.#config.baseMutationRate
    });
  }

  /**
   * Get singleton instance of TraitService
   * Creates new instance if none exists
   * @returns TraitService singleton instance
   */
  public static getInstance(): TraitService {
    if (!TraitService.#instance) {
      TraitService.#instance = new TraitService();
    }
    return TraitService.#instance;
  }

  /**
   * Initialize the Trait service with configuration
   * @param config - Optional trait configuration
   */
  public async initialize(config?: TraitConfig): Promise<void> {
    this.#logger.info("Initializing TraitService with configuration", { config });

    if (config) {
      this.#config = { ...this.#config, ...config };
    }

    this.#logger.info("TraitService initialization completed");
  }

  /**
   * Generate traits for a new organism from Bitcoin block data
   * @param blockNumber - Bitcoin block number for seeding
   * @param parentIds - Optional parent organism IDs for inheritance
   * @returns Promise resolving to generated traits
   */
  public async generateTraits(blockNumber: number, parentIds?: string[]): Promise<OrganismTraits> {
    const startTime = performance.now();
    this.#logger.info("Generating organism traits", { blockNumber, parentIds });

    // Check cache first
    const cacheKey = `${blockNumber}_${parentIds?.join(",") || "genesis"}`;
    const cached = this.#traitsCache.get(cacheKey);
    if (cached) {
      this.#updateCacheHitRate(true);
      return { ...cached, organismId: this.#generateOrganismId(blockNumber) };
    }

    try {
      const generationType: GenerationType = parentIds?.length ? "inheritance" : "genesis";

      // Generate organism ID
      const organismId = this.#generateOrganismId(blockNumber);

      // Generate visual traits
      const visual = this.#generateVisualTraits(blockNumber);

      // Generate behavioral traits
      const behavioral = this.#generateBehavioralTraits(blockNumber);

      // Generate physical traits
      const physical = this.#generatePhysicalTraits(blockNumber);

      // Generate evolutionary traits
      const evolutionary = this.#generateEvolutionaryTraits(blockNumber, generationType);

      const traits: OrganismTraits = {
        organismId,
        parentIds,
        blockNumber,
        visual,
        behavioral,
        physical,
        evolutionary,
        generatedAt: Date.now(),
        mutationHistory: []
      };

      // Cache the result
      this.#traitsCache.set(cacheKey, traits);

      // Update metrics
      this.#updateMetrics(startTime, generationType);
      this.#updateCacheHitRate(false);

      this.#logger.info("Organism traits generated successfully", {
        organismId,
        blockNumber,
        generationType
      });

      return traits;
    } catch (error) {
      this.#logger.error("Failed to generate organism traits", { blockNumber, error });
      throw error;
    }
  }

  /**
   * Mutate existing organism traits
   * @param traits - Current organism traits
   * @param mutationRate - Optional custom mutation rate
   * @returns Mutated traits
   */
  public mutateTraits(traits: OrganismTraits, mutationRate?: number): OrganismTraits {
    const startTime = performance.now();
    const rate = mutationRate || this.#config.baseMutationRate!;

    this.#logger.info("Mutating organism traits", {
      organismId: traits.organismId,
      mutationRate: rate
    });

    const mutatedTraits: OrganismTraits = JSON.parse(JSON.stringify(traits));
    const mutations: MutationRecord[] = [];

    // Mutate visual traits
    this.#mutateVisualTraits(mutatedTraits.visual, rate, mutations);

    // Mutate behavioral traits
    this.#mutateBehavioralTraits(mutatedTraits.behavioral, rate, mutations);

    // Mutate physical traits
    this.#mutatePhysicalTraits(mutatedTraits.physical, rate, mutations);

    // Mutate evolutionary traits
    this.#mutateEvolutionaryTraits(mutatedTraits.evolutionary, rate, mutations);

    // Update mutation history
    mutatedTraits.mutationHistory.push(...mutations);

    // Update metrics
    this.#metrics.totalMutations++;
    this.#updateMetrics(startTime, "mutation");

    this.#logger.info("Organism traits mutated successfully", {
      organismId: traits.organismId,
      mutationsApplied: mutations.length
    });

    return mutatedTraits;
  }

  /**
   * Get trait generation statistics
   * @returns Trait service metrics
   */
  public getMetrics(): TraitMetrics {
    return { ...this.#metrics };
  }

  /**
   * Dispose of resources and cleanup
   */
  public dispose(): void {
    this.#logger.info("Disposing TraitService resources");

    this.#traitsCache.clear();
    this.#traitRanges.clear();

    // Reset singleton instance
    TraitService.#instance = null;

    this.#logger.info("TraitService disposal completed");
  }

  // Private helper methods

  /**
   * Initialize trait range definitions
   */
  #initializeTraitRanges(): void {
    // Visual trait ranges
    this.#traitRanges.set("size", { min: 0.5, max: 2.0, default: 1.0 });
    this.#traitRanges.set("opacity", { min: 0.3, max: 1.0, default: 0.8 });
    this.#traitRanges.set("particleDensity", { min: 0.5, max: 3.0, default: 1.0 });
    this.#traitRanges.set("glowIntensity", { min: 0.0, max: 1.0, default: 0.3 });

    // Behavioral trait ranges
    this.#traitRanges.set("speed", { min: 0.5, max: 2.0, default: 1.0 });
    this.#traitRanges.set("aggression", { min: 0.0, max: 1.0, default: 0.5 });
    this.#traitRanges.set("sociability", { min: 0.0, max: 1.0, default: 0.5 });
    this.#traitRanges.set("curiosity", { min: 0.0, max: 1.0, default: 0.5 });
    this.#traitRanges.set("efficiency", { min: 0.3, max: 1.0, default: 0.7 });
    this.#traitRanges.set("adaptability", { min: 0.0, max: 1.0, default: 0.5 });

    // Physical trait ranges
    this.#traitRanges.set("mass", { min: 0.5, max: 2.0, default: 1.0 });
    this.#traitRanges.set("collisionRadius", { min: 0.7, max: 1.5, default: 1.0 });
    this.#traitRanges.set("energyCapacity", { min: 0.5, max: 2.0, default: 1.0 });
    this.#traitRanges.set("durability", { min: 0.5, max: 2.0, default: 1.0 });
    this.#traitRanges.set("regeneration", { min: 0.1, max: 1.0, default: 0.3 });

    // Evolutionary trait ranges
    this.#traitRanges.set("fitness", { min: 0.0, max: 100.0, default: 50.0 });
    this.#traitRanges.set("stability", { min: 0.0, max: 1.0, default: 0.5 });
    this.#traitRanges.set("reproductivity", { min: 0.0, max: 1.0, default: 0.5 });
    this.#traitRanges.set("longevity", { min: 0.5, max: 2.0, default: 1.0 });
  }

  /**
   * Generate unique organism ID based on block number
   * @param blockNumber - Bitcoin block number
   * @returns Unique organism ID
   */
  #generateOrganismId(blockNumber: number): string {
    const timestamp = Date.now();
    const hash = ((blockNumber * 37) + timestamp) % 1000000;
    return `org_${blockNumber}_${hash}`;
  }

  /**
   * Generate visual traits from block data
   * @param blockNumber - Bitcoin block number for seeding
   * @returns Generated visual traits
   */
  #generateVisualTraits(blockNumber: number): VisualTraits {
    const hash = this.#hashBlock(blockNumber);

    return {
      primaryColor: this.#generateColor(hash, 0),
      secondaryColor: this.#generateColor(hash, 1),
      size: this.#generateTraitValue("size", hash, 2),
      opacity: this.#generateTraitValue("opacity", hash, 3),
      shape: this.#availableShapes[hash[4] % this.#availableShapes.length],
      particleDensity: this.#generateTraitValue("particleDensity", hash, 5),
      glowIntensity: this.#generateTraitValue("glowIntensity", hash, 6)
    };
  }

  /**
   * Generate behavioral traits from block data
   * @param blockNumber - Bitcoin block number for seeding
   * @returns Generated behavioral traits
   */
  #generateBehavioralTraits(blockNumber: number): BehavioralTraits {
    const hash = this.#hashBlock(blockNumber + 1);

    return {
      speed: this.#generateTraitValue("speed", hash, 0),
      aggression: this.#generateTraitValue("aggression", hash, 1),
      sociability: this.#generateTraitValue("sociability", hash, 2),
      curiosity: this.#generateTraitValue("curiosity", hash, 3),
      efficiency: this.#generateTraitValue("efficiency", hash, 4),
      adaptability: this.#generateTraitValue("adaptability", hash, 5)
    };
  }

  /**
   * Generate physical traits from block data
   * @param blockNumber - Bitcoin block number for seeding
   * @returns Generated physical traits
   */
  #generatePhysicalTraits(blockNumber: number): PhysicalTraits {
    const hash = this.#hashBlock(blockNumber + 2);

    return {
      mass: this.#generateTraitValue("mass", hash, 0),
      collisionRadius: this.#generateTraitValue("collisionRadius", hash, 1),
      energyCapacity: this.#generateTraitValue("energyCapacity", hash, 2),
      durability: this.#generateTraitValue("durability", hash, 3),
      regeneration: this.#generateTraitValue("regeneration", hash, 4)
    };
  }

  /**
   * Generate evolutionary traits from block data
   * @param blockNumber - Bitcoin block number for seeding
   * @param generationType - Type of generation
   * @returns Generated evolutionary traits
   */
  #generateEvolutionaryTraits(blockNumber: number, generationType: GenerationType): EvolutionaryTraits {
    const hash = this.#hashBlock(blockNumber + 3);

    return {
      generation: generationType === "genesis" ? 0 : 1,
      fitness: this.#generateTraitValue("fitness", hash, 0),
      stability: this.#generateTraitValue("stability", hash, 1),
      reproductivity: this.#generateTraitValue("reproductivity", hash, 2),
      longevity: this.#generateTraitValue("longevity", hash, 3)
    };
  }

  /**
   * Generate color from hash values
   * @param hash - Hash array
   * @param offset - Offset in hash array
   * @returns RGB color hex string
   */
  #generateColor(hash: number[], offset: number): string {
    const r = hash[offset % hash.length] % 256;
    const g = hash[(offset + 1) % hash.length] % 256;
    const b = hash[(offset + 2) % hash.length] % 256;

    return `#${r.toString(16).padStart(2, "0")}${g.toString(16).padStart(2, "0")}${b.toString(16).padStart(2, "0")}`;
  }

  /**
   * Generate trait value within defined range
   * @param traitName - Name of the trait
   * @param hash - Hash array for randomization
   * @param offset - Offset in hash array
   * @returns Generated trait value
   */
  #generateTraitValue(traitName: string, hash: number[], offset: number): number {
    const range = this.#traitRanges.get(traitName);
    if (!range) return 1.0;

    const normalizedValue = (hash[offset % hash.length] % 1000) / 1000;
    return range.min + (normalizedValue * (range.max - range.min));
  }

  /**
   * Hash block number to array of values
   * @param blockNumber - Bitcoin block number
   * @returns Array of hash values
   */
  #hashBlock(blockNumber: number): number[] {
    const hash: number[] = [];
    let n = blockNumber;

    for (let i = 0; i < 8; i++) {
      n = ((n >> 16) ^ n) * 0x45d9f3b;
      n = ((n >> 16) ^ n) * 0x45d9f3b;
      n = (n >> 16) ^ n;
      hash.push(Math.abs(n));
    }

    return hash;
  }

  /**
   * Mutate visual traits
   * @param visual - Visual traits to mutate
   * @param rate - Mutation rate
   * @param mutations - Mutation records array
   */
  #mutateVisualTraits(visual: VisualTraits, rate: number, mutations: MutationRecord[]): void {
    if (Math.random() < rate) {
      const oldSize = visual.size;
      visual.size = this.#mutateNumericTrait(visual.size, "size", 0.1);
      mutations.push(this.#createMutationRecord("visual", "size", oldSize, visual.size, rate));
    }

    if (Math.random() < rate) {
      const oldOpacity = visual.opacity;
      visual.opacity = this.#mutateNumericTrait(visual.opacity, "opacity", 0.05);
      mutations.push(this.#createMutationRecord("visual", "opacity", oldOpacity, visual.opacity, rate));
    }
  }

  /**
   * Mutate behavioral traits
   * @param behavioral - Behavioral traits to mutate
   * @param rate - Mutation rate
   * @param mutations - Mutation records array
   */
  #mutateBehavioralTraits(behavioral: BehavioralTraits, rate: number, mutations: MutationRecord[]): void {
    if (Math.random() < rate) {
      const oldSpeed = behavioral.speed;
      behavioral.speed = this.#mutateNumericTrait(behavioral.speed, "speed", 0.1);
      mutations.push(this.#createMutationRecord("behavioral", "speed", oldSpeed, behavioral.speed, rate));
    }
  }

  /**
   * Mutate physical traits
   * @param physical - Physical traits to mutate
   * @param rate - Mutation rate
   * @param mutations - Mutation records array
   */
  #mutatePhysicalTraits(physical: PhysicalTraits, rate: number, mutations: MutationRecord[]): void {
    if (Math.random() < rate) {
      const oldMass = physical.mass;
      physical.mass = this.#mutateNumericTrait(physical.mass, "mass", 0.1);
      mutations.push(this.#createMutationRecord("physical", "mass", oldMass, physical.mass, rate));
    }
  }

  /**
   * Mutate evolutionary traits
   * @param evolutionary - Evolutionary traits to mutate
   * @param rate - Mutation rate
   * @param mutations - Mutation records array
   */
  #mutateEvolutionaryTraits(evolutionary: EvolutionaryTraits, rate: number, mutations: MutationRecord[]): void {
    evolutionary.generation++;

    if (Math.random() < rate) {
      const oldFitness = evolutionary.fitness;
      evolutionary.fitness = this.#mutateNumericTrait(evolutionary.fitness, "fitness", 5.0);
      mutations.push(this.#createMutationRecord("evolutionary", "fitness", oldFitness, evolutionary.fitness, rate));
    }
  }

  /**
   * Mutate numeric trait within bounds
   * @param currentValue - Current trait value
   * @param traitName - Name of the trait
   * @param variance - Mutation variance
   * @returns Mutated value
   */
  #mutateNumericTrait(currentValue: number, traitName: string, variance: number): number {
    const range = this.#traitRanges.get(traitName);
    if (!range) return currentValue;

    const mutation = (Math.random() - 0.5) * variance * 2;
    const newValue = currentValue + mutation;

    return Math.max(range.min, Math.min(range.max, newValue));
  }

  /**
   * Create mutation record
   * @param category - Trait category
   * @param traitName - Trait name
   * @param oldValue - Previous value
   * @param newValue - New value
   * @param strength - Mutation strength
   * @returns Mutation record
   */
  #createMutationRecord(category: TraitCategory, traitName: string, oldValue: any, newValue: any, strength: number): MutationRecord {
    return {
      timestamp: Date.now(),
      blockNumber: 0, // Will be set by caller
      category,
      traitName,
      previousValue: oldValue,
      newValue,
      mutationStrength: strength
    };
  }

  /**
   * Update performance metrics
   * @param startTime - Operation start time
   * @param generationType - Type of generation performed
   */
  #updateMetrics(startTime: number, generationType: GenerationType): void {
    const duration = performance.now() - startTime;

    this.#metrics.totalGenerated++;
    this.#metrics.generationTypes[generationType]++;

    // Update average generation time
    const total = this.#metrics.totalGenerated;
    this.#metrics.averageGenerationTime =
      ((this.#metrics.averageGenerationTime * (total - 1)) + duration) / total;
  }

  /**
   * Update cache hit rate
   * @param hit - Whether this was a cache hit
   */
  #updateCacheHitRate(hit: boolean): void {
    // Simple cache hit rate calculation
    const totalOperations = this.#metrics.totalGenerated + 1;
    if (hit) {
      this.#metrics.cacheHitRate = ((this.#metrics.cacheHitRate * (totalOperations - 1)) + 100) / totalOperations;
    } else {
      this.#metrics.cacheHitRate = (this.#metrics.cacheHitRate * (totalOperations - 1)) / totalOperations;
    }
  }
}

// Export singleton instance getter
export const traitService = TraitService.getInstance();
'@

    # Append Part 3 to complete the service
    Add-Content -Path (Join-Path $servicesPath "traitService.ts") -Value $serviceContent3 -Encoding UTF8
    Write-SuccessLog "TraitService implementation Part 3 generated successfully"

    # Generate export index file
    Write-InfoLog "Generating Trait domain export index"
    $indexContent = @'
/**
 * @fileoverview Trait Domain Exports
 * @description Main export file for Trait domain
 * @author Protozoa Development Team
 * @version 1.0.0
 */

// Service exports
export { TraitService, traitService } from "./services/traitService";

// Interface exports
export type {
  ITraitService,
  TraitConfig,
  OrganismTraits,
  VisualTraits,
  BehavioralTraits,
  PhysicalTraits,
  EvolutionaryTraits,
  TraitMetrics
} from "./interfaces/ITraitService";

// Type exports
export type {
  TraitCategory,
  TraitType,
  MutationRecord,
  TraitValidation,
  TraitGenerationParams,
  GenerationType,
  RGBColor,
  TraitRange,
  InheritanceWeights
} from "./types/trait.types";
'@

    Set-Content -Path (Join-Path $traitDomainPath "index.ts") -Value $indexContent -Encoding UTF8
    Write-SuccessLog "Trait domain export index generated successfully"

    Write-SuccessLog "Trait Service generation completed successfully"
    Write-InfoLog "Generated files:"
    Write-InfoLog "  - src/domains/trait/interfaces/ITraitService.ts"
    Write-InfoLog "  - src/domains/trait/types/trait.types.ts"
    Write-InfoLog "  - src/domains/trait/services/traitService.ts"
    Write-InfoLog "  - src/domains/trait/index.ts"

    exit 0
}
catch {
    Write-ErrorLog "Trait Service generation failed: $($_.Exception.Message)"
    exit 1
}
finally {
    try { Pop-Location -ErrorAction SilentlyContinue } catch { }
}
