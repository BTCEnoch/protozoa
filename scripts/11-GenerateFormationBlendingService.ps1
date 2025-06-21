# 11-GenerateFormationBlendingService.ps1 - Phase 2 High
# Generates FormationBlendingService via templates

[CmdletBinding(SupportsShouldProcess)]
param(
  [Parameter(Mandatory=$false)] [string]$ProjectRoot = $PWD
)
try { Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop } catch { Write-Error "utils import failed: $($_.Exception.Message)"; exit 1 }
$ErrorActionPreference = "Stop"

function CopyTpl($rel,$dest){ Copy-Item -Path (Join-Path $ProjectRoot $rel) -Destination $dest -Force; Write-InfoLog "Copied $(Split-Path $rel -Leaf)" }

try {
  Write-StepHeader "Formation Blending Service generation"
  $domain = Join-Path $ProjectRoot "src/domains/formation"
  $interfaces = Join-Path $domain "interfaces"
  $services   = Join-Path $domain "services"
  foreach ($p in @($interfaces,$services)) { if (-not (Test-Path $p)) { New-Item -Path $p -ItemType Directory -Force | Out-Null } }

  CopyTpl "templates/domains/formation/interfaces/IFormationBlendingService.ts.template" $interfaces
  CopyTpl "templates/domains/formation/services/formationBlendingService.ts.template"     $services

  Write-SuccessLog "Formation blending service files generated"
  exit 0
} catch { Write-ErrorLog "Formation blending generation failed: $($_.Exception.Message)"; exit 1 }
