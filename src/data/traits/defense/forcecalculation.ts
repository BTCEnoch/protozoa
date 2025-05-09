// Generated from group_traits/trait_banks/force_calculation/defense_force_traits.json
// DO NOT EDIT MANUALLY - This file is generated by scripts/generate_trait_data_better.ps1

import { ForceCalculationTrait } from '../../../types/traits/trait';
import { Role, Rarity, ForceType, FalloffType } from '../../../types/core';

export const DEFENSE_FORCE_CALCULATION_TRAITS = [
    {
      "name": "Protective Cohesion",
      "description": "Particles maintain protective cohesion",
      "rarityTier": "Common",
      "type": "Cohesion",
      "strengthMultiplier": 1.4,
      "rangeMultiplier": 1.2,
      "falloff": "linear",
      "physicsLogic": {
        "forceFunction": "protectiveCohesion",
        "thresholdDistance": 4,
        "maxForce": 6
      },
      "visualEffects": {
        "forceVisualization": true,
        "forceColor": "#33cc33"
      },
      "evolutionParameters": {
        "mutationChance": 0.05,
        "possibleEvolutions": [
          "Barrier Cohesion",
          "Resilient Bond"
        ]
      }
    },
    {
      "name": "Barrier Cohesion",
      "description": "Particles form cohesive barriers",
      "rarityTier": "Uncommon",
      "type": "Cohesion",
      "strengthMultiplier": 1.5,
      "rangeMultiplier": 1.3,
      "falloff": "quadratic",
      "physicsLogic": {
        "forceFunction": "barrierCohesion",
        "thresholdDistance": 4.2,
        "maxForce": 6.5
      },
      "visualEffects": {
        "forceVisualization": true,
        "forceColor": "#55dd55"
      },
      "evolutionParameters": {
        "mutationChance": 0.05,
        "possibleEvolutions": [
          "Resilient Bond",
          "Adaptive Shield"
        ]
      }
    },
    {
      "name": "Resilient Bond",
      "description": "Particles form resilient cohesive bonds",
      "rarityTier": "Rare",
      "type": "Cohesion",
      "strengthMultiplier": 1.6,
      "rangeMultiplier": 1.4,
      "falloff": "exponential",
      "physicsLogic": {
        "forceFunction": "resilientBond",
        "thresholdDistance": 4.4,
        "maxForce": 7
      },
      "visualEffects": {
        "forceVisualization": true,
        "forceColor": "#77ee77"
      },
      "evolutionParameters": {
        "mutationChance": 0.05,
        "possibleEvolutions": [
          "Adaptive Shield",
          "Absorption Matrix"
        ]
      }
    },
    {
      "name": "Adaptive Shield",
      "description": "Particles form adaptively cohesive shields",
      "rarityTier": "Rare",
      "type": "Cohesion",
      "strengthMultiplier": 1.7,
      "rangeMultiplier": 1.5,
      "falloff": "exponential",
      "physicsLogic": {
        "forceFunction": "adaptiveShield",
        "thresholdDistance": 4.6,
        "maxForce": 7.5
      },
      "visualEffects": {
        "forceVisualization": true,
        "forceColor": "#99ff99"
      },
      "evolutionParameters": {
        "mutationChance": 0.05,
        "possibleEvolutions": [
          "Absorption Matrix",
          "Temporal Barrier"
        ]
      }
    },
    {
      "name": "Absorption Matrix",
      "description": "Particles form a cohesive energy absorption matrix",
      "rarityTier": "Epic",
      "type": "Cohesion",
      "strengthMultiplier": 1.8,
      "rangeMultiplier": 1.6,
      "falloff": "exponential",
      "physicsLogic": {
        "forceFunction": "absorptionMatrix",
        "thresholdDistance": 4.8,
        "maxForce": 8
      },
      "visualEffects": {
        "forceVisualization": true,
        "forceColor": "#aaffaa"
      },
      "evolutionParameters": {
        "mutationChance": 0.05,
        "possibleEvolutions": [
          "Temporal Barrier",
          "Quantum Shield"
        ]
      }
    },
    {
      "name": "Temporal Barrier",
      "description": "Particles form temporally cohesive barriers",
      "rarityTier": "Epic",
      "type": "Cohesion",
      "strengthMultiplier": 1.9,
      "rangeMultiplier": 1.7,
      "falloff": "quantum",
      "physicsLogic": {
        "forceFunction": "temporalBarrier",
        "thresholdDistance": 5,
        "maxForce": 8.5
      },
      "visualEffects": {
        "forceVisualization": true,
        "forceColor": "#bbffbb"
      },
      "evolutionParameters": {
        "mutationChance": 0.05,
        "possibleEvolutions": [
          "Quantum Shield",
          "Reality Anchor"
        ]
      }
    },
    {
      "name": "Quantum Shield",
      "description": "Particles form quantum cohesive shields",
      "rarityTier": "Legendary",
      "type": "Cohesion",
      "strengthMultiplier": 2,
      "rangeMultiplier": 1.8,
      "falloff": "quantum",
      "physicsLogic": {
        "forceFunction": "quantumShield",
        "thresholdDistance": 5.2,
        "maxForce": 9
      },
      "visualEffects": {
        "forceVisualization": true,
        "forceColor": "#ccffcc"
      },
      "evolutionParameters": {
        "mutationChance": 0.05,
        "possibleEvolutions": [
          "Reality Anchor",
          "Dimensional Fortress"
        ]
      }
    },
    {
      "name": "Reality Anchor",
      "description": "Particles anchor reality with cohesive forces",
      "rarityTier": "Legendary",
      "type": "Cohesion",
      "strengthMultiplier": 2.1,
      "rangeMultiplier": 1.9,
      "falloff": "quantum",
      "physicsLogic": {
        "forceFunction": "realityAnchor",
        "thresholdDistance": 5.4,
        "maxForce": 9.5
      },
      "visualEffects": {
        "forceVisualization": true,
        "forceColor": "#ddffdd"
      },
      "evolutionParameters": {
        "mutationChance": 0.05,
        "possibleEvolutions": [
          "Dimensional Fortress",
          "Cosmic Aegis"
        ]
      }
    },
    {
      "name": "Dimensional Fortress",
      "description": "Particles form dimensionally cohesive fortresses",
      "rarityTier": "Mythic",
      "type": "Cohesion",
      "strengthMultiplier": 2.2,
      "rangeMultiplier": 2,
      "falloff": "quantum",
      "physicsLogic": {
        "forceFunction": "dimensionalFortress",
        "thresholdDistance": 5.6,
        "maxForce": 10
      },
      "visualEffects": {
        "forceVisualization": true,
        "forceColor": "#eeffee"
      },
      "evolutionParameters": {
        "mutationChance": 0.05,
        "possibleEvolutions": [
          "Cosmic Aegis"
        ]
      }
    },
    {
      "name": "Cosmic Aegis",
      "description": "Particles form a cosmic-scale cohesive aegis",
      "rarityTier": "Mythic",
      "type": "Cohesion",
      "strengthMultiplier": 2.3,
      "rangeMultiplier": 2.1,
      "falloff": "quantum",
      "physicsLogic": {
        "forceFunction": "cosmicAegis",
        "thresholdDistance": 5.8,
        "maxForce": 10.5
      },
      "visualEffects": {
        "forceVisualization": true,
        "forceColor": "#ffffff"
      },
      "evolutionParameters": {
        "mutationChance": 0.05,
        "possibleEvolutions": [
          "Dimensional Fortress"
        ]
      }
    }
  ];

export default DEFENSE_FORCE_CALCULATION_TRAITS;





