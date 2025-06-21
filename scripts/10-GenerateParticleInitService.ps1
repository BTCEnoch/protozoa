# 10-GenerateParticleInitService.ps1 - Phase 2 High
# Generates ParticleInitService from templates

[CmdletBinding(SupportsShouldProcess)]
param(
  [Parameter(Mandatory=$false)] [string]$ProjectRoot = $PWD
)
try { Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop } catch { Write-Error "utils import failed"; exit 1 }
$ErrorActionPreference = "Stop"
function CopyTpl($rel,$dest){ Copy-Item -Path (Join-Path $ProjectRoot $rel) -Destination $dest -Force; Write-InfoLog "Copied $(Split-Path $rel -Leaf)" }

try {
  Write-StepHeader "ParticleInitService generation"
  $domain = Join-Path $ProjectRoot "src/domains/particle"
  $interfaces = Join-Path $domain "interfaces"
  $services   = Join-Path $domain "services"
  foreach ($p in @($interfaces,$services)) { if (-not (Test-Path $p)) { New-Item -Path $p -ItemType Directory -Force | Out-Null } }

  CopyTpl "templates/domains/particle/interfaces/IParticleInitService.ts.template" $interfaces
  CopyTpl "templates/domains/particle/services/particleInitService.ts.template" $services

  Write-SuccessLog "Particle init service generated"
  exit 0
} catch { Write-ErrorLog "Particle init generation failed: $($_.Exception.Message)"; exit 1 }

