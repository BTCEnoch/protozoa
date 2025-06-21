# 41-GenerateGroupService.ps1 - Phase 2 High
# Consolidated generator for GroupService and SwarmService (replaces 41a-41d chain)

[CmdletBinding(SupportsShouldProcess)]
param(
  [Parameter(Mandatory=$false)] [string]$ProjectRoot = $PWD
)

try { Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop } catch { Write-Error "utils import failed: $($_.Exception.Message)"; exit 1 }
$ErrorActionPreference = "Stop"

function CopyTpl($rel, $destDir) {
  $sourcePath = Join-Path $ProjectRoot $rel
  $fileName = (Split-Path $rel -Leaf) -replace '\.template$', ''
  $destPath = Join-Path $destDir $fileName
  Copy-Item -Path $sourcePath -Destination $destPath -Force
  Write-InfoLog "Generated $fileName from template"
}

try {
  Write-StepHeader "Group domain generation"
  $domainPath = Join-Path $ProjectRoot "src/domains/group"
  $interfaces = Join-Path $domainPath "interfaces"
  $services   = Join-Path $domainPath "services"
  $types      = Join-Path $domainPath "types"
  foreach ($d in @($interfaces,$services,$types)) { if (-not (Test-Path $d)) { New-Item -Path $d -ItemType Directory -Force | Out-Null } }

  # Templates
  CopyTpl "templates/domains/group/interfaces/IGroupService.ts.template" $interfaces
  CopyTpl "templates/domains/group/interfaces/ISwarmService.ts.template" $interfaces
  CopyTpl "templates/domains/group/services/GroupService.ts.template"    $services
  CopyTpl "templates/domains/group/services/SwarmService.ts.template"    $services

  # Create index.ts
  $index = @'
/** Group domain barrel */
export { GroupService, groupService } from './services/GroupService'
export { SwarmService, swarmService } from './services/SwarmService'
export type * from './interfaces/IGroupService'
export type * from './interfaces/ISwarmService'
'@
  Set-Content -Path (Join-Path $domainPath "index.ts") -Value $index -Encoding UTF8

  Write-SuccessLog "Group domain generation completed"
  exit 0
} catch { Write-ErrorLog "Group domain generation failed: $($_.Exception.Message)"; exit 1 }
