# Bitcoin Integration Details - Part 2: Confirmation Milestones and Mutation System

This document provides implementation details for the confirmation-based mutation system, building upon the architecture defined in [19_evolution_mechanics.md](19_evolution_mechanics.md).

## Confirmation Milestone Thresholds

Implementing the milestone thresholds as defined in [19_evolution_mechanics.md](19_evolution_mechanics.md) (lines 19-47):

```typescript
// Confirmation milestone definitions
// Based on the milestones defined in 19_evolution_mechanics.md (lines 19-47)
interface ConfirmationMilestone {
  threshold: number;      // Number of confirmations required
  name: string;           // Name of the milestone
  probability: number;    // Probability of mutation (0.0-1.0)
  description: string;    // Description of the milestone
  rarities: Rarity[];     // Available rarities at this milestone
}

// Milestone definitions directly from 19_evolution_mechanics.md
const CONFIRMATION_MILESTONES: ConfirmationMilestone[] = [
  { 
    threshold: 10000, 
    name: '10,000 Confirmations Milestone', 
    probability: 0.01,     // 1% chance as specified in 19_evolution_mechanics.md (line 20)
    description: 'Occurs approximately every 10,000 blocks (~70 days)',
    rarities: [Rarity.COMMON, Rarity.UNCOMMON, Rarity.RARE, Rarity.EPIC, Rarity.LEGENDARY, Rarity.MYTHIC]
  },
  { 
    threshold: 50000, 
    name: '50,000 Confirmations Milestone', 
    probability: 0.005,    // 0.5% chance as specified in 19_evolution_mechanics.md (line 25)
    description: 'Occurs approximately every 50,000 blocks (~347 days)',
    rarities: [Rarity.UNCOMMON, Rarity.RARE, Rarity.EPIC, Rarity.LEGENDARY, Rarity.MYTHIC]
  },
  { 
    threshold: 100000, 
    name: '100,000 Confirmations Milestone', 
    probability: 0.0025,   // 0.25% chance as specified in 19_evolution_mechanics.md (line 30)
    description: 'Occurs approximately every 100,000 blocks (~694 days)',
    rarities: [Rarity.RARE, Rarity.EPIC, Rarity.LEGENDARY, Rarity.MYTHIC]
  },
  { 
    threshold: 250000, 
    name: '250,000 Confirmations Milestone', 
    probability: 0.001,    // 0.1% chance as specified in 19_evolution_mechanics.md (line 35)
    description: 'Occurs approximately every 250,000 blocks (~1,736 days)',
    rarities: [Rarity.EPIC, Rarity.LEGENDARY, Rarity.MYTHIC]
  },
  { 
    threshold: 500000, 
    name: '500,000 Confirmations Milestone', 
    probability: 0.0005,   // 0.05% chance as specified in 19_evolution_mechanics.md (line 40)
    description: 'Occurs approximately every 500,000 blocks (~3,472 days)',
    rarities: [Rarity.LEGENDARY, Rarity.MYTHIC]
  },
  { 
    threshold: 1000000, 
    name: '1,000,000 Confirmations Milestone', 
    probability: 0.0002,   // 0.02% chance as specified in 19_evolution_mechanics.md (line 45)
    description: 'Occurs approximately every 1,000,000 blocks (~6,944 days)',
    rarities: [Rarity.MYTHIC]
  }
];
```

## Mutation Types

Implementing the mutation types as defined in [19_evolution_mechanics.md](19_evolution_mechanics.md) (lines 164-196):

```typescript
// Mutation type enum from 19_evolution_mechanics.md (lines 72-77)
enum MutationType {
  ATTRIBUTE_BOOST = 'attribute_boost',
  TYPE_CHANGE = 'type_change',
  COUNT_INCREASE = 'count_increase',
  GROUP_SPLIT = 'group_split'
}

// Rarity enum from 19_evolution_mechanics.md (lines 79-86)
enum Rarity {
  COMMON = 'common',
  UNCOMMON = 'uncommon',
  RARE = 'rare',
  EPIC = 'epic',
  LEGENDARY = 'legendary',
  MYTHIC = 'mythic'
}

// Mutation type probabilities
// Based on the mutation types defined in 19_evolution_mechanics.md (lines 164-196)
interface MutationTypeProbability {
  type: MutationType;     // Type of mutation
  probability: number;    // Base probability (0.0-1.0)
  description: string;    // Description from 19_evolution_mechanics.md
}

// Mutation type probabilities
const MUTATION_TYPE_PROBABILITIES: MutationTypeProbability[] = [
  {
    type: MutationType.ATTRIBUTE_BOOST,
    probability: 0.4,     // 40% chance
    description: 'Increases attribute value by 10-30% as described in 19_evolution_mechanics.md (lines 166-171)'
  },
  {
    type: MutationType.TYPE_CHANGE,
    probability: 0.2,     // 20% chance
    description: 'Changes particle group type as described in 19_evolution_mechanics.md (lines 173-179)'
  },
  {
    type: MutationType.COUNT_INCREASE,
    probability: 0.3,     // 30% chance
    description: 'Adds up to 20% more particles to a group as described in 19_evolution_mechanics.md (lines 181-187)'
  },
  {
    type: MutationType.GROUP_SPLIT,
    probability: 0.1,     // 10% chance
    description: 'Creates new group from 40% of particles in an existing group as described in 19_evolution_mechanics.md (lines 189-195)'
  }
];
```

## Rarity System

Implementing the rarity system as defined in [19_evolution_mechanics.md](19_evolution_mechanics.md) (lines 198-263):

```typescript
// Rarity weights directly from 19_evolution_mechanics.md (lines 229-236)
interface RarityWeight {
  rarity: Rarity;
  weight: number;
}

// Rarity weights from 19_evolution_mechanics.md (lines 229-236)
const rarityWeights: RarityWeight[] = [
  { rarity: Rarity.COMMON, weight: 40 },     // 40% chance as specified in 19_evolution_mechanics.md (line 203)
  { rarity: Rarity.UNCOMMON, weight: 30 },   // 30% chance as specified in 19_evolution_mechanics.md (line 204)
  { rarity: Rarity.RARE, weight: 20 },       // 20% chance as specified in 19_evolution_mechanics.md (line 205)
  { rarity: Rarity.EPIC, weight: 8 },        // 8% chance as specified in 19_evolution_mechanics.md (line 206)
  { rarity: Rarity.LEGENDARY, weight: 1.5 }, // 1.5% chance as specified in 19_evolution_mechanics.md (line 207)
  { rarity: Rarity.MYTHIC, weight: 0.5 }     // 0.5% chance as specified in 19_evolution_mechanics.md (line 208)
];

// Determine rarity function from 19_evolution_mechanics.md (lines 238-262)
function determineRarity(availableRarities: Rarity[], rng: () => number): Rarity {
  // Filter weights to only include available rarities
  const availableWeights = rarityWeights.filter(
    weight => availableRarities.includes(weight.rarity)
  );

  // Calculate total weight
  const totalWeight = availableWeights.reduce(
    (sum, weight) => sum + weight.weight, 0
  );

  // Roll for rarity
  const roll = rng() * totalWeight;
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

## Group Selection for Mutations

Implementing the group selection logic as defined in [19_evolution_mechanics.md](19_evolution_mechanics.md) (lines 265-303):

```typescript
// Random group selection function from 19_evolution_mechanics.md (lines 272-276)
function selectRandomGroup(traits: Record<string, any>, rng: () => number): string {
  const groupIds = Object.keys(traits);
  const randomIndex = Math.floor(rng() * groupIds.length);
  return groupIds[randomIndex];
}

// Multi-group mutation chance from 19_evolution_mechanics.md (lines 284-302)
function determineAffectedGroups(traits: Record<string, any>, rarity: Rarity, rng: () => number): string[] {
  // Select primary group
  const primaryGroup = selectRandomGroup(traits, rng);

  // Determine if this is a multi-group mutation (rare chance)
  // Using the exact probabilities from 19_evolution_mechanics.md (lines 289-290)
  const multiGroupChance = rarity === Rarity.LEGENDARY ? 0.15 :
                          rarity === Rarity.MYTHIC ? 0.25 : 0.05;

  if (rng() < multiGroupChance) {
    // Select a second group different from the primary
    const remainingGroups = Object.keys(traits).filter(id => id !== primaryGroup);
    if (remainingGroups.length > 0) {
      const secondaryIndex = Math.floor(rng() * remainingGroups.length);
      return [primaryGroup, remainingGroups[secondaryIndex]];
    }
  }

  return [primaryGroup];
}
```
