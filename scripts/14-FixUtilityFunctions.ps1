# 14-FixUtilityFunctions.ps1 - converts to template copy
[CmdletBinding()]param([string]$ProjectRoot=$PWD)
Import-Module "$PSScriptRoot\utils.psm1" -Force
$dest=Join-Path $ProjectRoot "src/shared/utils"; New-Item -Path $dest -ItemType Directory -Force|Out-Null
Copy-Item -Path (Join-Path $ProjectRoot "templates/shared/utils/fixHelpers.ts.template") -Destination (Join-Path $dest "fixHelpers.ts") -Force
Write-InfoLog "Utility helpers generated"