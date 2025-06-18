#!/usr/bin/env pwsh
# === fix-content-parsing.ps1 ===
# Converts all double-quoted HERE-STRING blocks (@" ... "@) to single-quoted
# form (@' ... '@) across every .ps1 file in the ./scripts directory tree.  This
# prevents PowerShell from attempting to parse embedded TypeScript/JSON code and
# eliminates the pervasive "parameter name 'and'" errors raised during
# template-generation phases.

param(
    [Parameter(Mandatory=$false)][switch]$WhatIf = $false,
    [Parameter(Mandatory=$false)][string]$ScriptsRoot = (Join-Path (Split-Path $MyInvocation.MyCommand.Path -Parent) '.' )
)

Write-Host "🔧 Converting double-quoted HERE-STRING blocks across all scripts…" -ForegroundColor Cyan

# Collect every PowerShell script under the target root (excluding this script itself)
$problemScripts = Get-ChildItem -Path $ScriptsRoot -Recurse -Filter '*.ps1' |
    Where-Object { $_.FullName -ne $MyInvocation.MyCommand.Path }

$totalFixed   = 0
$scriptsModified = 0

foreach ($file in $problemScripts) {
    $scriptPath = $file.FullName

    $content = Get-Content $scriptPath -Raw

    # Quick reject if file contains no @" tokens – saves time
    if ($content -notmatch '@"') { continue }

    $lines = $content -split "`r`n|`n"
    $newLines = @()
    $inHereString = $false
    $hereStringStartLine = -1
    $fixesInScript = 0

    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]

        # Detect the start of a double-quoted HERE-STRING, e.g. $x = @"  (ignoring trailing spaces)
        if (-not $inHereString -and $line -match '^\s*\$[A-Za-z0-9_]+\s*=\s*@"\s*$') {
            $inHereString = $true
            $hereStringStartLine = $i
            $newLines += ($line -replace '@"\s*$', "@'")
            continue
        }

        # Detect the end of a double-quoted HERE-STRING (`"@`)
        if ($inHereString -and $line -match '^"@\s*$') {
            $inHereString = $false
            $newLines += ($line -replace '^"@', "'@")
            $fixesInScript++
            $hereStringStartLine = -1
            continue
        }

        if ($inHereString) {
            # Inside HERE-STRING – escape any single quotes to preserve content integrity
            $newLines += $line -replace [char]39, ([char]39 + [char]39)
        } else {
            $newLines += $line
        }
    }

    if ($fixesInScript -gt 0) {
        $scriptsModified++
        $totalFixed += $fixesInScript

        if ($WhatIf) {
            Write-Host "[DRY-RUN] Would fix $fixesInScript block(s) in $($file.Name)" -ForegroundColor Yellow
        } else {
            $newLines -join "`r`n" | Set-Content -Path $scriptPath -Encoding UTF8
            Write-Host "✓ Fixed $fixesInScript block(s) in $($file.Name)" -ForegroundColor Green
        }
    }
}

Write-Host "`n🎯 SUMMARY:" -ForegroundColor Cyan
Write-Host "Scripts scanned   : $($problemScripts.Count)" -ForegroundColor White
Write-Host "Scripts modified  : $scriptsModified" -ForegroundColor Green
Write-Host "Blocks converted  : $totalFixed" -ForegroundColor Green

if ($WhatIf) { Write-Host "`nRun without -WhatIf to apply changes." -ForegroundColor Yellow }

# Exit with success
exit 0