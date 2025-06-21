/**
 * Color Palettes for Protozoa Digital Organisms
 * Auto-generated default palettes
 */

export const COLOR_PALETTES = {
  cosmic: {
    core: '#6366f1',
    energy: '#8b5cf6',
    barrier: '#06b6d4',
    mutation: '#f59e0b',
    background: '#0f172a',
  },
  organic: {
    core: '#10b981',
    energy: '#34d399',
    barrier: '#6ee7b7',
    mutation: '#fbbf24',
    background: '#064e3b',
  },
  neon: {
    core: '#ec4899',
    energy: '#f472b6',
    barrier: '#06d6a0',
    mutation: '#ffd60a',
    background: '#0c0a09',
  },
  monochrome: {
    core: '#ffffff',
    energy: '#d1d5db',
    barrier: '#9ca3af',
    mutation: '#fef08a',
    background: '#111827',
  },
} as const

export type PaletteName = keyof typeof COLOR_PALETTES
export type ColorRole = keyof typeof COLOR_PALETTES.cosmic
