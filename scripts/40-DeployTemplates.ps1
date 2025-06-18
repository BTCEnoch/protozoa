# 40-DeployTemplates.ps1
# Scans templates directory and deploys each template to the appropriate destination path under /src.
# Destination path is derived by stripping the first path segment (domains/…) and prefixing with src/.
# Example:
#   templates/domains/particle/interfaces/ILifecycleEngine.ts.template
#     => src/domains/particle/interfaces/ILifecycleEngine.ts
#
# Replaces optional tokens using -TokenMap (currently just "PROJECT" token as placeholder).
#
# This script supersedes the inline generation logic of phases 32-56, enabling a template-based workflow.

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
    # Build destination path
    $rel = $tpl.FullName.Substring($TemplatesRoot.Length).TrimStart('\','/')
    # Remove .template suffix
    $relDest = $rel -replace '\.template$',''
    # Prefix with src/
    $destPath = Join-Path $ProjectRoot "src/$relDest"

    Write-TemplateFile -TemplateRelPath $rel -DestinationPath $destPath -TokenMap @{ PROJECT = 'protozoa' }
    $deployed++
}

Write-SuccessLog "Template deployment completed ($deployed file(s) written)."
exit 0