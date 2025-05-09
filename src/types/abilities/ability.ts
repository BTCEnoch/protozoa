/**
 * Ability Types for Bitcoin Protozoa
 *
 * This file contains the type definitions for the ability system.
 * It builds on the core types and defines the structure of abilities.
 */

// Import Role and Tier from core types
import { Role, Tier } from '../core';

// Re-export Role and Tier for convenience
export { Role, Tier };

/**
 * Ability interface
 * Defines an ability that can be used by particles
 */
export interface Ability {
  id?: string;
  name: string;
  description: string;
  cooldown: number;
  trigger?: string; // e.g., "when HP < 50%"
  category: 'primary' | 'secondary' | 'unique' | 'crowdControl';
  subclass?: string; // The subclass this ability belongs to
  energyCost?: number;
  damage?: number;
  healing?: number;
  duration?: number;
  range?: number;
  area?: number;
  visualEffect?: string;
  soundEffect?: string;
}

/**
 * Formation trait interface
 * Defines a passive effect that influences the entire formation
 */
export interface FormationTrait {
  id?: string;
  name: string;
  description: string;
  subclass?: string; // The subclass this formation trait belongs to
  bonusType?: string; // The type of bonus this formation trait provides
  bonusValue?: number; // The value of the bonus
  visualEffect?: string;
}

/**
 * Ability pool interface
 * Defines a collection of abilities for a specific role and tier
 */
export interface AbilityPool {
  role?: Role;
  tier?: Tier;
  primary: Ability[];
  secondary: Ability[];
  unique: Ability[];
  crowdControl: Ability[];
  formationTraits: FormationTrait[];
}

// Tier is already imported above

// Tier ranges for particle counts
export const TierRanges = {
  [Tier.TIER_1]: [43, 90],
  [Tier.TIER_2]: [91, 121],
  [Tier.TIER_3]: [122, 151],
  [Tier.TIER_4]: [152, 182],
  [Tier.TIER_5]: [183, 203],
  [Tier.TIER_6]: [204, 220]
};

// Tier attribute thresholds
export const TierThresholds = {
  [Tier.TIER_1]: 0,      // 0-300
  [Tier.TIER_2]: 301,    // 301-600
  [Tier.TIER_3]: 601,    // 601-900
  [Tier.TIER_4]: 901,    // 901-1200
  [Tier.TIER_5]: 1201,   // 1201-1500
  [Tier.TIER_6]: 1501    // 1501+
};

// Tier rarity percentages
export const TierRarities = {
  [Tier.TIER_1]: 0.4,    // 40%
  [Tier.TIER_2]: 0.3,    // 30%
  [Tier.TIER_3]: 0.2,    // 20%
  [Tier.TIER_4]: 0.08,   // 8%
  [Tier.TIER_5]: 0.015,  // 1.5%
  [Tier.TIER_6]: 0.005   // 0.5%
};


