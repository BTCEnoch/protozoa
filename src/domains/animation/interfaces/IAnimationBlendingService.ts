/**
* IAnimationBlendingService – provides blend-tree creation and state transitions.
*/
export interface BlendNode { id: string; weight: number; children?: BlendNode[] }
export interface IAnimationBlendingService {
  setBlendTree(root: BlendNode): void
  transition(toState: string, duration: number): void
  update(delta: number): void
  dispose(): void
}
