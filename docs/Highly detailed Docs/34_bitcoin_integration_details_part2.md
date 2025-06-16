# Bitcoin Integration Details - Part 2: Confirmation Milestones and Mutation System

## Confirmation Milestone Thresholds

```typescript
// Confirmation milestone definitions
interface ConfirmationMilestone {
  threshold: number;      // Number of confirmations required
  name: string;           // Name of the milestone
  probability: number;    // Probability of mutation (0.0-1.0)
  description: string;    // Description of the milestone
  mutationTypes: string[]; // Types of mutations possible at this milestone
}

// Milestone definitions
const CONFIRMATION_MILESTONES: ConfirmationMilestone[] = [
  { 
    threshold: 6, 
    name: 'Basic', 
    probability: 1.0,     // 100% chance at 6 confirmations
    description: 'Initial stabilization of the creature',
    mutationTypes: ['color', 'scale']
  },
  { 
    threshold: 100, 
    name: 'Common', 
    probability: 0.8,     // 80% chance at 100 confirmations
    description: 'Common evolutionary traits',
    mutationTypes: ['color', 'scale', 'shape', 'force']
  },
  { 
    threshold: 1000, 
    name: 'Uncommon', 
    probability: 0.6,     // 60% chance at 1,000 confirmations
    description: 'Uncommon evolutionary traits',
    mutationTypes: ['color', 'scale', 'shape', 'force', 'behavior']
  },
  { 
    threshold: 10000, 
    name: 'Rare', 
    probability: 0.4,     // 40% chance at 10,000 confirmations
    description: 'Rare evolutionary traits',
    mutationTypes: ['color', 'scale', 'shape', 'force', 'behavior', 'special']
  },
  { 
    threshold: 50000, 
    name: 'Epic', 
    probability: 0.2,     // 20% chance at 50,000 confirmations
    description: 'Epic evolutionary traits',
    mutationTypes: ['color', 'scale', 'shape', 'force', 'behavior', 'special', 'legendary']
  },
  { 
    threshold: 100000, 
    name: 'Legendary', 
    probability: 0.1,     // 10% chance at 100,000 confirmations
    description: 'Legendary evolutionary traits',
    mutationTypes: ['color', 'scale', 'shape', 'force', 'behavior', 'special', 'legendary', 'mythic']
  },
  { 
    threshold: 210000, 
    name: 'Mythic', 
    probability: 0.05,    // 5% chance at 210,000 confirmations (approx. 4 years)
    description: 'Mythic evolutionary traits - once per halving',
    mutationTypes: ['color', 'scale', 'shape', 'force', 'behavior', 'special', 'legendary', 'mythic', 'genesis']
  }
];
```

## Mutation Probability Tables

```typescript
// Mutation type definitions
interface MutationTypeProbability {
  type: string;           // Type of mutation
  probability: number;    // Base probability (0.0-1.0)
  groupWeights: Record<string, number>; // Weight multipliers for different groups
  rarityMultipliers: Record<string, number>; // Multipliers for different rarity levels
}

// Mutation type probabilities
const MUTATION_TYPE_PROBABILITIES: MutationTypeProbability[] = [
  {
    type: 'color',
    probability: 0.3,
    groupWeights: {
      'core': 0.5,
      'control': 1.0,
      'attack': 1.2,
      'defense': 0.8,
      'movement': 1.0
    },
    rarityMultipliers: {
      'common': 1.0,
      'uncommon': 0.8,
      'rare': 0.6,
      'epic': 0.4,
      'legendary': 0.2,
      'mythic': 0.1
    }
  },
  {
    type: 'scale',
    probability: 0.2,
    groupWeights: {
      'core': 0.7,
      'control': 0.8,
      'attack': 1.2,
      'defense': 1.0,
      'movement': 1.1
    },
    rarityMultipliers: {
      'common': 1.0,
      'uncommon': 0.8,
      'rare': 0.6,
      'epic': 0.4,
      'legendary': 0.2,
      'mythic': 0.1
    }
  },
  {
    type: 'shape',
    probability: 0.15,
    groupWeights: {
      'core': 0.5,
      'control': 0.7,
      'attack': 1.3,
      'defense': 1.2,
      'movement': 1.0
    },
    rarityMultipliers: {
      'common': 1.0,
      'uncommon': 0.8,
      'rare': 0.6,
      'epic': 0.4,
      'legendary': 0.2,
      'mythic': 0.1
    }
  },
  {
    type: 'force',
    probability: 0.25,
    groupWeights: {
      'core': 1.2,
      'control': 1.3,
      'attack': 1.0,
      'defense': 0.8,
      'movement': 1.1
    },
    rarityMultipliers: {
      'common': 1.0,
      'uncommon': 0.9,
      'rare': 0.7,
      'epic': 0.5,
      'legendary': 0.3,
      'mythic': 0.2
    }
  },
  {
    type: 'behavior',
    probability: 0.1,
    groupWeights: {
      'core': 1.0,
      'control': 1.5,
      'attack': 1.2,
      'defense': 0.9,
      'movement': 1.3
    },
    rarityMultipliers: {
      'common': 0.0, // Not available at common level
      'uncommon': 1.0,
      'rare': 0.8,
      'epic': 0.6,
      'legendary': 0.4,
      'mythic': 0.2
    }
  },
  {
    type: 'special',
    probability: 0.05,
    groupWeights: {
      'core': 1.5,
      'control': 1.2,
      'attack': 1.0,
      'defense': 1.0,
      'movement': 0.8
    },
    rarityMultipliers: {
      'common': 0.0, // Not available at common level
      'uncommon': 0.0, // Not available at uncommon level
      'rare': 1.0,
      'epic': 0.8,
      'legendary': 0.6,
      'mythic': 0.4
    }
  },
  {
    type: 'legendary',
    probability: 0.03,
    groupWeights: {
      'core': 2.0,
      'control': 1.0,
      'attack': 1.0,
      'defense': 1.0,
      'movement': 1.0
    },
    rarityMultipliers: {
      'common': 0.0, // Not available at common level
      'uncommon': 0.0, // Not available at uncommon level
      'rare': 0.0, // Not available at rare level
      'epic': 0.0, // Not available at epic level
      'legendary': 1.0,
      'mythic': 0.5
    }
  },
  {
    type: 'mythic',
    probability: 0.01,
    groupWeights: {
      'core': 3.0,
      'control': 0.5,
      'attack': 0.5,
      'defense': 0.5,
      'movement': 0.5
    },
    rarityMultipliers: {
      'common': 0.0, // Not available at common level
      'uncommon': 0.0, // Not available at uncommon level
      'rare': 0.0, // Not available at rare level
      'epic': 0.0, // Not available at epic level
      'legendary': 0.0, // Not available at legendary level
      'mythic': 1.0
    }
  },
  {
    type: 'genesis',
    probability: 0.005,
    groupWeights: {
      'core': 5.0,
      'control': 0.0, // Only core can get genesis mutations
      'attack': 0.0,
      'defense': 0.0,
      'movement': 0.0
    },
    rarityMultipliers: {
      'common': 0.0, // Not available at common level
      'uncommon': 0.0, // Not available at uncommon level
      'rare': 0.0, // Not available at rare level
      'epic': 0.0, // Not available at epic level
      'legendary': 0.0, // Not available at legendary level
      'mythic': 1.0
    }
  }
];
```

## Group Selection for Mutations

```typescript
// Group selection weights
interface GroupSelectionWeight {
  group: string;          // Group name
  baseWeight: number;     // Base selection weight
  confirmationScaling: number; // How weight scales with confirmations
  mutationTypeMultipliers: Record<string, number>; // Multipliers for different mutation types
}

// Group selection weights
const GROUP_SELECTION_WEIGHTS: GroupSelectionWeight[] = [
  {
    group: 'core',
    baseWeight: 1.0,
    confirmationScaling: 0.0001, // Increases by 0.01% per confirmation
    mutationTypeMultipliers: {
      'color': 0.8,
      'scale': 0.9,
      'shape': 0.7,
      'force': 1.2,
      'behavior': 1.0,
      'special': 1.5,
      'legendary': 2.0,
      'mythic': 3.0,
      'genesis': 5.0
    }
  },
  {
    group: 'control',
    baseWeight: 0.8,
    confirmationScaling: 0.00008, // Increases by 0.008% per confirmation
    mutationTypeMultipliers: {
      'color': 1.0,
      'scale': 0.8,
      'shape': 0.7,
      'force': 1.3,
      'behavior': 1.5,
      'special': 1.2,
      'legendary': 1.0,
      'mythic': 0.5,
      'genesis': 0.0
    }
  },
  {
    group: 'attack',
    baseWeight: 0.9,
    confirmationScaling: 0.00009, // Increases by 0.009% per confirmation
    mutationTypeMultipliers: {
      'color': 1.2,
      'scale': 1.2,
      'shape': 1.3,
      'force': 1.0,
      'behavior': 1.2,
      'special': 1.0,
      'legendary': 1.0,
      'mythic': 0.5,
      'genesis': 0.0
    }
  },
  {
    group: 'defense',
    baseWeight: 0.7,
    confirmationScaling: 0.00007, // Increases by 0.007% per confirmation
    mutationTypeMultipliers: {
      'color': 0.8,
      'scale': 1.0,
      'shape': 1.2,
      'force': 0.8,
      'behavior': 0.9,
      'special': 1.0,
      'legendary': 1.0,
      'mythic': 0.5,
      'genesis': 0.0
    }
  },
  {
    group: 'movement',
    baseWeight: 0.8,
    confirmationScaling: 0.00008, // Increases by 0.008% per confirmation
    mutationTypeMultipliers: {
      'color': 1.0,
      'scale': 1.1,
      'shape': 1.0,
      'force': 1.1,
      'behavior': 1.3,
      'special': 0.8,
      'legendary': 1.0,
      'mythic': 0.5,
      'genesis': 0.0
    }
  }
];
```

## Multi-Group Mutation Probabilities

```typescript
// Multi-group mutation probability by confirmation milestone
const MULTI_GROUP_MUTATION_PROBABILITIES: Record<string, number> = {
  'Basic': 0.0,      // No multi-group mutations at basic level
  'Common': 0.1,     // 10% chance of multi-group mutation
  'Uncommon': 0.2,   // 20% chance of multi-group mutation
  'Rare': 0.3,       // 30% chance of multi-group mutation
  'Epic': 0.4,       // 40% chance of multi-group mutation
  'Legendary': 0.5,  // 50% chance of multi-group mutation
  'Mythic': 0.6      // 60% chance of multi-group mutation
};

// Number of groups affected in multi-group mutations
const MULTI_GROUP_COUNT_PROBABILITIES: Record<string, number[]> = {
  'Basic': [1.0, 0.0, 0.0, 0.0, 0.0],  // Always 1 group
  'Common': [0.9, 0.1, 0.0, 0.0, 0.0],  // 90% 1 group, 10% 2 groups
  'Uncommon': [0.7, 0.2, 0.1, 0.0, 0.0],  // 70% 1 group, 20% 2 groups, 10% 3 groups
  'Rare': [0.5, 0.3, 0.15, 0.05, 0.0],  // 50% 1 group, 30% 2 groups, 15% 3 groups, 5% 4 groups
  'Epic': [0.3, 0.3, 0.2, 0.15, 0.05],  // 30% 1 group, 30% 2 groups, 20% 3 groups, 15% 4 groups, 5% 5 groups
  'Legendary': [0.2, 0.2, 0.2, 0.2, 0.2],  // Equal 20% chance for 1-5 groups
  'Mythic': [0.1, 0.15, 0.2, 0.25, 0.3]  // 10% 1 group, 15% 2 groups, 20% 3 groups, 25% 4 groups, 30% 5 groups
};
```

## Mutation Effect System

```typescript
// Mutation effect definition
interface MutationEffect {
  type: string;           // Type of mutation
  rarity: string;         // Rarity level
  group: string;          // Affected group
  description: string;    // Description of the effect
  visualEffect: boolean;  // Whether the mutation has a visual effect
  applyEffect: (creature: Creature, group: ParticleGroup) => void; // Function to apply the effect
}

// Example mutation effects
const MUTATION_EFFECTS: Record<string, MutationEffect[]> = {
  'color': [
    {
      type: 'color',
      rarity: 'common',
      group: 'any',
      description: 'Slight color shift',
      visualEffect: true,
      applyEffect: (creature, group) => {
        // Shift color slightly
        const color = new THREE.Color(group.color);
        const hsl = { h: 0, s: 0, l: 0 };
        color.getHSL(hsl);
        
        // Shift hue by up to 5%
        const hueShift = (Math.random() * 0.1 - 0.05);
        hsl.h = (hsl.h + hueShift + 1) % 1;
        
        // Apply new color
        color.setHSL(hsl.h, hsl.s, hsl.l);
        group.color = '#' + color.getHexString();
      }
    },
    {
      type: 'color',
      rarity: 'uncommon',
      group: 'any',
      description: 'Moderate color shift',
      visualEffect: true,
      applyEffect: (creature, group) => {
        // Shift color moderately
        const color = new THREE.Color(group.color);
        const hsl = { h: 0, s: 0, l: 0 };
        color.getHSL(hsl);
        
        // Shift hue by up to 15%
        const hueShift = (Math.random() * 0.3 - 0.15);
        hsl.h = (hsl.h + hueShift + 1) % 1;
        
        // Increase saturation slightly
        hsl.s = Math.min(1, hsl.s * (1 + Math.random() * 0.2));
        
        // Apply new color
        color.setHSL(hsl.h, hsl.s, hsl.l);
        group.color = '#' + color.getHexString();
      }
    },
    // Additional color mutations for other rarities...
  ],
  'scale': [
    {
      type: 'scale',
      rarity: 'common',
      group: 'any',
      description: 'Slight size change',
      visualEffect: true,
      applyEffect: (creature, group) => {
        // Change scale by up to 10%
        const scaleChange = 1 + (Math.random() * 0.2 - 0.1);
        group.scale *= scaleChange;
        
        // Ensure scale stays within reasonable bounds
        group.scale = Math.max(0.5, Math.min(2.0, group.scale));
      }
    },
    // Additional scale mutations...
  ],
  'force': [
    {
      type: 'force',
      rarity: 'common',
      group: 'any',
      description: 'Minor force adjustment',
      visualEffect: false,
      applyEffect: (creature, group) => {
        // Adjust force rules for this group
        const forceRules = creature.forceRules[group.id];
        
        // Pick a random target group
        const targetGroups = Object.keys(forceRules);
        const targetGroup = targetGroups[Math.floor(Math.random() * targetGroups.length)];
        
        // Adjust force by up to 20%
        const forceChange = (Math.random() * 0.4 - 0.2);
        forceRules[targetGroup] += forceChange;
        
        // Ensure force stays within reasonable bounds
        forceRules[targetGroup] = Math.max(-1.0, Math.min(1.0, forceRules[targetGroup]));
      }
    },
    // Additional force mutations...
  ],
  // Additional mutation types...
};
```
