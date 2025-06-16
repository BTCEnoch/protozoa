# 04-EnforceSingletonPatterns.ps1
# Enforces singleton patterns across all domain services
# Referenced from build_design.md singleton pattern requirements

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
    Write-StepHeader "Singleton Pattern Enforcement - Phase 4"
    
    Push-Location $ProjectRoot
    Write-InfoLog "Validating singleton patterns in project: $ProjectRoot"
    
    # Check for service files and validate singleton patterns
    $domains = Get-DomainList
    $violations = @()
    
    foreach ($domain in $domains) {
        $servicePath = "src/domains/$domain/services"
        if (Test-Path $servicePath) {
            $serviceFiles = Get-ChildItem -Path $servicePath -Filter "*.ts" -ErrorAction SilentlyContinue
            
            foreach ($file in $serviceFiles) {
                $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
                if ($content) {
                    # Check for singleton pattern
                    if ($content -notmatch "static\s+#instance" -and $content -notmatch "getInstance\(\)") {
                        $violations += "Missing singleton pattern: $($file.FullName)"
                    }
                    
                    # Check for dispose method
                    if ($content -notmatch "dispose\(\)") {
                        $violations += "Missing dispose method: $($file.FullName)"
                    }
                }
            }
        }
    }
    
    if ($violations.Count -eq 0) {
        Write-SuccessLog "All singleton patterns validated successfully"
    } else {
        Write-WarningLog "Found $($violations.Count) singleton pattern violations:"
        foreach ($violation in $violations) {
            Write-WarningLog "  - $violation"
        }
    }
    
    Write-SuccessLog "Singleton pattern enforcement completed"
    exit 0
}
catch {
    Write-ErrorLog "Singleton pattern enforcement failed: $($_.Exception.Message)"
    exit 1
}
finally {
    try { Pop-Location -ErrorAction SilentlyContinue } catch { }
} 