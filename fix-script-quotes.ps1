#!/usr/bin/env pwsh
# fix-script-quotes.ps1
# Fixes double single quote issues in PowerShell scripts that generate TypeScript content
# Replaces ''text'' with "text" in here-strings and content generation

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$ScriptsPath = "./scripts",
    
    [Parameter(Mandatory = $false)]
    [switch]$WhatIf
)

$ErrorActionPreference = 'Stop'

Write-Host "FIXING TYPESCRIPT GENERATION QUOTE ISSUES IN AUTOMATION SCRIPTS" -ForegroundColor Cyan
Write-Host "Scanning PowerShell scripts for TypeScript quote issues..." -ForegroundColor White

# Find all PowerShell scripts with optimized filtering
$scriptFiles = Get-ChildItem -Path $ScriptsPath -Filter "*.ps1" | Where-Object { 
    $_.Length -gt 0 -and $_.Name -notmatch "^(fix-|runAll)" 
}

Write-Host "Found $($scriptFiles.Count) PowerShell scripts to check" -ForegroundColor Yellow

$fixedFiles = @()
$totalReplacements = 0
$processedCount = 0

# Define the pattern to match double single quotes in TypeScript generation
$doubleSingleQuotePattern = "''([^']+)''"

foreach ($file in $scriptFiles) {
    $processedCount++
    Write-Progress -Activity "Processing Scripts" -Status "Processing $($file.Name)" -PercentComplete (($processedCount / $scriptFiles.Count) * 100)
    
    try {
        Write-Host "[PROGRESS] $processedCount/$($scriptFiles.Count) - Checking: $($file.Name)" -ForegroundColor Gray
        
        # Read file content efficiently
        $content = Get-Content -Path $file.FullName -Raw
        
        # Quick check if file contains double single quotes
        if (-not $content.Contains("''")) {
            Write-Host "  [SKIP] No double quotes found" -ForegroundColor DarkGray
            continue
        }
        
        $replacements = 0
        $newContent = $content
        
        # Replace TypeScript-related double single quotes with double quotes
        $matchCount = ([regex]::Matches($newContent, $doubleSingleQuotePattern)).Count
        
        if ($matchCount -gt 0) {
            $newContent = [regex]::Replace($newContent, $doubleSingleQuotePattern, '"$1"')
            $replacements = $matchCount
            Write-Host "  [MATCH] Found $matchCount double single quotes to replace" -ForegroundColor Cyan
        }
        
        if ($replacements -gt 0) {
            if ($WhatIf) {
                Write-Host "  [WHATIF] Would fix $replacements TypeScript quote issues" -ForegroundColor Yellow
            } else {
                Set-Content -Path $file.FullName -Value $newContent -Encoding UTF8
                Write-Host "  [FIXED] $replacements replacements applied" -ForegroundColor Green
                $fixedFiles += $file.FullName
            }
            $totalReplacements += $replacements
        } else {
            Write-Host "  [CLEAN] No TypeScript quote issues found" -ForegroundColor DarkGreen
        }
    }
    catch {
        Write-Host "  [ERROR] Failed to process: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Progress -Activity "Processing Scripts" -Completed

# Summary
Write-Host "`nFIX SUMMARY:" -ForegroundColor Cyan
if ($WhatIf) {
    Write-Host "WhatIf mode - no changes made" -ForegroundColor Yellow
    Write-Host "Would fix TypeScript quote issues in $($fixedFiles.Count) files" -ForegroundColor Yellow
    Write-Host "Total potential replacements: $totalReplacements" -ForegroundColor Yellow
} else {
    Write-Host "Fixed TypeScript quote issues in $($fixedFiles.Count) files" -ForegroundColor Green
    Write-Host "Total replacements made: $totalReplacements" -ForegroundColor Green
    
    if ($fixedFiles.Count -gt 0) {
        Write-Host "`nFixed scripts:" -ForegroundColor White
        $fixedFiles | ForEach-Object { Write-Host "  - $(Split-Path $_ -Leaf)" -ForegroundColor Gray }
    }
}

Write-Host "`nScript quote fix process completed in $($processedCount) files!" -ForegroundColor Green 