# 34-EnhanceFormationSystem.ps1 - template copy
[CmdletBinding()]param([string]$ProjectRoot=$PWD)
Import-Module "$PSScriptRoot\utils.psm1" -Force
$services=Join-Path $ProjectRoot "src/domains/formation/services"; New-Item -Path $services -ItemType Directory -Force|Out-Null
Copy-Item -Path (Join-Path $ProjectRoot "templates/domains/formation/services/formationEnhancer.ts.template") -Destination (Join-Path $services "formationEnhancer.ts") -Force
Write-InfoLog "Formation enhancer utility generated"
