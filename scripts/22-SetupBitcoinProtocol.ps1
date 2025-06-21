# 22-SetupBitcoinProtocol.ps1 - Phase 2 High
# Copies bitcoin config and rate-limiter templates

[CmdletBinding(SupportsShouldProcess)]
param(
  [Parameter(Mandatory=$false)] [string]$ProjectRoot = $PWD
)
try { Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop } catch { Write-Error "utils import failed"; exit 1 }
$ErrorActionPreference = "Stop"
function CopyTpl($rel,$dest){ Copy-Item -Path (Join-Path $ProjectRoot $rel) -Destination $dest -Force; Write-InfoLog "Copied $(Split-Path $rel -Leaf)" }

try {
  Write-StepHeader "Bitcoin protocol setup"
  $configDir = Join-Path $ProjectRoot "src/config"
  New-Item -Path $configDir -ItemType Directory -Force | Out-Null

  CopyTpl "templates/config/bitcoin.config.ts.template" (Join-Path $configDir "bitcoin.config.ts")
  CopyTpl "templates/config/rate-limiter.ts.template"   (Join-Path $configDir "rate-limiter.ts")

  Write-SuccessLog "Bitcoin protocol config generated"
  exit 0
} catch { Write-ErrorLog "Bitcoin protocol setup failed: $($_.Exception.Message)"; exit 1 }
