# fix-here-strings.ps1
# Utility script that converts double-quoted HERE-STRINGS (@"..."@) to single-quoted ones (@'...'@)
# across all PowerShell automation scripts. This prevents PowerShell from attempting
# to interpolate variables or parse special characters inside multi-language blocks
# (TypeScript, YAML, Dockerfiles, etc.) which previously caused syntax errors.
#
# Usage:
#   1. Run manually before executing runAll.ps1:
#        powershell -File .\scripts\fix-here-strings.ps1
#   2. Or let runAll.ps1 invoke it as the first step (see injected call).
#
# IMPORTANT: The script backs up every modified file ( *.ps1.bak_yyyyMMdd_HHmmss ) so
# you can safely revert if necessary.

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $false)]
    [string]$ScriptsPath = (Join-Path $PSScriptRoot '.'),

    [Parameter(Mandatory = $false)]
    [switch]$Recurse,

    [Parameter(Mandatory = $false)]
    [switch]$WhatIf
)

Import-Module "$PSScriptRoot\utils.psm1" -Force

$ErrorActionPreference = 'Stop'

Write-StepHeader "HERE-STRING SANITISATION"
Write-InfoLog "Scanning *.ps1 files in '$ScriptsPath' for double-quoted HERE-STRINGS..."

# Collect files
$searchOption = if ($Recurse) { '-Recurse' } else { '' }
$ps1Files = Get-ChildItem -Path $ScriptsPath -Filter '*.ps1' @($searchOption) | Where-Object {
    # Skip this script itself to avoid infinite recursion
    $_.FullName -ne $PSCommandPath
}

$convertedCount = 0
foreach ($file in $ps1Files) {
    try {
        $content = Get-Content -LiteralPath $file.FullName -Raw

        # Quick heuristic: only proceed if the file contains @" and "@
        if ($content -notmatch '@"' -or $content -notmatch '"@') { continue }

        # Regex: convert opening = @" or @" at line start to = @' / @'
        $newContent = $content -replace '(?m)=\s*@"', '= @\''
        $newContent = $newContent -replace '(?m)^\s*@"', "@'"  # standalone openings

        # Convert closing "@ to '@  (must be at line start/with whitespace only)
        $newContent = $newContent -replace '(?m)^\s*"@', "'@"

        if ($newContent -ne $content) {
            # Backup original file
            $backupPath = "$($file.FullName).bak_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
            if (-not $WhatIf) { Copy-Item -LiteralPath $file.FullName -Destination $backupPath -Force }
            Write-DebugLog "Backed up '$($file.Name)' -> '$([System.IO.Path]::GetFileName($backupPath))'"

            # Write new content
            if (-not $WhatIf) { Set-Content -LiteralPath $file.FullName -Value $newContent -Encoding UTF8 }
            $convertedCount++
            Write-InfoLog "Converted HERE-STRINGS in: $($file.Name)"
        }
    }
    catch {
        Write-WarningLog "Failed to process '$($file.FullName)': $($_.Exception.Message)"
    }
}

Write-SuccessLog "HERE-STRING sanitisation complete. Files modified: $convertedCount"
exit 0