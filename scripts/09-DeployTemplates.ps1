# 09-DeployTemplates.ps1
# Scans templates directory and deploys each template to the src tree. See header in previous version.

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory=$false)]
    [string]$TemplatesRoot = (Join-Path (Split-Path $PSScriptRoot -Parent) 'templates'),

    [Parameter(Mandatory=$false)]
    [string]$ProjectRoot = (Split-Path $PSScriptRoot -Parent),

    [Parameter(Mandatory=$false)]
    [switch]$Recurse = $true,

    [Parameter(Mandatory=$false)]
    [switch]$WhatIf
)

Import-Module "$PSScriptRoot\utils.psm1" -Force
$ErrorActionPreference = 'Stop'

Write-StepHeader 'TEMPLATE DEPLOYMENT'
Write-InfoLog "Deploying templates from '$TemplatesRoot' to source tree..."

if (-not (Test-Path $TemplatesRoot)) {
    Write-ErrorLog "Templates directory not found: $TemplatesRoot"
    exit 1
}

$searchOption = if ($Recurse) { '-Recurse' } else { '' }
$templates = Get-ChildItem -Path $TemplatesRoot -File @($searchOption)

$deployed = 0
foreach ($tpl in $templates) {
    $rel = $tpl.FullName.Substring($TemplatesRoot.Length).TrimStart('\\','/')
    $relDest = $rel -replace '\\.?template$',''
    $destPath = Join-Path $ProjectRoot "src/$relDest"

    Write-TemplateFile -TemplateRelPath $rel -DestinationPath $destPath -TokenMap @{ PROJECT = 'protozoa' }
    $deployed++
}

Write-SuccessLog "Template deployment completed ($deployed file(s) written)."
exit 0