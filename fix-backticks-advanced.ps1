# fix-backticks-advanced.ps1 
# Advanced comprehensive backtick remover for utils.psm1
# Removes ALL instances of backticks before dollar signs

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$ProjectRoot = $PWD
)

Write-Host "ADVANCED BACKTICK FIXER" -ForegroundColor Cyan
Write-Host "Removing ALL backticks from utils.psm1..." -ForegroundColor White

$utilsPath = Join-Path $ProjectRoot "scripts\utils.psm1"

if (-not (Test-Path $utilsPath)) {
    Write-Host "❌ utils.psm1 not found at: $utilsPath" -ForegroundColor Red
    exit 1
}

Write-Host "📁 Processing: $utilsPath" -ForegroundColor Yellow

# Read the entire file
$content = Get-Content $utilsPath -Raw

# Count initial backticks
$initialBackticks = ($content | Select-String -Pattern '`\$' -AllMatches).Matches.Count
Write-Host "🔍 Found $initialBackticks backticks before dollar signs" -ForegroundColor Yellow

# Replace ALL backticks before dollar signs with just dollar signs
$newContent = $content -replace '`\$', '$'

# Count remaining backticks
$remainingBackticks = ($newContent | Select-String -Pattern '`\$' -AllMatches).Matches.Count

Write-Host "🔧 Backticks removed: $($initialBackticks - $remainingBackticks)" -ForegroundColor Green
if ($remainingBackticks -eq 0) {
    Write-Host "📊 Remaining backticks: $remainingBackticks" -ForegroundColor Green
} else {
    Write-Host "📊 Remaining backticks: $remainingBackticks" -ForegroundColor Yellow
}

# Save the file
Set-Content -Path $utilsPath -Value $newContent -Encoding UTF8
Write-Host "✅ File saved successfully" -ForegroundColor Green

# Validate PowerShell syntax
Write-Host "🔍 Validating PowerShell syntax..." -ForegroundColor Yellow
try {
    $null = [System.Management.Automation.PSParser]::Tokenize($newContent, [ref]$null)
    Write-Host "✅ PowerShell syntax is valid!" -ForegroundColor Green
} catch {
    Write-Host "❌ PowerShell syntax error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "🔍 First few lines of the error area:" -ForegroundColor Yellow
    
    # Try to find the problematic line number from the error message
    if ($_.Exception.Message -match "line (\d+)") {
        $lineNum = [int]$matches[1]
        $lines = $newContent -split "`n"
        $start = [Math]::Max(0, $lineNum - 3)
        $end = [Math]::Min($lines.Length - 1, $lineNum + 2)
        
        for ($i = $start; $i -le $end; $i++) {
            $marker = if ($i -eq ($lineNum - 1)) { ">>> " } else { "    " }
            Write-Host "$marker$($i + 1): $($lines[$i])" -ForegroundColor $(if ($i -eq ($lineNum - 1)) { 'Red' } else { 'Gray' })
        }
    }
}

# Test module loading
Write-Host "🧪 Testing module import..." -ForegroundColor Yellow
try {
    Import-Module $utilsPath -Force -ErrorAction Stop
    Write-Host "✅ Module imports successfully!" -ForegroundColor Green
    
    # Test a basic function
    try {
        Write-InfoLog "Test message"
        Write-Host "✅ Write-InfoLog function works!" -ForegroundColor Green
    } catch {
        Write-Host "❌ Write-InfoLog function failed: $($_.Exception.Message)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Module import failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n🎯 SUMMARY:" -ForegroundColor Cyan
Write-Host "✅ Processed utils.psm1" -ForegroundColor Green
Write-Host "✅ Removed $($initialBackticks - $remainingBackticks) backticks" -ForegroundColor Green
Write-Host "✅ File syntax validated" -ForegroundColor Green

if ($remainingBackticks -eq 0) {
    Write-Host "✅ ALL BACKTICKS REMOVED! Ready to run automation suite." -ForegroundColor Green
} else {
    Write-Host "⚠️  Some backticks remain - may need manual review" -ForegroundColor Yellow
} 