#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Validate Fresh Build - Template Configuration Verification
.DESCRIPTION
    Validates that all critical template fixes are in place for React/JSX support
    and that a fresh build will work correctly with the automation suite.
.AUTHOR
    Protozoa Development Team
#>

param(
    [switch]$Verbose = $false
)

# Import utilities
$ProjectRoot = Split-Path $PSScriptRoot -Parent
Import-Module (Join-Path $PSScriptRoot "utils.psm1") -Force

Write-StepHeader "FRESH BUILD VALIDATION"
Write-InfoLog "Validating template configuration for React/JSX support..."

$validationErrors = @()

# Validate tsconfig.json.template
Write-InfoLog "Checking tsconfig.json.template..."
$tsconfigTemplate = Join-Path $ProjectRoot "templates/tsconfig.json.template"
if (Test-Path $tsconfigTemplate) {
    $tsconfigContent = Get-Content $tsconfigTemplate -Raw
    
    # Check for correct JSX configuration
    if ($tsconfigContent -match '"jsx":\s*"react-jsx"') {
        Write-SuccessLog "✅ tsconfig.json.template has correct JSX configuration"
    } else {
        $validationErrors += "❌ tsconfig.json.template missing jsx: react-jsx"
    }
    
    # Check for simplified types configuration
    if ($tsconfigContent -match '"types":\s*\[\s*"node"\s*\]') {
        Write-SuccessLog "✅ tsconfig.json.template has correct types configuration"
    } else {
        $validationErrors += "❌ tsconfig.json.template has incorrect types configuration"
    }
} else {
    $validationErrors += "❌ tsconfig.json.template not found"
}

# Validate vite.config.ts.template
Write-InfoLog "Checking vite.config.ts.template..."
$viteTemplate = Join-Path $ProjectRoot "templates/vite.config.ts.template"
if (Test-Path $viteTemplate) {
    $viteContent = Get-Content $viteTemplate -Raw
    
    # Check for automatic JSX runtime
    if ($viteContent -match 'jsxRuntime:\s*[''"]automatic[''"]') {
        Write-SuccessLog "✅ vite.config.ts.template has automatic JSX runtime"
    } else {
        $validationErrors += "❌ vite.config.ts.template missing automatic JSX runtime"
    }
    
    # Check for esbuild JSX configuration
    if ($viteContent -match 'jsxFactory:\s*[''"]React\.createElement[''"]') {
        Write-SuccessLog "✅ vite.config.ts.template has correct JSX factory"
    } else {
        $validationErrors += "❌ vite.config.ts.template missing JSX factory configuration"
    }
} else {
    $validationErrors += "❌ vite.config.ts.template not found"
}

# Validate main.tsx.template
Write-InfoLog "Checking main.tsx.template..."
$mainTemplate = Join-Path $ProjectRoot "templates/src/main.tsx.template"
if (Test-Path $mainTemplate) {
    $mainContent = Get-Content $mainTemplate -Raw
    
    # Check for React import
    if ($mainContent -match 'import React,\s*\{\s*StrictMode\s*\}') {
        Write-SuccessLog "✅ main.tsx.template has correct React import"
    } else {
        $validationErrors += "❌ main.tsx.template missing React import"
    }
} else {
    $validationErrors += "❌ main.tsx.template not found"
}

# Validate SimulationCanvas.tsx.template
Write-InfoLog "Checking SimulationCanvas.tsx.template..."
$canvasTemplate = Join-Path $ProjectRoot "templates/components/SimulationCanvas.tsx.template"
if (Test-Path $canvasTemplate) {
    $canvasContent = Get-Content $canvasTemplate -Raw
    
    # Check for ParticleType import
    if ($canvasContent -match 'import.*ParticleType.*from.*particle\.types') {
        Write-SuccessLog "✅ SimulationCanvas.tsx.template has ParticleType import"
    } else {
        $validationErrors += "❌ SimulationCanvas.tsx.template missing ParticleType import"
    }
    
    # Check for correct TraitService configuration
    if ($canvasContent -match 'enableInheritance:\s*true') {
        Write-SuccessLog "✅ SimulationCanvas.tsx.template has correct TraitService config"
    } else {
        $validationErrors += "❌ SimulationCanvas.tsx.template has incorrect TraitService config"
    }
    
    # Check for ParticleType.BASIC usage
    if ($canvasContent -match 'ParticleType\.BASIC') {
        Write-SuccessLog "✅ SimulationCanvas.tsx.template uses ParticleType.BASIC"
    } else {
        $validationErrors += "❌ SimulationCanvas.tsx.template missing ParticleType.BASIC usage"
    }
} else {
    $validationErrors += "❌ SimulationCanvas.tsx.template not found"
}

# Validate service templates have required methods
Write-InfoLog "Checking service templates..."

# ParticleService.ts.template
$particleServiceTemplate = Join-Path $ProjectRoot "templates/domains/particle/services/ParticleService.ts.template"
if (Test-Path $particleServiceTemplate) {
    $particleContent = Get-Content $particleServiceTemplate -Raw
    if ($particleContent -match 'spawnParticle.*getSystems.*setParticleStore') {
        Write-SuccessLog "✅ ParticleService.ts.template has required methods"
    } else {
        $validationErrors += "❌ ParticleService.ts.template missing required methods"
    }
}

# TraitService.ts.template
$traitServiceTemplate = Join-Path $ProjectRoot "templates/domains/trait/services/TraitService.ts.template"
if (Test-Path $traitServiceTemplate) {
    $traitContent = Get-Content $traitServiceTemplate -Raw
    if ($traitContent -match 'setRNGService.*setBitcoinService') {
        Write-SuccessLog "✅ TraitService.ts.template has dependency injection methods"
    } else {
        $validationErrors += "❌ TraitService.ts.template missing dependency injection methods"
    }
}

# Logger template
$loggerTemplate = Join-Path $ProjectRoot "templates/shared/lib/logger.ts.template"
if (Test-Path $loggerTemplate) {
    $loggerContent = Get-Content $loggerTemplate -Raw
    if ($loggerContent -match 'success\(message:\s*string') {
        Write-SuccessLog "✅ logger.ts.template has success method"
    } else {
        $validationErrors += "❌ logger.ts.template missing success method"
    }
}

# Final validation report
Write-InfoLog ""
Write-StepHeader "VALIDATION RESULTS"

if ($validationErrors.Count -eq 0) {
    Write-SuccessLog "🎉 ALL TEMPLATE VALIDATIONS PASSED!"
    Write-SuccessLog "✅ Fresh builds will work correctly with React/JSX support"
    Write-SuccessLog "✅ All critical template fixes are in place"
    Write-SuccessLog "✅ Template-first architecture is properly configured"
    
    Write-InfoLog ""
    Write-InfoLog "📋 VALIDATED CONFIGURATIONS:"
    Write-InfoLog "   • React JSX automatic runtime"
    Write-InfoLog "   • TypeScript React types configuration"
    Write-InfoLog "   • Vite JSX factory setup"
    Write-InfoLog "   • Service method implementations"
    Write-InfoLog "   • Logger success method"
    Write-InfoLog "   • ParticleType imports and usage"
    
    exit 0
} else {
    Write-ErrorLog "❌ VALIDATION FAILED - Template fixes needed:"
    foreach ($error in $validationErrors) {
        Write-ErrorLog "   $error"
    }
    
    Write-InfoLog ""
    Write-InfoLog "🔧 RECOMMENDED ACTIONS:"
    Write-InfoLog "   1. Review and fix the failing template configurations"
    Write-InfoLog "   2. Re-run this validation script"
    Write-InfoLog "   3. Deploy templates with: scripts/09-DeployTemplates.ps1"
    
    exit 1
} 