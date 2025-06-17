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
    Write-InfoLog "Generating main tsconfig.json with strict validation"
    $mainTsConfig = @{
        compilerOptions = @{
            # Strict type checking options
            strict = $true
            noImplicitAny = $true
            strictNullChecks = $true
            strictFunctionTypes = $true
            strictBindCallApply = $true
            strictPropertyInitialization = $true
            noImplicitReturns = $true
            noFallthroughCasesInSwitch = $true
            noUncheckedIndexedAccess = $true
            
            # Module resolution
            target = "ES2022"
            lib = @("ES2022", "DOM", "DOM.Iterable")
            allowJs = $false
            skipLibCheck = $false
            esModuleInterop = $true
            allowSyntheticDefaultImports = $true
            forceConsistentCasingInFileNames = $true
            
            # Path mapping for domain boundaries
            baseUrl = "."
            paths = @{
                "@/*" = @("./src/*")
                "@/domains/*" = @("./src/domains/*")
                "@/shared/*" = @("./src/shared/*")
                "@/components/*" = @("./src/components/*")
                "@/lib/*" = @("./src/lib/*")
                "@/types/*" = @("./src/types/*")
            }
            
            # Output and module settings
            module = "ESNext"
            moduleResolution = "bundler"
            resolveJsonModule = $true
            isolatedModules = $true
            noEmit = $true
            jsx = "react-jsx"
            
            # Advanced options for performance
            incremental = $true
            composite = $false
            declaration = $true
            declarationMap = $true
            sourceMap = $true
        }
        
        # Include/exclude patterns
        include = @(
            "src/**/*"
            "vite.config.ts"
        )
        
        exclude = @(
            "node_modules"
            "dist"
            "build"
            "scripts"
            "**/*.test.ts"
            "**/*.test.tsx"
            "**/*.spec.ts"
            "**/*.spec.tsx"
        )
        
        # TypeScript references for better performance
        references = @(
            @{ path = "./tsconfig.app.json" }
            @{ path = "./tsconfig.node.json" }
        )
    }
    
    $mainTsConfigJson = $mainTsConfig | ConvertTo-Json -Depth 10
    Set-Content -Path $tsConfigPath -Value $mainTsConfigJson -Encoding UTF8
    Write-SuccessLog "Main tsconfig.json generated with strict settings"
    
    # Generate tsconfig.app.json for application code
    Write-InfoLog "Generating tsconfig.app.json for application code"
    $appTsConfig = @{
        extends = "./tsconfig.json"
        compilerOptions = @{
            composite = $true
            tsBuildInfoFile = "./node_modules/.tmp/tsconfig.app.tsbuildinfo"
        }
        include = @(
            "src/**/*"
        )
        exclude = @(
            "src/**/*.test.ts"
            "src/**/*.test.tsx"
            "src/**/*.spec.ts"  
            "src/**/*.spec.tsx"
            "node_modules"
        )
    }
    
    $appTsConfigJson = $appTsConfig | ConvertTo-Json -Depth 10
    Set-Content -Path $tsConfigAppPath -Value $appTsConfigJson -Encoding UTF8
    Write-SuccessLog "tsconfig.app.json generated for application code"
    
    # Generate tsconfig.node.json for build tools
    Write-InfoLog "Generating tsconfig.node.json for build tools"
    $nodeTsConfig = @{
        extends = "./tsconfig.json"
        compilerOptions = @{
            composite = $true
            skipLibCheck = $true
            module = "ESNext"
            moduleResolution = "bundler"
            allowSyntheticDefaultImports = $true
            tsBuildInfoFile = "./node_modules/.tmp/tsconfig.node.tsbuildinfo"
        }
        include = @(
            "vite.config.ts"
            "scripts/**/*"
        )
        exclude = @(
            "src/**/*"
        )
    }
    
    $nodeTsConfigJson = $nodeTsConfig | ConvertTo-Json -Depth 10
    Set-Content -Path $tsConfigNodePath -Value $nodeTsConfigJson -Encoding UTF8
    Write-SuccessLog "tsconfig.node.json generated for build tools"
    
    # Create custom type definitions for Bitcoin Ordinals API
    Write-InfoLog "Creating custom type definitions for Bitcoin Ordinals API"
    $typesDir = Join-Path $srcPath "types"
    New-Item -Path $typesDir -ItemType Directory -Force | Out-Null
    
    $ordinalsTypes = @"
/**
 * @fileoverview Bitcoin Ordinals API Type Definitions
 * @description Custom TypeScript definitions for Bitcoin Ordinals Protocol
 * @author Protozoa Development Team
 * @version 1.0.0
 */

declare namespace BitcoinOrdinals {
  interface BlockInfo {
    hash: string;
    height: number;
    timestamp: number;
    difficulty: number;
    nonce: number;
    merkleroot: string;
    previousblockhash?: string;
    nextblockhash?: string;
    size: number;
    weight: number;
    version: number;
    versionHex: string;
    bits: string;
    chainwork: string;
    nTx: number;
    mediantime: number;
  }

  interface InscriptionContent {
    content_type: string;
    content_length: number;
    content: string | ArrayBuffer;
    inscription_id: string;
    inscription_number: number;
    genesis_height: number;
    genesis_fee: number;
    output_value: number;
    address?: string;
    sat?: number;
    timestamp: number;
  }

  interface APIResponse<T> {
    success: boolean;
    data?: T;
    error?: string;
    timestamp: number;
  }
}

// Extend Window interface for browser environment
declare global {
  interface Window {
    BitcoinOrdinals?: typeof BitcoinOrdinals;
  }
}

export {};
"@
    
    Set-Content -Path (Join-Path $typesDir "bitcoin-ordinals.d.ts") -Value $ordinalsTypes -Encoding UTF8
    Write-SuccessLog "Bitcoin Ordinals API type definitions created"
    
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