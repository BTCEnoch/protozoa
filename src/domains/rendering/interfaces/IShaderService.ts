import type * as THREE from 'three'

export interface IShaderService {
  compile(name: string, vertexSrc: string, fragmentSrc: string): THREE.ShaderMaterial
  get(name: string): THREE.ShaderMaterial | undefined
  hotReload(name: string, newFrag: string): void
  dispose(): void
}
