# 23-GenerateRNGService.ps1 - Phase 2 Core Domain Implementation
# Generates RNGService domain files from templates (no inline TypeScript code)
# Reference: build_design.md Phase 2 guidelines
# Requires PowerShell 5.1 or later

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $false)]
    [string]$ProjectRoot = $PWD
)

try {
    Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop
} catch {
    Write-Error "Failed to import utilities module: $($_.Exception.Message)"
    exit 1
}

$ErrorActionPreference = "Stop"

try {
    Write-StepHeader "RNG Service Generation - Phase 2 Core Domain Implementation"
    Write-InfoLog "Generating RNGService domain files via templates"

    # Domain paths
    $rngDomainPath  = Join-Path $ProjectRoot "src/domains/rng"
    $servicesPath   = Join-Path $rngDomainPath "services"
    $typesPath      = Join-Path $rngDomainPath "types"
    $interfacesPath = Join-Path $rngDomainPath "interfaces"
    $utilsPath      = Join-Path $rngDomainPath "utils"

    # Ensure directory structure
    Write-InfoLog "Creating RNG domain directory structure"
    foreach ($path in @($servicesPath, $typesPath, $interfacesPath, $utilsPath)) {
        New-Item -Path $path -ItemType Directory -Force | Out-Null
    }
    Write-SuccessLog "RNG domain directories created successfully"

    function Copy-Template {
        param(
            [string]$TemplateRel,
            [string]$DestPath
        )
        $templatePath = Join-Path $ProjectRoot $TemplateRel
        Copy-Item -Path $templatePath -Destination $DestPath -Force
    }

    # 1. Interface
    Write-InfoLog "Copying IRNGService interface from template"
    Copy-Template "templates/domains/rng/interfaces/IRNGService.ts.template" (Join-Path $interfacesPath "IRNGService.ts")
    Write-SuccessLog "IRNGService generated"

    # 2. Types
    Write-InfoLog "Copying rng.types definitions from template"
    Copy-Template "templates/domains/rng/types/rng.types.ts.template" (Join-Path $typesPath "rng.types.ts")
    Write-SuccessLog "rng.types generated"

    # 3. Service implementation
    Write-InfoLog "Copying RNGService implementation from template"
    Copy-Template "templates/domains/rng/services/RNGService.ts.template" (Join-Path $servicesPath "RNGService.ts")
    Write-SuccessLog "RNGService generated"

    # 4. Domain index
    Write-InfoLog "Generating RNG domain export index"
    $index = @'
/**
 * @fileoverview RNG Domain Exports
 * @version 1.0.0
 */

export { RNGService, rngService } from "./services/RNGService"

export type {
  IRNGService,
  RNGConfig,
  RNGState,
  RNGOptions
} from "./interfaces/IRNGService"

export type {
  PRNGAlgorithm,
  SeedSource,
  RNGMetrics
} from "./types/rng.types"
'@
    Set-Content -Path (Join-Path $rngDomainPath "index.ts") -Value $index -Encoding UTF8
    Write-SuccessLog "RNG domain export index generated"

    Write-SuccessLog "RNG Service generation completed successfully"
    Write-InfoLog "Generated files:"
    Write-InfoLog "  - src/domains/rng/interfaces/IRNGService.ts"
    Write-InfoLog "  - src/domains/rng/types/rng.types.ts"
    Write-InfoLog "  - src/domains/rng/services/RNGService.ts"
    Write-InfoLog "  - src/domains/rng/index.ts"

    exit 0
} catch {
    Write-ErrorLog "RNG Service generation failed: $($_.Exception.Message)"
    exit 1
} finally {
    try { Pop-Location -ErrorAction SilentlyContinue } catch { }
}
