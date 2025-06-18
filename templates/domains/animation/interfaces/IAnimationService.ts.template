/** IAnimationService Interface */
export interface AnimationConfig {
  duration: number
  easing?: 'linear' | 'ease-in' | 'ease-out' | 'ease-in-out'
  type: 'move' | 'scale' | 'rotation' | 'custom'
  [key: string]: unknown
}

export interface AnimationState {
  role: string
  progress: number
  duration: number
  type: string
}

export interface IAnimationService {
  startAnimation(role: string, config: AnimationConfig): void
  updateAnimations(delta: number): void
  stopAll(): void
  dispose(): void
}