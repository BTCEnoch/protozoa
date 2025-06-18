#!/usr/bin/env pwsh
# fix-quotes.ps1
# Fixes double single quote syntax errors in TypeScript files
# Replaces ''text'' with "text" throughout the codebase

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$ProjectRoot = $PWD,
    
    [Parameter(Mandatory = $false)]
    [switch]$WhatIf
)

$ErrorActionPreference = 'Stop'

Write-Host "FIXING DOUBLE SINGLE QUOTE SYNTAX ERRORS" -ForegroundColor Cyan
Write-Host "Scanning TypeScript files for quote issues..." -ForegroundColor White

# Find all TypeScript files
$tsFiles = Get-ChildItem -Path $ProjectRoot -Recurse -Filter "*.ts" | Where-Object { $_.FullName -notmatch "node_modules" }

Write-Host "Found $($tsFiles.Count) TypeScript files to check" -ForegroundColor Yellow

$fixedFiles = @()
$totalReplacements = 0

foreach ($file in $tsFiles) {
    try {
        $content = Get-Content -Path $file.FullName -Raw -ErrorAction Stop
        
        # Count occurrences before replacement
        $beforeCount = ([regex]::Matches($content, "''")).Count
        
        if ($beforeCount -gt 0) {
            # Replace double single quotes with double quotes
            $newContent = $content -replace "''", '"'
            
            # Count replacements made
            $replacements = $beforeCount
            
            if ($WhatIf) {
                Write-Host "[WHATIF] Would fix $replacements quote issues in: $($file.FullName)" -ForegroundColor Yellow
            } else {
                Set-Content -Path $file.FullName -Value $newContent -Encoding UTF8
                Write-Host "[FIXED] $replacements replacements in: $($file.Name)" -ForegroundColor Green
                $fixedFiles += $file.FullName
                $totalReplacements += $replacements
            }
        }
    }
    catch {
        Write-Host "[ERROR] Failed to process $($file.FullName): $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Summary
Write-Host "`nFIX SUMMARY:" -ForegroundColor Cyan
if ($WhatIf) {
    Write-Host "WhatIf mode - no changes made" -ForegroundColor Yellow
    Write-Host "Would fix quote issues in $($fixedFiles.Count) files" -ForegroundColor Yellow
} else {
    Write-Host "Fixed quote issues in $($fixedFiles.Count) files" -ForegroundColor Green
    Write-Host "Total replacements made: $totalReplacements" -ForegroundColor Green
    
    if ($fixedFiles.Count -gt 0) {
        Write-Host "`nFixed files:" -ForegroundColor White
        $fixedFiles | ForEach-Object { Write-Host "  - $($_)" -ForegroundColor Gray }
    }
}

Write-Host "`nQuote fix process completed!" -ForegroundColor Green 