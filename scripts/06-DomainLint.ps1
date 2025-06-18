# 06-DomainLint.ps1
# Domain-specific linting and boundary enforcement
# Referenced from build_design.md domain boundary requirements

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
    Write-StepHeader "Domain-Specific Linting - Phase 6"
    
    Push-Location $ProjectRoot
    Write-InfoLog "Running domain linting in project: $ProjectRoot"
    
    $violations = @()
    $domains = Get-DomainList
    
    # Check domain boundary violations
    foreach ($domain in $domains) {
        $domainPath = "src/domains/$domain"
        if (Test-Path $domainPath) {
            $domainFiles = Get-ChildItem -Path $domainPath -Filter "*.ts" -Recurse -ErrorAction SilentlyContinue
            
            foreach ($file in $domainFiles) {
                $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
                if ($content) {
                    # Check for imports from other domains
                    $otherDomains = $domains | Where-Object { $_ -ne $domain }
                    foreach ($otherDomain in $otherDomains) {
                        # Check for direct cross-domain imports using alias or relative paths
                        if ($content -match "from\s+[`"']@/domains/$otherDomain") {
                            $violations += "Domain boundary violation in $($file.FullName): aliased import from $otherDomain domain"
                        }
                        # Check for relative path escaping own domain folder into another domain
                        if ($content -match "from\s+[`"'](\.\./).*domains/$otherDomain") {
                            $violations += "Domain boundary violation in $($file.FullName): relative import to $otherDomain domain"
                        }
                    }
                    
                    # Enforce correct alias usage for own domain (no deep relative imports)
                    if ($content -match "from\s+[`"'](\.\./).*domains/$domain") {
                        $violations += "Import path violation in $($file.FullName): use '@/domains/$domain' alias instead of relative path"
                    }
                    
                    # Check for proper service naming
                    if ($file.Name -like "*Service.ts" -and $content -notmatch "class\s+\w+Service") {
                        $violations += "Service naming violation in $($file.FullName): missing Service class"
                    }
                }
            }
        }
    }
    
    # Run ESLint if available
    if (Test-Path "package.json" -and (Get-Command pnpm -ErrorAction SilentlyContinue)) {
        Write-InfoLog "Running ESLint..."
        try {
            $eslintResult = pnpm exec eslint src --ext .ts --format compact 2>&1
            if ($LASTEXITCODE -ne 0) {
                Write-WarningLog "ESLint found issues:"
                Write-WarningLog $eslintResult
            } else {
                Write-SuccessLog "ESLint passed"
            }
        }
        catch {
            Write-WarningLog "ESLint execution failed: $($_.Exception.Message)"
        }
    }
    
    # Report results
    if ($violations.Count -eq 0) {
        Write-SuccessLog "All domain linting checks passed"
    } else {
        Write-WarningLog "Found $($violations.Count) domain violations:"
        foreach ($violation in $violations) {
            Write-WarningLog "  - $violation"
        }
    }
    
    Write-SuccessLog "Domain linting completed"
    exit 0
}
catch {
    Write-ErrorLog "Domain linting failed: $($_.Exception.Message)"
    exit 1
}
finally {
    try { Pop-Location -ErrorAction SilentlyContinue } catch { }
} 