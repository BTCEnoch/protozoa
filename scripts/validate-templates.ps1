# validate-templates.ps1
# Performs syntax validation for every template under the templates/ directory.
# Should be executed early in automation pipeline to detect issues before files are generated.

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$TemplatesRoot = (Join-Path (Split-Path $PSScriptRoot -Parent) 'templates'),

    [Parameter(Mandatory = $false)]
    [switch]$Recurse,

    [Parameter(Mandatory = $false)]
    [switch]$WhatIf
)

Import-Module "$PSScriptRoot\utils.psm1" -Force
$ErrorActionPreference = 'Stop'

Write-StepHeader 'TEMPLATE VALIDATION'
Write-InfoLog "Validating templates in '$TemplatesRoot'..."

if (-not (Test-Path $TemplatesRoot)) {
    Write-ErrorLog "Templates directory not found: $TemplatesRoot"
    exit 1
}

# Default to recursive search unless explicitly disabled
$useRecurse = if ($PSBoundParameters.ContainsKey('Recurse')) { $Recurse } else { $true }
$templates = if ($useRecurse) { 
    Get-ChildItem -Path $TemplatesRoot -File -Recurse 
} else { 
    Get-ChildItem -Path $TemplatesRoot -File 
}

$failures = @()
foreach ($t in $templates) {
    $valid = Test-TemplateSyntax -TemplatePath $t.FullName
    if (-not $valid) { $failures += $t.FullName }
}

if ($failures.Count -eq 0) {
    Write-SuccessLog 'All template files passed syntax validation.'
    exit 0
} else {
    Write-ErrorLog "Template validation failed for $($failures.Count) file(s):"
    foreach ($f in $failures) { Write-WarningLog "  - $f" }
    exit 1
}