/**
 * @fileoverview Effect Presets
 * @description Predefined effect configurations for common use cases
 */

import { EffectType, IEffectConfig } from '../interfaces/IEffectService'
import { Vector3 } from 'three'

export const EFFECT_PRESETS: Record<EffectType, IEffectConfig> = {
  nebula_burst: {
    duration: 2000,
    intensity: 0.8,
    fadeIn: 200,
    fadeOut: 800,
    scale: new Vector3(2, 2, 2),
    color: '#4A90E2',
    opacity: 0.7,
    particleCount: 150,
    animationSpeed: 1.2,
    blendMode: 'additive'
  },
  
  type_change_transition: {
    duration: 1500,
    intensity: 0.6,
    fadeIn: 300,
    fadeOut: 400,
    scale: new Vector3(1.5, 1.5, 1.5),
    color: '#7ED321',
    opacity: 0.8,
    particleCount: 80,
    animationSpeed: 1.0,
    blendMode: 'normal'
  },
  
  evolution_pulse: {
    duration: 3000,
    intensity: 1.0,
    fadeIn: 500,
    fadeOut: 1000,
    scale: new Vector3(3, 3, 3),
    color: '#F5A623',
    opacity: 0.9,
    particleCount: 200,
    animationSpeed: 0.8,
    blendMode: 'additive'
  },
  
  mutation_sparkle: {
    duration: 1000,
    intensity: 0.5,
    fadeIn: 100,
    fadeOut: 300,
    scale: new Vector3(0.8, 0.8, 0.8),
    color: '#BD10E0',
    opacity: 0.6,
    particleCount: 50,
    animationSpeed: 1.5,
    blendMode: 'screen'
  },
  
  formation_shift: {
    duration: 2500,
    intensity: 0.7,
    fadeIn: 400,
    fadeOut: 600,
    scale: new Vector3(2.5, 2.5, 2.5),
    color: '#50E3C2',
    opacity: 0.5,
    particleCount: 120,
    animationSpeed: 0.9,
    blendMode: 'overlay'
  },
  
  particle_trail: {
    duration: 5000,
    intensity: 0.4,
    fadeIn: 0,
    fadeOut: 2000,
    scale: new Vector3(0.5, 0.5, 0.5),
    color: '#9013FE',
    opacity: 0.4,
    particleCount: 30,
    animationSpeed: 2.0,
    blendMode: 'additive'
  },
  
  energy_wave: {
    duration: 1800,
    intensity: 0.9,
    fadeIn: 200,
    fadeOut: 500,
    scale: new Vector3(4, 4, 4),
    color: '#FF6D00',
    opacity: 0.6,
    particleCount: 100,
    animationSpeed: 1.3,
    blendMode: 'soft-light'
  },
  
  dissolve_effect: {
    duration: 3500,
    intensity: 0.6,
    fadeIn: 800,
    fadeOut: 1500,
    scale: new Vector3(1, 1, 1),
    color: '#37474F',
    opacity: 0.8,
    particleCount: 200,
    animationSpeed: 0.6,
    blendMode: 'multiply'
  }
}

export const MUTATION_EFFECT_MAPPINGS = {
  primaryColor: 'mutation_sparkle',
  secondaryColor: 'mutation_sparkle',
  size: 'evolution_pulse',
  speed: 'particle_trail',
  aggression: 'energy_wave',
  generation: 'evolution_pulse'
}
