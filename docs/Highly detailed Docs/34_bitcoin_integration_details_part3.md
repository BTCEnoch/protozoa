# Bitcoin Integration Details - Part 3: Mutation System Implementation

## Mutation System Core

```typescript
// Mutation definition
interface Mutation {
  id: string;             // Unique identifier
  blockHeight: number;    // Block height when mutation occurred
  confirmations: number;  // Confirmations at time of mutation
  timestamp: number;      // Timestamp when mutation occurred
  type: string;           // Type of mutation (color, scale, shape, etc.)
  rarity: string;         // Rarity level
  groups: string[];       // Affected groups
  description: string;    // Human-readable description
  applied: boolean;       // Whether mutation has been applied
  visualEffect: boolean;  // Whether mutation has visual effect
}

// Mutation manager class
class MutationSystem {
  private creature: Creature;
  private mutations: Mutation[] = [];
  private rng: () => number;
  private lastCheckedConfirmation: number = 0;
  
  constructor(creature: Creature, seed: number) {
    this.creature = creature;
    this.rng = mulberry32(seed);
  }
  
  // Check for mutations based on current confirmations
  checkForMutations(currentConfirmations: number): Mutation[] {
    // Skip if no new confirmations
    if (currentConfirmations <= this.lastCheckedConfirmation) {
      return [];
    }
    
    const newMutations: Mutation[] = [];
    
    // Check each milestone
    for (const milestone of CONFIRMATION_MILESTONES) {
      // Skip if we've already passed this milestone
      if (this.lastCheckedConfirmation >= milestone.threshold) {
        continue;
      }
      
      // Skip if we haven't reached this milestone yet
      if (currentConfirmations < milestone.threshold) {
        continue;
      }
      
      // We've hit a new milestone - check for mutation
      if (this.rng() < milestone.probability) {
        // Mutation occurs!
        const mutation = this.generateMutation(milestone);
        this.mutations.push(mutation);
        newMutations.push(mutation);
      }
    }
    
    // Update last checked confirmation
    this.lastCheckedConfirmation = currentConfirmations;
    
    return newMutations;
  }
  
  // Generate a mutation based on milestone
  private generateMutation(milestone: ConfirmationMilestone): Mutation {
    // Select mutation type
    const mutationType = this.selectMutationType(milestone.mutationTypes);
    
    // Determine if this is a multi-group mutation
    const isMultiGroup = this.rng() < MULTI_GROUP_MUTATION_PROBABILITIES[milestone.name];
    
    // Select affected groups
    const affectedGroups = this.selectAffectedGroups(
      mutationType, 
      isMultiGroup ? this.selectMultiGroupCount(milestone.name) : 1
    );
    
    // Create mutation object
    const mutation: Mutation = {
      id: `mutation-${Date.now()}-${Math.floor(this.rng() * 1000000)}`,
      blockHeight: this.creature.blockInfo.height,
      confirmations: this.creature.blockInfo.confirmations,
      timestamp: Date.now(),
      type: mutationType,
      rarity: milestone.name.toLowerCase(),
      groups: affectedGroups,
      description: this.generateMutationDescription(mutationType, milestone.name, affectedGroups),
      applied: false,
      visualEffect: this.hasMutationVisualEffect(mutationType)
    };
    
    return mutation;
  }
  
  // Select mutation type based on available types and probabilities
  private selectMutationType(availableTypes: string[]): string {
    // Get probabilities for available types
    const typeProbabilities = MUTATION_TYPE_PROBABILITIES
      .filter(mtp => availableTypes.includes(mtp.type));
    
    // Calculate total probability
    const totalProbability = typeProbabilities.reduce(
      (sum, mtp) => sum + mtp.probability, 0
    );
    
    // Select random type based on probabilities
    let random = this.rng() * totalProbability;
    for (const mtp of typeProbabilities) {
      random -= mtp.probability;
      if (random <= 0) {
        return mtp.type;
      }
    }
    
    // Fallback to first type (should never happen)
    return typeProbabilities[0].type;
  }
  
  // Select number of groups for multi-group mutation
  private selectMultiGroupCount(milestoneName: string): number {
    const probabilities = MULTI_GROUP_COUNT_PROBABILITIES[milestoneName];
    let random = this.rng();
    
    for (let i = 0; i < probabilities.length; i++) {
      random -= probabilities[i];
      if (random <= 0) {
        return i + 1; // 1-based count (1-5 groups)
      }
    }
    
    // Fallback to 1 group (should never happen)
    return 1;
  }
  
  // Select affected groups based on weights
  private selectAffectedGroups(mutationType: string, count: number): string[] {
    const groups = ['core', 'control', 'attack', 'defense', 'movement'];
    const weights = groups.map(group => {
      const groupWeight = GROUP_SELECTION_WEIGHTS.find(gsw => gsw.group === group);
      if (!groupWeight) return 0;
      
      // Calculate weight based on base weight, confirmation scaling, and mutation type
      let weight = groupWeight.baseWeight;
      
      // Add confirmation scaling
      weight += this.creature.blockInfo.confirmations * groupWeight.confirmationScaling;
      
      // Apply mutation type multiplier
      if (groupWeight.mutationTypeMultipliers[mutationType]) {
        weight *= groupWeight.mutationTypeMultipliers[mutationType];
      }
      
      return weight;
    });
    
    // Select groups based on weights
    const selectedGroups: string[] = [];
    const availableGroups = [...groups];
    const availableWeights = [...weights];
    
    for (let i = 0; i < count && availableGroups.length > 0; i++) {
      // Calculate total weight
      const totalWeight = availableWeights.reduce((sum, w) => sum + w, 0);
      
      // Select random group based on weights
      let random = this.rng() * totalWeight;
      let selectedIndex = -1;
      
      for (let j = 0; j < availableWeights.length; j++) {
        random -= availableWeights[j];
        if (random <= 0) {
          selectedIndex = j;
          break;
        }
      }
      
      // If no group was selected (shouldn't happen), select the first one
      if (selectedIndex === -1) selectedIndex = 0;
      
      // Add selected group to result
      selectedGroups.push(availableGroups[selectedIndex]);
      
      // Remove selected group from available groups
      availableGroups.splice(selectedIndex, 1);
      availableWeights.splice(selectedIndex, 1);
    }
    
    return selectedGroups;
  }
  
  // Generate human-readable description for mutation
  private generateMutationDescription(type: string, rarity: string, groups: string[]): string {
    const groupText = groups.length === 1 
      ? groups[0] 
      : `${groups.slice(0, -1).join(', ')} and ${groups[groups.length - 1]}`;
    
    const rarityText = rarity.toLowerCase();
    
    switch (type) {
      case 'color':
        return `${rarityText} color mutation affecting ${groupText} particles`;
      case 'scale':
        return `${rarityText} size mutation affecting ${groupText} particles`;
      case 'shape':
        return `${rarityText} shape mutation affecting ${groupText} particles`;
      case 'force':
        return `${rarityText} force mutation affecting ${groupText} particles`;
      case 'behavior':
        return `${rarityText} behavior mutation affecting ${groupText} particles`;
      case 'special':
        return `${rarityText} special mutation affecting ${groupText} particles`;
      case 'legendary':
        return `${rarityText} legendary mutation affecting ${groupText} particles`;
      case 'mythic':
        return `${rarityText} mythic mutation affecting ${groupText} particles`;
      case 'genesis':
        return `${rarityText} genesis mutation affecting ${groupText} particles`;
      default:
        return `${rarityText} unknown mutation affecting ${groupText} particles`;
    }
  }
  
  // Determine if mutation has visual effect
  private hasMutationVisualEffect(type: string): boolean {
    // These mutation types have visual effects
    const visualTypes = ['color', 'scale', 'shape', 'special', 'legendary', 'mythic', 'genesis'];
    return visualTypes.includes(type);
  }
  
  // Apply all pending mutations
  applyPendingMutations(): void {
    const pendingMutations = this.mutations.filter(m => !m.applied);
    
    for (const mutation of pendingMutations) {
      this.applyMutation(mutation);
      mutation.applied = true;
    }
  }
  
  // Apply a specific mutation
  private applyMutation(mutation: Mutation): void {
    // Find mutation effect
    const effects = MUTATION_EFFECTS[mutation.type];
    if (!effects) return;
    
    // Find effect matching rarity
    const effect = effects.find(e => e.rarity === mutation.rarity);
    if (!effect) return;
    
    // Apply effect to each affected group
    for (const groupName of mutation.groups) {
      const group = this.creature.particleGroups.find(g => g.id === groupName);
      if (group) {
        effect.applyEffect(this.creature, group);
      }
    }
    
    // Dispatch mutation event
    window.dispatchEvent(new CustomEvent('mutation-applied', {
      detail: { mutation, creature: this.creature }
    }));
  }
  
  // Get all mutations
  getMutations(): Mutation[] {
    return [...this.mutations];
  }
  
  // Get mutation history
  getMutationHistory(): MutationHistoryEntry[] {
    return this.mutations.map(mutation => ({
      id: mutation.id,
      blockHeight: mutation.blockHeight,
      confirmations: mutation.confirmations,
      timestamp: mutation.timestamp,
      type: mutation.type,
      rarity: mutation.rarity,
      groups: [...mutation.groups],
      description: mutation.description
    }));
  }
}

// Mutation history entry (for storage/display)
interface MutationHistoryEntry {
  id: string;
  blockHeight: number;
  confirmations: number;
  timestamp: number;
  type: string;
  rarity: string;
  groups: string[];
  description: string;
}
```
