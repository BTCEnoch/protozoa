/**
 * @fileoverview Simulation Store - Zustand State Management
 * @description Global state management for simulation control and formation patterns
 * @author Protozoa Development Team
 * @version 1.0.0
 */

import { create } from 'zustand'

/**
 * Simulation control state interface
 */
interface SimulationState { 
  /** Whether simulation is currently running */
  running: boolean
  /** Currently active formation pattern ID */
  formation: string | null
  /** Set simulation running state */
  setRunning: (running: boolean) => void
  /** Set active formation pattern */
  setFormation: (formation: string | null) => void 
}

/**
 * Simulation store using Zustand v4 syntax
 * Manages global simulation state and formation patterns across the application
 */
export const useSimulationStore = create<SimulationState>()((set) => ({
  running: false,
  formation: null,
  setRunning: (running: boolean) => set({ running }),
  setFormation: (formation: string | null) => set({ formation })
}))