/**
 * @fileoverview Particle Store - Zustand State Management
 * @description Global state management for particle selection and UI interactions
 * @author Protozoa Development Team
 * @version 1.0.0
 */

import { create } from 'zustand'

/**
 * Particle UI state interface
 */
interface ParticleUIState { 
  /** Currently selected particle ID */
  selected: string | null
  /** Select a particle by ID */
  select: (id: string | null) => void 
}

/**
 * Particle store using Zustand v4 syntax
 * Manages global particle selection state across the application
 */
export const useParticleStore = create<ParticleUIState>()((set) => ({
  selected: null,
  select: (id: string | null) => set({ selected: id })
}))
