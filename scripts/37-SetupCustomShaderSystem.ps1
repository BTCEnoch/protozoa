# 37-SetupCustomShaderSystem.ps1 - Phase 5 Visual Enhancement
# Generates ShaderService and shader library for custom GLSL effects
# Reference: script_checklist.md lines 2400-2450
#Requires -Version 5.1

[CmdletBinding()]
param([string]$ProjectRoot=(Split-Path $PSScriptRoot -Parent))

try{Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop}catch{Write-Error $_;exit 1}
$ErrorActionPreference='Stop'

try{
 Write-StepHeader "Custom Shader System Setup"
 $renderPath=Join-Path $ProjectRoot 'src/domains/rendering'
 $services=Join-Path $renderPath 'services'
 $interfaces=Join-Path $renderPath 'interfaces'
 $data=Join-Path $renderPath 'data'
 New-Item -Path $services -ItemType Directory -Force | Out-Null
 New-Item -Path $interfaces -ItemType Directory -Force | Out-Null
 New-Item -Path $data -ItemType Directory -Force | Out-Null

 # Shader library
 $lib=@"// shaderLibrary.ts – collection of GLSL snippets
export const Shaders={
  dnaVis:`
    varying vec2 vUv;
    void main(){
      vec2 uv=vUv;
      float stripe=smoothstep(0.45,0.55,abs(sin(uv.y*20.0)));
      gl_FragColor=vec4(vec3(stripe),1.0);
    }
  `,
  particleInstancing:`
    attribute vec3 offset;
    void main(){
      vec3 pos=position+offset;
      gl_Position=projectionMatrix*modelViewMatrix*vec4(pos,1.0);
    }
  `
}
"@
 Set-Content -Path (Join-Path $data 'shaderLibrary.ts') -Value $lib -Encoding UTF8

 # Interface
 $iface=@"export interface IShaderService{
  compile(name:string,vertexSrc:string,fragmentSrc:string):THREE.ShaderMaterial
  get(name:string):THREE.ShaderMaterial|undefined
  hotReload(name:string,newFrag:string):void
  dispose():void
}
"@
 Set-Content -Path (Join-Path $interfaces 'IShaderService.ts') -Value $iface -Encoding UTF8

 # Implementation
 $impl=@"import * as THREE from 'three'
import { createServiceLogger } from '@/shared/lib/logger'
import { Shaders } from '@/domains/rendering/data/shaderLibrary'
import type { IShaderService } from '@/domains/rendering/interfaces/IShaderService'

class ShaderService implements IShaderService{
 static #instance:ShaderService|null=null
 #log=createServiceLogger('SHADER_SERVICE')
 #materials:Map<string,THREE.ShaderMaterial>=new Map()
 private constructor(){
  // precompile bundled shaders
  Object.entries(Shaders).forEach(([k,frag])=>{
   this.compile(k,'void main(){gl_Position=projectionMatrix*modelViewMatrix*vec4(position,1.0);}',frag as string)
  })
 }
 static getInstance(){return this.#instance??(this.#instance=new ShaderService())}
 compile(name:string,vertexSrc:string,fragmentSrc:string){
  const mat=new THREE.ShaderMaterial({vertexShader:vertexSrc,fragmentShader:fragmentSrc})
  this.#materials.set(name,mat)
  this.#log.info('Shader compiled',{name})
  return mat
 }
 get(name:string){return this.#materials.get(name)}
 hotReload(name:string,newFrag:string){
  const mat=this.#materials.get(name);if(!mat) return
  mat.fragmentShader=newFrag;mat.needsUpdate=true
  this.#log.warn('Shader hot-reloaded',{name})
 }
 dispose(){this.#materials.forEach(m=>m.dispose());this.#materials.clear();ShaderService.#instance=null}
}
export const shaderService=ShaderService.getInstance()
"@
 Set-Content -Path (Join-Path $services 'shaderService.ts') -Value $impl -Encoding UTF8

 Write-SuccessLog "Shader system generated"
 exit 0
}catch{Write-ErrorLog "Shader system generation failed: $($_.Exception.Message)";exit 1}