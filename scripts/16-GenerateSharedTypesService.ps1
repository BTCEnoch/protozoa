# 16-GenerateSharedTypesService.ps1 - Phase 1 Critical
# Copies shared type templates into src/shared/types (no inline TS)

[CmdletBinding(SupportsShouldProcess)]
param(
  [Parameter(Mandatory=$false)]
  [string]$ProjectRoot = $PWD
)

try { Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop } catch { Write-Error "utils.psm1 import failed: $($_.Exception.Message)"; exit 1 }
$ErrorActionPreference = "Stop"

try {
  Write-StepHeader "Shared Types Generation"
  $typesPath = Join-Path $ProjectRoot "src/shared/types"
  New-Item -Path $typesPath -ItemType Directory -Force | Out-Null

  function Copy-Template([string]$rel) {
    Copy-Item -Path (Join-Path $ProjectRoot $rel) -Destination $typesPath -Force
  }

  $templates = @(
    "templates/shared/types/vectorTypes.ts.template",
    "templates/shared/types/entityTypes.ts.template",
    "templates/shared/types/configTypes.ts.template",
    "templates/shared/types/loggingTypes.ts.template",
    "templates/shared/types/eventTypes.ts.template",
    "templates/shared/types/index.ts.template"
  )

  foreach ($tpl in $templates) {
    Copy-Template $tpl
    Write-InfoLog "Copied $(Split-Path $tpl -Leaf)"
  }

  Write-SuccessLog "Shared types generation completed successfully"
  exit 0
} catch {
  Write-ErrorLog "Shared types generation failed: $($_.Exception.Message)"; exit 1
}
