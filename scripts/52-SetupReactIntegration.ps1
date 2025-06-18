# 52-SetupReactIntegration.ps1 - Phase 8 UI
# Sets up React components for simulation canvas and control UI
#Requires -Version 5.1
[CmdletBinding()]
param([string]$ProjectRoot=(Split-Path $PSScriptRoot -Parent))
try{Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop}catch{Write-Error $_;exit 1}
$ErrorActionPreference='Stop'
try{
 Write-StepHeader "React Integration Setup"
 $compDir=Join-Path $ProjectRoot 'src/components'
 New-Item -Path $compDir -ItemType Directory -Force | Out-Null
 # SimulationCanvas
 $canvas=@"
'use client'
"@
import { Canvas, useFrame } from '@react-three/fiber'
import { Suspense } from 'react'
import { renderingService } from '@/domains/rendering/services/renderingService'

export function SimulationCanvas(){
 return (
  <Canvas>
    <Suspense fallback={null}>
      <primitive object={renderingService.scene} />
    </Suspense>
  </Canvas>
 )
}
"@
 Set-Content -Path (Join-Path $compDir 'SimulationCanvas.tsx') -Value $canvas -Encoding UTF8
 # App component
 $app=@"
'use client'
"@
import { SimulationCanvas } from '@/components/SimulationCanvas'
import { initServices } from '@/compositionRoot'
import { useEffect } from 'react'

export default function App(){
 useEffect(()=>{initServices()},[])
 return (
  <div className="w-full h-screen">
    <SimulationCanvas />
  </div>
 )
}
"@
 Set-Content -Path (Join-Path $compDir 'App.tsx') -Value $app -Encoding UTF8
 Write-SuccessLog "React components generated"
 exit 0
}catch{Write-ErrorLog "React integration failed: $($_.Exception.Message)";exit 1}