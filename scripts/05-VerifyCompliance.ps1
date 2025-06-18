# 05-VerifyCompliance.ps1
# Verifies architectural compliance with .cursorrules standards
# Referenced from build_design.md compliance requirements

#Requires -Version 5.1

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $false)]
    [string]$ProjectRoot = (Split-Path $PSScriptRoot -Parent)
)

try {
    Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop
}
catch {
    Write-Error "Failed to import utilities module: $($_.Exception.Message)"
    exit 1
}

$ErrorActionPreference = "Stop"

try {
    Write-StepHeader "Architecture Compliance Verification - Phase 5"

    Push-Location $ProjectRoot
    Write-InfoLog "Verifying compliance in project: $ProjectRoot"

    $violations = @()

    # Check file size limits (500 lines)
    if (Test-Path "src") {
        $tsFiles = Get-ChildItem -Path "src" -Filter "*.ts" -Recurse -ErrorAction SilentlyContinue
        foreach ($file in $tsFiles) {
            $lineCount = (Get-Content $file.FullName -ErrorAction SilentlyContinue).Count
            if ($lineCount -gt 500) {
                $violations += "File exceeds 500 lines ($lineCount): $($file.FullName)"
            }
        }
    }

    # Check for cross-domain imports
    if (Test-Path "src/domains") {
        $domainFiles = Get-ChildItem -Path "src/domains" -Filter "*.ts" -Recurse -ErrorAction SilentlyContinue
        foreach ($file in $domainFiles) {
            $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
            if ($content -and $content -match "from\s+['\`"]\.\.\/\.\.\/domains\/") {
                $violations += "Cross-domain import detected: $($file.FullName)"
            }
        }
    }

    # Check for backup files
    $backupPatterns = @("*.bak", "*.backup", "*.old", "*.temp")
    foreach ($pattern in $backupPatterns) {
        $backupFiles = Get-ChildItem -Path "." -Filter $pattern -Recurse -ErrorAction SilentlyContinue
        foreach ($file in $backupFiles) {
            $violations += "Backup file found: $($file.FullName)"
        }
    }

    # Report results
    if ($violations.Count -eq 0) {
        Write-SuccessLog "All compliance checks passed"
    } else {
        Write-WarningLog "Found $($violations.Count) compliance violations:"
        foreach ($violation in $violations) {
            Write-WarningLog "  - $violation"
        }
    }

    Write-SuccessLog "Compliance verification completed"
    exit 0
}
catch {
    Write-ErrorLog "Compliance verification failed: $($_.Exception.Message)"
    exit 1
}
finally {
    try { Pop-Location -ErrorAction SilentlyContinue } catch { }
}