# 17-GenerateEnvironmentConfig.ps1 - Phase 1 Critical
# Generates EnvironmentService, envUtils and shared logger from templates (no inline TypeScript)

[CmdletBinding(SupportsShouldProcess)]
param(
  [Parameter(Mandatory = $false)]
  [string]$ProjectRoot = $PWD
)

try { Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop } catch {
  Write-Error "Failed to import utils module: $($_.Exception.Message)"; exit 1
}
$ErrorActionPreference = "Stop"

try {
  Write-StepHeader "Environment Configuration Generation"
  Write-InfoLog "Copying environment/config templates into shared folder"

  # Paths
  $configPath = Join-Path $ProjectRoot "src/shared/config"
  $libPath    = Join-Path $ProjectRoot "src/shared/lib"

  foreach ($p in @($configPath, $libPath)) { New-Item -Path $p -ItemType Directory -Force | Out-Null }

  function Copy-Template([string]$rel, [string]$dest) {
    Copy-Item -Path (Join-Path $ProjectRoot $rel) -Destination $dest -Force
  }

  # 1. EnvironmentService
  Copy-Template "templates/shared/config/environmentService.ts.template" (Join-Path $configPath "environmentService.ts")
  Write-SuccessLog "environmentService.ts generated"

  # 2. envUtils helper
  Copy-Template "templates/shared/config/envUtils.ts.template" (Join-Path $configPath "envUtils.ts")
  Write-SuccessLog "envUtils.ts generated"

  # 3. Winston logger helper
  Copy-Template "templates/shared/lib/logger.ts.template" (Join-Path $libPath "logger.ts")
  Write-SuccessLog "logger.ts generated"

  Write-SuccessLog "Environment config generation completed successfully"
  exit 0
} catch {
  Write-ErrorLog "Environment config generation failed: $($_.Exception.Message)"; exit 1
}
