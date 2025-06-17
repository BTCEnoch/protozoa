# Evolution Mechanics

This document outlines the mutation-based evolution mechanics for particle creatures based on Bitcoin block confirmations. These mechanics will allow creatures to evolve and change over time as their associated Bitcoin blocks gain more confirmations.

## Overview

In the Bitcoin network, each new block that is added to the blockchain provides an additional "confirmation" for all previous blocks. This confirmation count serves as a natural progression metric that we can use to drive the evolution of our particle creatures through a milestone-based mutation system.

## Confirmation-Based Mutation System

### Core Concept

As a Bitcoin block gains more confirmations, its associated particle creature will have opportunities to mutate at specific confirmation milestones. Each milestone has a small percentage chance to trigger a mutation event, with the rarity of potential mutations determined by the milestone level. This creates a dynamic, living ecosystem where creatures age with Bitcoin and develop unique characteristics over time.

### Mutation Milestones

Mutations will be checked at specific confirmation thresholds:

1. **10,000 Confirmations Milestone**
   - 1% chance for mutation
   - All rarities available (Common to Mythic)
   - Occurs approximately every 10,000 blocks (~70 days)

2. **50,000 Confirmations Milestone**
   - 5% chance for mutation
   - Uncommon to Mythic rarities available
   - Occurs approximately every 50,000 blocks (~347 days)

3. **100,000 Confirmations Milestone**
   - 10% chance for mutation
   - Rare to Mythic rarities available
   - Occurs approximately every 100,000 blocks (~694 days)

4. **250,000 Confirmations Milestone**
   - 25% chance for mutation
   - Epic to Mythic rarities available
   - Occurs approximately every 250,000 blocks (~1,736 days)

5. **500,000 Confirmations Milestone**
   - 50% chance for mutation
   - Legendary to Mythic rarities available
   - Occurs approximately every 500,000 blocks (~3,472 days)

6. **1,000,000 Confirmations Milestone**
   - 100% chance for mutation
   - Mythic rarity only
   - Occurs approximately every 1,000,000 blocks (~6,944 days)

### Implementation Approach

```typescript
interface EvolutionState {
  version: number;
  confirmations: number;
  mutationHistory: MutationEvent[];
  lastMutation?: MutationEvent;
}

interface MutationEvent {
  type: MutationType;
  rarity: Rarity;
  groupId: string;
  timestamp: number;
  milestone: number;
  details: {
    oldValue: any;
    newValue: any;
    [key: string]: any;
  };
}

enum MutationType {
  ATTRIBUTE_BOOST = 'attribute_boost',
  TYPE_CHANGE = 'type_change',
  COUNT_INCREASE = 'count_increase',
  GROUP_SPLIT = 'group_split'
}

enum Rarity {
  COMMON = 'common',
  UNCOMMON = 'uncommon',
  RARE = 'rare',
  EPIC = 'epic',
  LEGENDARY = 'legendary',
  MYTHIC = 'mythic'
}

class MutationSystem {
  private rng: () => number;
  private lastProcessedNonce: number | null = null;

  constructor() {
    this.rng = getRNG('mutations');
  }

  public checkMilestoneEvolution(
    traits: Record<string, Trait>,
    confirmations: number
  ): { traits: Record<string, Trait>; event?: MutationEvent } {
    // Check if we've hit a milestone
    const milestone = this.determineMilestone(confirmations);
    if (!milestone) {
      return { traits };
    }

    // Roll for mutation chance
    if (!this.rollForMutation(milestone.chance)) {
      return { traits };
    }

    // Determine rarity based on milestone
    const rarity = this.determineRarity(milestone.rarities);

    // Choose mutation type
    const mutationType = this.determineMutationType(rarity);

    // Select target group
    const groupId = this.selectRandomGroup(traits);

    // Apply mutation
    const { updatedTraits, details } = this.applyMutation(
      traits,
      mutationType,
      rarity,
      groupId
    );

    // Create mutation event
    const event: MutationEvent = {
      type: mutationType,
      rarity,
      groupId,
      timestamp: Date.now(),
      milestone: milestone.threshold,
      details
    };

    return { traits: updatedTraits, event };
  }

  private determineMilestone(confirmations: number): { threshold: number; chance: number; rarities: Rarity[] } | null {
    // Check highest milestones first for efficiency
    if (confirmations >= 1000000 && confirmations % 1000000 === 0) {
      return {
        threshold: 1000000,
        chance: 0.0002,
        rarities: [Rarity.MYTHIC]
      };
    }
    if (confirmations >= 500000 && confirmations % 500000 === 0) {
      return {
        threshold: 500000,
        chance: 0.0005,
        rarities: [Rarity.LEGENDARY, Rarity.MYTHIC]
      };
    }
    // ... other milestones
    return null;
  }
}
```

## Mutation Types

### Attribute Boost

- Increases attribute value by 10-30%
- Capped at maximum value of 1.0
- Applied to a single randomly selected group
- Visual effects reflect the boosted attribute
- Rarity influences the boost percentage

### Type Change

- Changes particle group type
- Updates associated color and visual properties
- Maintains count and other attributes
- Visual transition effect during change
- Rarity influences available type options

### Count Increase

- Adds up to 20% more particles to a group
- Distributes increase proportionally
- Respects total particle limits (500 total)
- Visual effect shows new particles spawning
- Rarity influences the percentage increase

### Group Split

- Creates new group from 40% of particles in an existing group
- New group inherits type with slight attribute variation
- Requires minimum particle counts to execute
- Visual effect shows group division
- Rarity influences the attribute variation in the new group

## Rarity System

### Rarity Distribution

The rarity system follows this distribution:

1. **Common**: 40% chance when a mutation occurs
2. **Uncommon**: 30% chance when a mutation occurs
3. **Rare**: 20% chance when a mutation occurs
4. **Epic**: 8% chance when a mutation occurs
5. **Legendary**: 1.5% chance when a mutation occurs
6. **Mythic**: 0.5% chance when a mutation occurs

### Milestone Restrictions

Higher milestones restrict available rarities to higher tiers:

- 10,000 confirmations: All rarities available
- 50,000 confirmations: Uncommon and above
- 100,000 confirmations: Rare and above
- 250,000 confirmations: Epic and above
- 500,000 confirmations: Legendary and above
- 1,000,000 confirmations: Mythic only

### Implementation Approach

```typescript
interface RarityWeight {
  rarity: Rarity;
  weight: number;
}

const rarityWeights: RarityWeight[] = [
  { rarity: Rarity.COMMON, weight: 40 },
  { rarity: Rarity.UNCOMMON, weight: 30 },
  { rarity: Rarity.RARE, weight: 20 },
  { rarity: Rarity.EPIC, weight: 8 },
  { rarity: Rarity.LEGENDARY, weight: 1.5 },
  { rarity: Rarity.MYTHIC, weight: 0.5 }
];

function determineRarity(availableRarities: Rarity[]): Rarity {
  // Filter weights to only include available rarities
  const availableWeights = rarityWeights.filter(
    weight => availableRarities.includes(weight.rarity)
  );

  // Calculate total weight
  const totalWeight = availableWeights.reduce(
    (sum, weight) => sum + weight.weight, 0
  );

  // Roll for rarity
  const roll = this.rng() * totalWeight;
  let cumulativeWeight = 0;

  for (const weight of availableWeights) {
    cumulativeWeight += weight.weight;
    if (roll < cumulativeWeight) {
      return weight.rarity;
    }
  }

  // Fallback to highest available rarity
  return availableRarities[availableRarities.length - 1];
}
```

## Group Selection and Multi-Group Mutations

### Random Group Selection

When a mutation occurs, a group is randomly selected to receive the mutation:

```typescript
function selectRandomGroup(traits: Record<string, Trait>): string {
  const groupIds = Object.keys(traits);
  const randomIndex = Math.floor(this.rng() * groupIds.length);
  return groupIds[randomIndex];
}
```

### Multi-Group Mutation Chance

In rare cases, a mutation may apply to multiple groups:

```typescript
function determineAffectedGroups(traits: Record<string, Trait>, rarity: Rarity): string[] {
  // Select primary group
  const primaryGroup = this.selectRandomGroup(traits);

  // Determine if this is a multi-group mutation (rare chance)
  const multiGroupChance = rarity === Rarity.LEGENDARY ? 0.15 :
                          rarity === Rarity.MYTHIC ? 0.25 : 0.05;

  if (this.rng() < multiGroupChance) {
    // Select a second group different from the primary
    const remainingGroups = Object.keys(traits).filter(id => id !== primaryGroup);
    if (remainingGroups.length > 0) {
      const secondaryIndex = Math.floor(this.rng() * remainingGroups.length);
      return [primaryGroup, remainingGroups[secondaryIndex]];
    }
  }

  return [primaryGroup];
}
```

### Role-Specific Mutation Effects

Mutations may have different effects based on the role of the group:

- **CORE**: Attribute boosts focus on stability and influence
- **CONTROL**: Mutations enhance gyroscopic movement and control patterns
- **MOVEMENT**: Mutations improve speed and maneuverability
- **DEFENSE**: Mutations strengthen protective fields and barrier effects
- **ATTACK**: Mutations enhance patrol patterns and aggressive behaviors

## Implementation Considerations

### Nonce Tracking

To prevent duplicate mutations, we track the last processed nonce:

```typescript
// Skip if already processed this nonce
if (stateUpdateRef.current.lastNonce === blockDataRef.current.nonce) {
  return;
}

// Track processed nonce
stateUpdateRef.current.lastNonce = blockDataRef.current.nonce;
```

### Mutation Visualization

When a mutation occurs, we provide visual feedback:

```typescript
function visualizeMutation(mutation: MutationEvent) {
  // Create visual effect based on mutation type and rarity
  const effect = createEffect(mutation.type, mutation.rarity);

  // Apply effect to specific group(s)
  mutation.groupId.forEach(groupId => {
    applyVisualEffect(groupId, effect);
  });

  // Show notification
  showNotification(`${mutation.rarity} mutation occurred: ${getMutationDescription(mutation)}`);

  // Update mutation history UI
  updateMutationHistory(mutation);
}
```

### Confirmation Tracking

We track confirmation changes from the Bitcoin API:

```typescript
async function updateConfirmations(blockNumber: number) {
  const blockInfo = await fetchBlockInfo(blockNumber);
  const confirmations = blockInfo.confirmations;

  // Check for milestone mutations
  const { traits: updatedTraits, event } = mutationSystem.checkMilestoneEvolution(
    traits,
    confirmations
  );

  // If mutation occurred, update state and visualize
  if (event) {
    setTraits(updatedTraits);
    visualizeMutation(event);
    addToMutationHistory(event);
  }
}
```

### User Interface

The UI should indicate:
- Current confirmation count
- Mutation history with rarity indicators
- Progress toward next milestone
- Visual cues during mutation events
- Attribute changes from mutations

## Testing Approach

### Milestone Testing

To test future milestones that haven't occurred yet in Bitcoin's history:

```typescript
function testMilestone(milestone: number) {
  // Override confirmation count for testing
  const testConfirmations = milestone;

  // Run mutation check with test confirmations
  const { traits: updatedTraits, event } = mutationSystem.checkMilestoneEvolution(
    traits,
    testConfirmations
  );

  // Log results
  console.log(`Testing milestone ${milestone}:`, {
    mutationOccurred: !!event,
    mutationType: event?.type,
    rarity: event?.rarity,
    affectedGroup: event?.groupId
  });

  // Visualize if mutation occurred
  if (event) {
    visualizeMutation(event);
  }
}
```

### Mutation Probability Testing

To verify mutation probabilities:

```typescript
function testMutationProbabilities(milestone: number, iterations: number) {
  const results = {
    total: iterations,
    mutations: 0,
    byRarity: {} as Record<Rarity, number>
  };

  for (let i = 0; i < iterations; i++) {
    // Set a different nonce for each iteration
    setNonce(i);

    const { event } = mutationSystem.checkMilestoneEvolution(
      traits,
      milestone
    );

    if (event) {
      results.mutations++;
      results.byRarity[event.rarity] = (results.byRarity[event.rarity] || 0) + 1;
    }
  }

  // Calculate percentages
  const mutationRate = (results.mutations / iterations) * 100;
  const rarityDistribution = Object.entries(results.byRarity).map(
    ([rarity, count]) => ({
      rarity,
      percentage: (count / results.mutations) * 100
    })
  );

  console.log(`Mutation rate at milestone ${milestone}: ${mutationRate.toFixed(2)}%`);
  console.log('Rarity distribution:', rarityDistribution);
}
```

## Implementation Plan

1. **Phase 1**: Implement the mutation system core logic
2. **Phase 2**: Add milestone detection and mutation chance rolling
3. **Phase 3**: Implement the four mutation types
4. **Phase 4**: Add visual effects for mutations
5. **Phase 5**: Implement mutation history and UI elements
6. **Phase 6**: Add testing tools for milestone and probability testing
