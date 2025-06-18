# 09-DeployTemplates.ps1
# Scans templates directory and deploys each template to the src tree. See header in previous version.

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory=$false)]
    [string]$TemplatesRoot = (Join-Path (Split-Path $PSScriptRoot -Parent) 'templates'),

    [Parameter(Mandatory=$false)]
    [string]$ProjectRoot = (Split-Path $PSScriptRoot -Parent),

    [Parameter(Mandatory=$false)]
    [switch]$Recurse
)

Import-Module "$PSScriptRoot\utils.psm1" -Force
$ErrorActionPreference = 'Stop'

Write-StepHeader 'TEMPLATE DEPLOYMENT'
Write-InfoLog "Deploying templates from '$TemplatesRoot' to source tree..."

if (-not (Test-Path $TemplatesRoot)) {
    Write-ErrorLog "Templates directory not found: $TemplatesRoot"
    exit 1
}

# Default to recursive behavior unless explicitly disabled
$useRecurse = -not $PSBoundParameters.ContainsKey('Recurse') -or $Recurse
$templates = if ($useRecurse) { 
    Get-ChildItem -Path $TemplatesRoot -File -Recurse 
} else { 
    Get-ChildItem -Path $TemplatesRoot -File 
}

$deployed = 0
foreach ($tpl in $templates) {
    try {
        $rel = $tpl.FullName.Substring($TemplatesRoot.Length).TrimStart('\', '/')
        $relDest = $rel -replace '\.template$',''
        $destPath = Join-Path $ProjectRoot "src\$relDest"
        
        Write-InfoLog "Processing template: $rel -> $destPath"
        Write-TemplateFile -TemplateRelPath $rel -DestinationPath $destPath
        $deployed++
    }
    catch {
        Write-ErrorLog "Failed to process template $($tpl.Name): $($_.Exception.Message)"
    }
}

Write-SuccessLog "Template deployment completed ($deployed file(s) written)."
exit 0