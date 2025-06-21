# 23a-GenerateFormationService.ps1
# Generates Formation domain services with pattern library and caching

<#
.SYNOPSIS
    Generates comprehensive Formation domain with FormationService, FormationBlendingService, and data.
.DESCRIPTION
    1. Creates IFormationService and IFormationBlendingService interfaces
    2. Generates FormationService with pattern library and caching
    3. Creates FormationBlendingService for interpolation
    4. Copies formation geometry and pattern data
    5. Updates domain exports and integrates with composition root
.PARAMETER ProjectRoot
    Root directory of the project (defaults to current directory)
.PARAMETER SkipBackup
    Skip backing up existing files before overwriting
.EXAMPLE
    .\23a-GenerateFormationService.ps1 -ProjectRoot "C:\Projects\Protozoa"
.NOTES
    Implements comprehensive formation system with DI and caching
#>
param(
    [string]$ProjectRoot = $PWD,
    [switch]$SkipBackup
)

try { Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop } catch { Write-Error "utils import failed"; exit 1 }
$ErrorActionPreference = 'Stop'

try {
    Write-StepHeader "Formation Domain Services Generation"
    Write-InfoLog "🔺 Generating comprehensive Formation domain services..."
    
    # Validate project structure
    $formationDomain = Join-Path $ProjectRoot "src/domains/formation"
    if (-not (Test-Path $formationDomain)) {
        New-Item -Path $formationDomain -ItemType Directory -Force | Out-Null
        Write-InfoLog "Created formation domain directory"
    }
    
    $interfacesDir = Join-Path $formationDomain "interfaces"
    $servicesDir = Join-Path $formationDomain "services" 
    $typesDir = Join-Path $formationDomain "types"
    $dataDir = Join-Path $formationDomain "data"
    
    # Ensure directories exist
    foreach ($dir in @($interfacesDir, $servicesDir, $typesDir, $dataDir)) {
        if (-not (Test-Path $dir)) {
            New-Item -Path $dir -ItemType Directory -Force | Out-Null
            Write-InfoLog "Created directory: $dir"
        }
    }
    
    # Backup existing files if not skipped
    if (-not $SkipBackup) {
        $backupDir = Join-Path $ProjectRoot "backup/formation_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        New-Item -Path $backupDir -ItemType Directory -Force | Out-Null
        
        $filesToBackup = @(
            (Join-Path $interfacesDir "IFormationService.ts"),
            (Join-Path $interfacesDir "IFormationBlendingService.ts"),
            (Join-Path $servicesDir "FormationService.ts"),
            (Join-Path $servicesDir "formationBlendingService.ts"),
            (Join-Path $servicesDir "dynamicFormationGenerator.ts"),
            (Join-Path $servicesDir "formationEnhancer.ts")
        )
        
        foreach ($file in $filesToBackup) {
            if (Test-Path $file) {
                $backupFile = Join-Path $backupDir (Split-Path $file -Leaf)
                Copy-Item $file $backupFile -Force
                Write-InfoLog "Backed up: $(Split-Path $file -Leaf)"
            }
        }
    }
    
    # Copy interface templates
    Write-InfoLog "🔧 Copying formation interface templates..."
    
    $interfaceTemplates = @(
        @{ Template = "IFormationService.ts.template"; Target = "IFormationService.ts" },
        @{ Template = "IFormationBlendingService.ts.template"; Target = "IFormationBlendingService.ts" }
    )
    
    foreach ($template in $interfaceTemplates) {
        $templatePath = Join-Path $ProjectRoot "templates/domains/formation/interfaces/$($template.Template)"
        $targetPath = Join-Path $interfacesDir $template.Target
        
        if (Test-Path $templatePath) {
            Copy-Item $templatePath $targetPath -Force
            Write-SuccessLog "✅ Interface template → $($template.Target)"
        } else {
            Write-ErrorLog "Template not found: $templatePath"
        }
    }
    
    # Copy service templates
    Write-InfoLog "⚙️ Copying formation service templates..."
    
    $serviceTemplates = @(
        @{ Template = "FormationService.ts.template"; Target = "FormationService.ts" },
        @{ Template = "formationBlendingService.ts.template"; Target = "formationBlendingService.ts" },
        @{ Template = "dynamicFormationGenerator.ts.template"; Target = "dynamicFormationGenerator.ts" },
        @{ Template = "formationEnhancer.ts.template"; Target = "formationEnhancer.ts" }
    )
    
    foreach ($template in $serviceTemplates) {
        $templatePath = Join-Path $ProjectRoot "templates/domains/formation/services/$($template.Template)"
        $targetPath = Join-Path $servicesDir $template.Target
        
        if (Test-Path $templatePath) {
            Copy-Item $templatePath $targetPath -Force
            Write-SuccessLog "✅ Service template → $($template.Target)"
        } else {
            Write-ErrorLog "Template not found: $templatePath"
        }
    }
    
    # Copy data templates
    Write-InfoLog "📊 Copying formation data templates..."
    
    $dataTemplates = @(
        @{ Template = "formationGeometry.ts.template"; Target = "formationGeometry.ts" },
        @{ Template = "formationPatterns.ts.template"; Target = "formationPatterns.ts" }
    )
    
    foreach ($template in $dataTemplates) {
        $templatePath = Join-Path $ProjectRoot "templates/domains/formation/data/$($template.Template)"
        $targetPath = Join-Path $dataDir $template.Target
        
        if (Test-Path $templatePath) {
            Copy-Item $templatePath $targetPath -Force
            Write-SuccessLog "✅ Data template → $($template.Target)"
        } else {
            Write-WarningLog "Data template not found (will create basic): $templatePath"
            
            # Create basic data file if template missing
            if ($template.Target -eq "formationGeometry.ts") {
                $basicGeometry = @'
/**
 * Formation Geometry Data
 * Basic geometric patterns for particle formations
 */

export const FORMATION_GEOMETRIES = {
  sphere: { vertices: [], faces: [], radius: 1.0 },
  cube: { vertices: [], faces: [], size: 1.0 },
  pyramid: { vertices: [], faces: [], height: 1.0 },
  torus: { vertices: [], faces: [], majorRadius: 1.0, minorRadius: 0.3 }
} as const;
'@
                $basicGeometry | Set-Content -Path $targetPath -Encoding UTF8
            } elseif ($template.Target -eq "formationPatterns.ts") {
                $basicPatterns = @'
/**
 * Formation Patterns Data
 * Predefined formation patterns for particle systems
 */

export const FORMATION_PATTERNS = {
  spiral: { type: 'spiral', density: 0.8, rotation: 1.0 },
  grid: { type: 'grid', spacing: 2.0, dimensions: [10, 10, 10] },
  cluster: { type: 'cluster', centers: 3, radius: 5.0 },
  wave: { type: 'wave', amplitude: 2.0, frequency: 1.0 }
} as const;
'@
                $basicPatterns | Set-Content -Path $targetPath -Encoding UTF8
            }
            Write-SuccessLog "✅ Created basic data → $($template.Target)"
        }
    }
    
    # Create formation types if missing
    Write-InfoLog "📝 Creating formation types..."
    $formationTypes = Join-Path $typesDir "formation.types.ts"
    if (-not (Test-Path $formationTypes)) {
        $typesContent = @'
/**
 * Formation Types Definition
 * @module @/domains/formation/types/formation.types
 */

export interface IFormationPattern {
  id: string
  name: string
  type: 'geometric' | 'organic' | 'mathematical'
  complexity: number
  parameters: Record<string, any>
}

export interface IFormationGeometry {
  vertices: number[][]
  faces: number[][]
  normals?: number[][]
  uvs?: number[][]
}

export interface FormationConfig {
  pattern: string
  scale: number
  rotation: { x: number; y: number; z: number }
  position: { x: number; y: number; z: number }
  particleCount: number
}

export type FormationType = 'sphere' | 'cube' | 'pyramid' | 'torus' | 'spiral' | 'grid' | 'cluster' | 'wave'
'@
        $typesContent | Set-Content -Path $formationTypes -Encoding UTF8
        Write-SuccessLog "✅ Created formation types"
    }
    
    # Update formation domain index exports
    Write-InfoLog "📝 Updating formation domain exports..."
    $domainIndex = Join-Path $formationDomain "index.ts"
    $indexContent = @"
/**
 * @fileoverview Formation Domain Exports
 * @module @/domains/formation
 */

// Service exports
export { FormationService } from './services/FormationService'
export { formationBlendingService } from './services/formationBlendingService'
export { dynamicFormationGenerator } from './services/dynamicFormationGenerator'
export { formationEnhancer } from './services/formationEnhancer'

// Interface exports  
export type { IFormationService } from './interfaces/IFormationService'
export type { IFormationBlendingService } from './interfaces/IFormationBlendingService'

// Type exports
export type { 
  IFormationPattern,
  IFormationGeometry,
  FormationConfig,
  FormationType
} from './types/formation.types'

// Data exports
export { FORMATION_GEOMETRIES } from './data/formationGeometry'
export { FORMATION_PATTERNS } from './data/formationPatterns'
"@
    
    $indexContent | Set-Content -Path $domainIndex -Encoding UTF8
    Write-SuccessLog "✅ Updated domain exports → $domainIndex"
    
    # Verify TypeScript compilation
    Write-InfoLog "🔍 Verifying TypeScript compilation..."
    Push-Location $ProjectRoot
    try {
        $result = & npx tsc --noEmit --skipLibCheck 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-SuccessLog "✅ TypeScript compilation successful"
        } else {
            Write-WarningLog "⚠️ TypeScript compilation has issues: $result"
        }
    } catch {
        Write-WarningLog "⚠️ Could not verify TypeScript compilation: $_"
    } finally {
        Pop-Location
    }
    
    Write-SuccessLog "🎉 Formation domain services generated successfully!"
    Write-InfoLog "🔧 Components created:"
    Write-InfoLog "  • FormationService with pattern library and caching"
    Write-InfoLog "  • FormationBlendingService for interpolation"
    Write-InfoLog "  • DynamicFormationGenerator for runtime patterns"
    Write-InfoLog "  • FormationEnhancer for optimization"
    Write-InfoLog "  • Formation geometry and pattern data"
    Write-InfoLog "  • Comprehensive TypeScript interfaces"
    
    exit 0
    
} catch {
    Write-ErrorLog "❌ Formation domain generation failed: $_"
    Write-DebugLog "Stack trace: $($_.ScriptStackTrace)"
    exit 1
} 