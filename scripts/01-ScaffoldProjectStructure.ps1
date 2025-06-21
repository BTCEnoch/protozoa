# 01-ScaffoldProjectStructure.ps1 - Phase 1 Critical
# Creates base folder structure and copies root templates (tsconfig, vite, vitest)

[CmdletBinding(SupportsShouldProcess)]
param(
  [Parameter(Mandatory=$false)]
  [string]$ProjectRoot = $PWD
)

try { Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop } catch { Write-Error "utils.psm1 import failed: $($_.Exception.Message)"; exit 1 }
$ErrorActionPreference = "Stop"

function New-Dir($Path) { if (-not (Test-Path $Path)) { New-Item -Path $Path -ItemType Directory -Force | Out-Null } }
function Copy-Template($Rel, $Dest) { Copy-Item -Path (Join-Path $ProjectRoot $Rel) -Destination $Dest -Force; Write-InfoLog "Copied $(Split-Path $Rel -Leaf)" }

try {
  Write-StepHeader "Project scaffold"

  # Base dirs
  $base = @("src","src/domains","src/shared","src/shared/config","src/shared/lib","src/shared/types","tests","docs","scripts")
  $base | ForEach-Object { New-Dir (Join-Path $ProjectRoot $_) }

  # Domain dirs (simple list)
  $domains = @("bitcoin","rng","physics","rendering","animation","effect","formation","particle","group","trait")
  foreach ($d in $domains) {
    foreach ($sub in @("","/services","/types","/data")) {
      New-Dir (Join-Path $ProjectRoot "src/domains/$d$sub")
    }
    New-Dir (Join-Path $ProjectRoot "tests/$d")
  }

  # Copy root template files
  Copy-Template "templates/tsconfig.json.template"        (Join-Path $ProjectRoot "tsconfig.json")
  Copy-Template "templates/tsconfig.app.json.template"    (Join-Path $ProjectRoot "tsconfig.app.json")
  Copy-Template "templates/tsconfig.node.json.template"   (Join-Path $ProjectRoot "tsconfig.node.json")
  Copy-Template "templates/vite.config.ts.template"       (Join-Path $ProjectRoot "vite.config.ts")
  Copy-Template "templates/vitest.config.ts.template"     (Join-Path $ProjectRoot "vitest.config.ts")

  Write-SuccessLog "Project scaffold complete"
  exit 0
} catch {
  Write-ErrorLog "Scaffold failed: $($_.Exception.Message)"; exit 1
}