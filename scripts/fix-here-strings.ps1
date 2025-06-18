#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Batch fix HERE-STRING syntax errors across all PowerShell scripts
.DESCRIPTION
    Fixes the common pattern where @"content should be @"<newline>content<newline>"@
#>

param(
    [switch]$WhatIf = $false
)

Write-Host "Batch fixing HERE-STRING syntax errors..." -ForegroundColor Cyan

$scripts = Get-ChildItem -Path "." -Filter "*.ps1" -Recurse | Where-Object { 
    $_.Name -ne "fix-here-strings.ps1" -and 
    $_.Name -ne "runAll.ps1" -and
    $_.Directory.Name -ne "script_scrub"
}

$totalFixed = 0
$scriptsModified = 0

foreach ($script in $scripts) {
    Write-Host "Processing: $($script.Name)" -ForegroundColor Yellow
    
    $content = Get-Content $script.FullName -Raw
    $originalContent = $content
    
    # Simple regex replacement approach  
    # Replace pattern: $var=@"content -> $var=@"<newline>content<newline>"@
    $pattern = '(\$\w+\s*=\s*)@"([^"@\r\n].+)$'
    $replacement = '$1@"' + "`r`n" + '$2' + "`r`n" + '"@'
    
    # Use regex with multiline flag
    $regex = [regex]::new($pattern, [System.Text.RegularExpressions.RegexOptions]::Multiline)
    $matches = $regex.Matches($content)
    
    if ($matches.Count -gt 0) {
        $newContent = $regex.Replace($content, $replacement)
        $scriptsModified++
        $totalFixed += $matches.Count
        
        if ($WhatIf) {
            Write-Host "  [WHATIF] Would fix $($matches.Count) HERE-STRING issues" -ForegroundColor Green
        } else {
            Set-Content -Path $script.FullName -Value $newContent -NoNewline
            Write-Host "  Fixed $($matches.Count) HERE-STRING issues" -ForegroundColor Green
        }
    } else {
        Write-Host "  No issues found" -ForegroundColor Gray
    }
}

Write-Host "`nBATCH FIX SUMMARY:" -ForegroundColor Cyan
Write-Host "  Scripts processed: $($scripts.Count)" -ForegroundColor White
Write-Host "  Scripts modified: $scriptsModified" -ForegroundColor Yellow  
Write-Host "  Total fixes applied: $totalFixed" -ForegroundColor Green

if ($WhatIf) {
    Write-Host "`nThis was a dry run. Use without -WhatIf to apply changes." -ForegroundColor Yellow
} else {
    Write-Host "`nAll HERE-STRING syntax errors have been fixed!" -ForegroundColor Green
    Write-Host "Run the pipeline again to test the fixes." -ForegroundColor Cyan
} 