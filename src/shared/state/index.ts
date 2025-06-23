/**
 * @fileoverview Shared State Management Exports
 * @description Centralized exports for all Zustand stores
 * @author Protozoa Automation Suite
 * @generated Generated from template
 */

// Zustand stores
export { useSimulationStore } from './useSimulationStore'
export { useParticleStore } from './useParticleStore'

// Store types (these should match the actual store interfaces)
export type { SimulationState } from './useSimulationStore'
export type { ParticleUIState } from './useParticleStore'
export type { ParticleInstance } from './useParticleStore'

// Backward compatibility aliases
export type { ParticleUIState as ParticleState } from './useParticleStore' 
