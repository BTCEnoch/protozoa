# fix-here-strings.ps1
# Batch repairs invalid PowerShell here-string headers of the pattern `= @"xxx"@`
# Applies to automation scaffolds that embed TypeScript/YAML in scripts 30-56.
#
# Usage (from repo root):
#   pwsh -NoLogo -NoProfile -File scripts/script_scrub/utils/fix-here-strings.ps1
# ------------------------------------------------------------
param(
    [Parameter(Mandatory=$false)]
    [string[]]$ScriptNumbers = 30..56  # default range to patch
)

$ErrorActionPreference = 'Stop'

function Fix-HereStrings([string]$Path){
    $original = Get-Content -Path $Path -Raw
    # pattern: equals sign then optional whitespace then @"  - NOT followed by newline
    $fixed   = $original -replace '(?m)=\s*@"', "= @`"`r`n"
    if($fixed -ne $original){
        Set-Content -Path $Path -Value $fixed -Encoding UTF8
        Write-Host "✔ Fixed here-strings in $Path" -ForegroundColor Green
    } else {
        Write-Host "ℹ No change needed in $Path" -ForegroundColor DarkGray
    }
}

$targetScripts = @()
foreach($num in $ScriptNumbers){
    $glob = (Join-Path $PSScriptRoot "../../${num}-*.ps1")
    $matched = Get-ChildItem -Path $glob -ErrorAction SilentlyContinue
    $targetScripts += $matched
}

if(-not $targetScripts){
    Write-Warning "No scripts matched the specified range. Exiting."
    exit 0
}

foreach($file in $targetScripts){
    Fix-HereStrings -Path $file.FullName
}

Write-Host "--- HERE-STRING PATCH COMPLETE ---" -ForegroundColor Cyan