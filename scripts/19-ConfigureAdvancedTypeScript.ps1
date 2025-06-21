# 19-ConfigureAdvancedTypeScript.ps1 - Phase 1 Infrastructure Enhancement
# Configures advanced TypeScript settings with strict validation and path mapping
# ARCHITECTURE: Domain boundary enforcement through TypeScript configuration
# Reference: script_checklist.md lines 19-ConfigureAdvancedTypeScript.ps1
# Reference: build_design.md lines 2000-2020 - Advanced TypeScript configuration requirements
#Requires -Version 5.1

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $false)]
    [string]$ProjectRoot = (Split-Path $PSScriptRoot -Parent)
)

try {
    Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop
}
catch {
    Write-Error "Failed to import utilities module: $($_.Exception.Message)"
    exit 1
}

$ErrorActionPreference = "Stop"

try {
    Write-StepHeader "Advanced TypeScript Configuration - Phase 1 Infrastructure Enhancement"
    Write-InfoLog "Configuring strict TypeScript settings with domain boundary enforcement"

    # Define paths
    $srcPath = Join-Path $ProjectRoot "src"
    $tsConfigPath = Join-Path $ProjectRoot "tsconfig.json"
    $tsConfigAppPath = Join-Path $ProjectRoot "tsconfig.app.json"
    $tsConfigNodePath = Join-Path $ProjectRoot "tsconfig.node.json"

    # Ensure src directory exists
    if (-not (Test-Path $srcPath)) {
        New-Item -Path $srcPath -ItemType Directory -Force | Out-Null
        Write-InfoLog "Created src directory structure"
    }

    Write-SuccessLog "Advanced TypeScript configuration setup initialized"

    # Generate main tsconfig.json with strict settings
    # Copy main tsconfig.json from template ONLY
    Write-InfoLog "Copying main tsconfig.json from template"
    $tsConfigTemplate = Join-Path $ProjectRoot "templates/tsconfig.json.template"
    if (Test-Path $tsConfigTemplate) {
        Copy-Item -Path $tsConfigTemplate -Destination $tsConfigPath -Force
        Write-SuccessLog "Main tsconfig.json copied from template"
    } else {
        Write-ErrorLog "CRITICAL: tsconfig.json template not found at $tsConfigTemplate"
        Write-ErrorLog "All configurations must use templates - no inline generation allowed"
        throw "Required template file missing: tsconfig.json.template"
    }

    # Copy tsconfig.app.json from template ONLY
    Write-InfoLog "Copying tsconfig.app.json from template"
    $tsConfigAppTemplate = Join-Path $ProjectRoot "templates/tsconfig.app.json.template"
    if (Test-Path $tsConfigAppTemplate) {
        Copy-Item -Path $tsConfigAppTemplate -Destination $tsConfigAppPath -Force
        Write-SuccessLog "tsconfig.app.json copied from template"
    } else {
        Write-ErrorLog "CRITICAL: tsconfig.app.json template not found at $tsConfigAppTemplate"
        Write-ErrorLog "All configurations must use templates - no inline generation allowed"
        throw "Required template file missing: tsconfig.app.json.template"
    }

    # Copy tsconfig.node.json from template ONLY
    Write-InfoLog "Copying tsconfig.node.json from template"
    $tsConfigNodeTemplate = Join-Path $ProjectRoot "templates/tsconfig.node.json.template"
    if (Test-Path $tsConfigNodeTemplate) {
        Copy-Item -Path $tsConfigNodeTemplate -Destination $tsConfigNodePath -Force
        Write-SuccessLog "tsconfig.node.json copied from template"
    } else {
        Write-ErrorLog "CRITICAL: tsconfig.node.json template not found at $tsConfigNodeTemplate"
        Write-ErrorLog "All configurations must use templates - no inline generation allowed"
        throw "Required template file missing: tsconfig.node.json.template"
    }

    # Copy Bitcoin Ordinals type definitions from template ONLY
    Write-InfoLog "Copying Bitcoin Ordinals type definitions from template"
    $typesDir = Join-Path $srcPath "types"
    New-Item -Path $typesDir -ItemType Directory -Force | Out-Null
    
    $bitcoinTypesTemplate = Join-Path $ProjectRoot "templates/src/types/bitcoin-ordinals.d.ts.template"
    $bitcoinTypesTarget = Join-Path $typesDir "bitcoin-ordinals.d.ts"
    
    if (Test-Path $bitcoinTypesTemplate) {
        Copy-Item -Path $bitcoinTypesTemplate -Destination $bitcoinTypesTarget -Force
        Write-SuccessLog "Bitcoin Ordinals type definitions copied from template"
    } else {
        Write-ErrorLog "CRITICAL: bitcoin-ordinals.d.ts template not found at $bitcoinTypesTemplate"
        Write-ErrorLog "All type definitions must use templates - no inline generation allowed"
        throw "Required template file missing: bitcoin-ordinals.d.ts.template"
    }

    Write-InfoLog "Advanced TypeScript configuration setup completed"

    exit 0
}
catch {
    Write-ErrorLog "Advanced TypeScript configuration failed: $($_.Exception.Message)"
    exit 1
}
finally {
    try { Pop-Location -ErrorAction SilentlyContinue } catch { }
}