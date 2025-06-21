# 25-SetupPhysicsWebWorkers.ps1 - Phase 2
# Copies physics worker template

[CmdletBinding(SupportsShouldProcess)]
param(
  [Parameter(Mandatory=$false)] [string]$ProjectRoot = $PWD
)
try { Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop } catch { Write-Error "utils import failed"; exit 1 }
$ErrorActionPreference = "Stop"

function CopyTpl($rel,$dest){ Copy-Item -Path (Join-Path $ProjectRoot $rel) -Destination $dest -Force; Write-InfoLog "Copied $(Split-Path $rel -Leaf)" }

try {
  Write-StepHeader "Physics worker setup"
  $workersDir = Join-Path $ProjectRoot "src/domains/physics/workers"
  New-Item -Path $workersDir -ItemType Directory -Force | Out-Null
  CopyTpl "templates/domains/physics/workers/physicsWorker.ts.template" (Join-Path $workersDir "physicsWorker.ts")
  Write-SuccessLog "Physics web worker generated"
  exit 0
} catch { Write-ErrorLog "Physics worker setup failed: $($_.Exception.Message)"; exit 1 }
