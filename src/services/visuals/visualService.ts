/**
 * Visual Service for Bitcoin Protozoa
 * 
 * This service is responsible for managing visual traits for particle groups.
 * It handles visual trait selection, application, and evolution.
 */

import { BlockData } from '../../types/bitcoin/bitcoin';
import { Role, Tier } from '../../types/abilities/ability';
import { VisualTrait, VisualRegistry, getRandomVisualTrait, createDefaultVisualTrait } from '../../types/visuals/visual';
import { RNGSystem } from '../../types/utils/rng';
import { createRNGFromBlockNonce } from '../../lib/rngSystem';
import { getVisualBankLoader } from './visualBankLoader';

/**
 * Visual service class
 */
export class VisualService {
  private blockData: BlockData | null = null;
  private rngSystem: RNGSystem | null = null;
  private visualRegistry: VisualRegistry | null = null;
  private selectedVisuals: Map<string, VisualTrait> = new Map();
  private initialized = false;

  /**
   * Initialize the visual service with block data
   * @param blockData The block data to use for RNG
   */
  public initialize(blockData: BlockData): void {
    this.blockData = blockData;
    this.rngSystem = createRNGFromBlockNonce(blockData.nonce);
    
    // Load visual registry
    const visualBankLoader = getVisualBankLoader();
    this.visualRegistry = visualBankLoader.createMockVisualRegistry();
    
    this.selectedVisuals.clear();
    this.initialized = true;

    console.log('Visual service initialized with block data:', blockData);
  }

  /**
   * Check if the service is initialized
   * @returns True if initialized, false otherwise
   */
  public isInitialized(): boolean {
    return this.initialized;
  }

  /**
   * Select a visual trait for a particle group
   * @param groupId The ID of the particle group
   * @param role The role of the particle group
   * @param tier The tier of the particle group
   * @param subclass Optional subclass to filter visual traits by
   * @returns The selected visual trait
   */
  public selectVisualForGroup(
    groupId: string,
    role: Role,
    tier: Tier,
    subclass?: string
  ): VisualTrait {
    if (!this.initialized || !this.rngSystem || !this.visualRegistry) {
      throw new Error('Visual service not initialized');
    }

    // Check if we already have a visual for this group
    if (this.selectedVisuals.has(groupId)) {
      return this.selectedVisuals.get(groupId)!;
    }

    // Create RNG stream for this group
    const visualRng = this.rngSystem.createStream(`${groupId}_visual`);

    // Try to find a visual trait for the subclass
    let visualTrait: VisualTrait | undefined;
    
    if (subclass) {
      // Try to find a visual trait for the specific subclass
      const tierVisuals = this.visualRegistry[role]?.[tier];
      if (tierVisuals) {
        visualTrait = tierVisuals.find(visual => visual.subclass === subclass);
      }
    }
    
    // If no subclass-specific visual trait was found, get a random one
    if (!visualTrait) {
      visualTrait = getRandomVisualTrait(this.visualRegistry, role, tier, visualRng);
    }
    
    // If still no visual trait, create a default one
    if (!visualTrait) {
      visualTrait = createDefaultVisualTrait(role, tier);
    }

    // Store the selected visual trait
    this.selectedVisuals.set(groupId, visualTrait);
    return visualTrait;
  }

  /**
   * Get all selected visual traits
   * @returns A map of group IDs to visual traits
   */
  public getAllSelectedVisuals(): Map<string, VisualTrait> {
    return new Map(this.selectedVisuals);
  }

  /**
   * Clear all selected visual traits
   */
  public clearSelectedVisuals(): void {
    this.selectedVisuals.clear();
  }

  /**
   * Apply a visual trait to a particle group
   * @param groupId The ID of the particle group
   * @param visualTrait The visual trait to apply
   */
  public applyVisualToGroup(groupId: string, visualTrait: VisualTrait): void {
    this.selectedVisuals.set(groupId, visualTrait);
  }

  /**
   * Evolve a visual trait
   * @param groupId The ID of the particle group
   * @param confirmations The number of confirmations
   * @returns True if the visual trait was evolved, false otherwise
   */
  public evolveVisual(groupId: string, confirmations: number): boolean {
    if (!this.initialized || !this.rngSystem || !this.visualRegistry) {
      throw new Error('Visual service not initialized');
    }

    // Check if we have a visual for this group
    if (!this.selectedVisuals.has(groupId)) {
      return false;
    }

    // Get the current visual trait
    const currentVisual = this.selectedVisuals.get(groupId)!;
    
    // TODO: Implement visual evolution based on confirmations
    // For now, just return false
    return false;
  }
}

// Singleton instance
let visualServiceInstance: VisualService | null = null;

/**
 * Get the visual service instance
 * @returns The visual service instance
 */
export function getVisualService(): VisualService {
  if (!visualServiceInstance) {
    visualServiceInstance = new VisualService();
  }
  return visualServiceInstance;
}

