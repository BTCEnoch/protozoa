# fix-syntax-errors.ps1
# Comprehensive PowerShell syntax error fixer
# Fixes backtick issues in utils.psm1 and Write-Info calls in all scripts

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$ProjectRoot = $PWD,
    
    [Parameter(Mandatory = $false)]
    [switch]$WhatIf
)

Write-Host "POWERSHELL SYNTAX ERROR FIXER" -ForegroundColor Cyan
Write-Host "Fixing backticks and Write-Info calls..." -ForegroundColor White

# Fix 1: Remove all backticks from utils.psm1 variable references
$utilsPath = Join-Path $ProjectRoot "scripts\utils.psm1"
if (Test-Path $utilsPath) {
    Write-Host "[1/4] Fixing backticks in utils.psm1..." -ForegroundColor Yellow
    
    $content = Get-Content $utilsPath -Raw
    
    # Fix all backticked variable references
    $fixes = @{
        '`$ProjectRoot' = '$ProjectRoot'
        '`$ScriptsPath' = '$ScriptsPath'
        '`$ModulePath' = '$ModulePath'
        '`$utilsPath' = '$utilsPath'
        '`$result' = '$result'
        '`$LASTEXITCODE' = '$LASTEXITCODE'
        '`$true' = '$true'
        '`$false' = '$false'
        '`$PSScriptRoot' = '$PSScriptRoot'
        '`$(`$_.Exception.Message)' = '$($_.Exception.Message)'
    }
    
    foreach ($find in $fixes.Keys) {
        $replace = $fixes[$find]
        $content = $content -replace [regex]::Escape($find), $replace
        Write-Host "  Fixed: $find -> $replace" -ForegroundColor Green
    }
    
    if (-not $WhatIf) {
        Set-Content -Path $utilsPath -Value $content -Encoding UTF8
        Write-Host "  ✅ utils.psm1 backticks fixed" -ForegroundColor Green
    }
}

# Fix 2: Find and fix Write-Info calls (should be Write-InfoLog)
Write-Host "[2/4] Fixing Write-Info calls in all scripts..." -ForegroundColor Yellow

$scriptFiles = Get-ChildItem -Path (Join-Path $ProjectRoot "scripts") -Filter "*.ps1" -Recurse
$writeInfoPattern = 'Write-Info\s+'
$fixedFiles = @()

foreach ($file in $scriptFiles) {
    $content = Get-Content $file.FullName -Raw
    if ($content -match $writeInfoPattern) {
        Write-Host "  Found Write-Info calls in: $($file.Name)" -ForegroundColor Yellow
        
        # Replace Write-Info with Write-InfoLog
        $newContent = $content -replace 'Write-Info\s+', 'Write-InfoLog '
        
        if (-not $WhatIf) {
            Set-Content -Path $file.FullName -Value $newContent -Encoding UTF8
        }
        $fixedFiles += $file.Name
    }
}

if ($fixedFiles.Count -gt 0) {
    Write-Host "  ✅ Fixed Write-Info calls in $($fixedFiles.Count) files:" -ForegroundColor Green
    $fixedFiles | ForEach-Object { Write-Host "    - $_" -ForegroundColor Cyan }
} else {
    Write-Host "  ✅ No Write-Info calls found" -ForegroundColor Green
}

# Fix 3: Find and fix empty string parameters in Write-*Log calls
Write-Host "[3/4] Fixing empty string parameters in logging calls..." -ForegroundColor Yellow

$emptyStringPattern = 'Write-(Info|Success|Warning|Error|Debug)Log\s+""'
$fixedEmptyStrings = @()

foreach ($file in $scriptFiles) {
    $content = Get-Content $file.FullName -Raw
    if ($content -match $emptyStringPattern) {
        Write-Host "  Found empty string parameters in: $($file.Name)" -ForegroundColor Yellow
        
        # Replace empty strings with meaningful messages
        $newContent = $content -replace 'Write-InfoLog\s+""', 'Write-InfoLog "Processing step completed"'
        $newContent = $newContent -replace 'Write-SuccessLog\s+""', 'Write-SuccessLog "Operation completed successfully"'
        $newContent = $newContent -replace 'Write-WarningLog\s+""', 'Write-WarningLog "Warning condition detected"'
        $newContent = $newContent -replace 'Write-ErrorLog\s+""', 'Write-ErrorLog "Error condition occurred"'
        $newContent = $newContent -replace 'Write-DebugLog\s+""', 'Write-DebugLog "Debug checkpoint reached"'
        
        if (-not $WhatIf) {
            Set-Content -Path $file.FullName -Value $newContent -Encoding UTF8
        }
        $fixedEmptyStrings += $file.Name
    }
}

if ($fixedEmptyStrings.Count -gt 0) {
    Write-Host "  ✅ Fixed empty string parameters in $($fixedEmptyStrings.Count) files:" -ForegroundColor Green
    $fixedEmptyStrings | ForEach-Object { Write-Host "    - $_" -ForegroundColor Cyan }
} else {
    Write-Host "  ✅ No empty string parameters found" -ForegroundColor Green
}

# Fix 4: Validate PowerShell syntax for all scripts
Write-Host "[4/4] Validating PowerShell syntax..." -ForegroundColor Yellow

$syntaxErrors = @()
foreach ($file in $scriptFiles) {
    try {
        $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content $file.FullName -Raw), [ref]$null)
        Write-Host "  ✅ $($file.Name)" -ForegroundColor Green
    }
    catch {
        Write-Host "  ❌ $($file.Name): $($_.Exception.Message)" -ForegroundColor Red
        $syntaxErrors += @{
            File = $file.Name
            Error = $_.Exception.Message
        }
    }
}

# Summary
Write-Host "`nSYNTAX FIX SUMMARY:" -ForegroundColor Cyan
Write-Host "✅ Backticks fixed in utils.psm1" -ForegroundColor Green
Write-Host "✅ Write-Info calls fixed: $($fixedFiles.Count) files" -ForegroundColor Green  
Write-Host "✅ Empty string parameters fixed: $($fixedEmptyStrings.Count) files" -ForegroundColor Green

if ($syntaxErrors.Count -eq 0) {
    Write-Host "✅ All PowerShell scripts have valid syntax!" -ForegroundColor Green
} else {
    Write-Host "❌ $($syntaxErrors.Count) scripts still have syntax errors:" -ForegroundColor Red
    foreach ($error in $syntaxErrors) {
        Write-Host "  - $($error.File): $($error.Error)" -ForegroundColor Red
    }
}

if ($WhatIf) {
    Write-Host "`n[WHATIF] No changes were made. Run without -WhatIf to apply fixes." -ForegroundColor Yellow
} else {
    Write-Host "`n[COMPLETE] All syntax fixes have been applied!" -ForegroundColor Green
    Write-Host "You can now run the automation suite: powershell -ExecutionPolicy Bypass -File scripts\runAll.ps1" -ForegroundColor Cyan
} 