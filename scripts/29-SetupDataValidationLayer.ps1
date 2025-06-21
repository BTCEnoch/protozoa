# 29-SetupDataValidationLayer.ps1 - template copy
[CmdletBinding()]param([string]$ProjectRoot=$PWD)
Import-Module "$PSScriptRoot\utils.psm1" -Force
$dest=Join-Path $ProjectRoot "src/shared/utils"; New-Item -Path $dest -ItemType Directory -Force|Out-Null
Copy-Item -Path (Join-Path $ProjectRoot "templates/shared/utils/validation.utils.ts.template") -Destination (Join-Path $dest "validation.utils.ts") -Force
Write-InfoLog "Validation utils generated"
