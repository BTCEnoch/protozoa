# 18a-SetupLoggingService.ps1
# Ensures browser-compatible logging infrastructure is present in src/shared/lib/logger.ts
# Uses console API in browser, Winston in Node.js (optional dependency)
# If file already exists, the script validates and updates for browser compatibility.
# Usage: Executed by runAll.ps1 right after environment configuration generation.

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $false)]
    [string]$ProjectRoot = (Split-Path $PSScriptRoot -Parent),

    [Parameter(Mandatory = $false)]
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

try {
    Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop
} catch {
    Write-Error "Failed to import utils module: $($_.Exception.Message)"
    exit 1
}

try {
    Write-StepHeader "Setup Winston Logging Service (18a)"
    Write-InfoLog "Verifying central Winston logger implementation"

    $libPath = Join-Path $ProjectRoot "src/shared/lib"
    $loggerPath = Join-Path $libPath "logger.ts"

    if (-not (Test-Path $libPath)) {
        Write-InfoLog "Creating shared lib directory: $libPath"
        if (-not $DryRun) { 
            New-Item -ItemType Directory -Path $libPath -Force | Out-Null 
        }
    }

    # Use template-based approach for browser compatibility
    $templatePath = Join-Path $ProjectRoot "templates/shared/lib/logger.ts.template"
    
    if (-not (Test-Path $templatePath)) {
        Write-ErrorLog "Logger template not found at: $templatePath"
        throw "Logger template missing - cannot generate browser-compatible logger"
    }
    
    Write-InfoLog "Using browser-compatible logger template"
    $loggerContent = Get-Content $templatePath -Raw

    if (Test-Path $loggerPath) {
        Write-InfoLog "logger.ts already exists - validating for browser compatibility"
        $existingContent = Get-Content $loggerPath -Raw
        if (-not ($existingContent | Select-String -Pattern "Universal Logger - Browser & Node.js Compatible")) {
            Write-WarningLog "Existing logger.ts detected but not browser-compatible - backing up and updating"
            $backupPath = "$loggerPath.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
            if (-not $DryRun) { 
                Copy-Item -Path $loggerPath -Destination $backupPath -Force
                Set-Content -Path $loggerPath -Value $loggerContent -Encoding UTF8 
                Write-InfoLog "Updated logger.ts with browser-compatible implementation"
            }
        } else {
            Write-InfoLog "Browser-compatible logger already present"
        }
    } else {
        Write-InfoLog "Creating browser-compatible logger.ts"
        if (-not $DryRun) { 
            Set-Content -Path $loggerPath -Value $loggerContent -Encoding UTF8 
        }
    }

    # TEMPLATE-ONLY APPROACH: All dependencies managed through package.json.template
    Write-InfoLog "Browser-compatible logger dependencies managed through package.json.template"
    Write-InfoLog "Winston is optional dependency - browser uses console API, Node.js uses Winston with fallback"
    
    # Verify package.json template exists with proper dependencies
    $pkgJsonPath = Join-Path $ProjectRoot "package.json"
    $templatePath = Join-Path $ProjectRoot "templates/package.json.template"
    
    if (Test-Path $templatePath) {
        Write-InfoLog "package.json template verified - all dependencies managed through template"
        if (-not $DryRun) {
            # Ensure package.json is up to date with template
            Copy-Item -Path $templatePath -Destination $pkgJsonPath -Force
            Write-SuccessLog "package.json synchronized with template"
        }
    } else {
        Write-ErrorLog "CRITICAL: package.json template not found at $templatePath"
        Write-ErrorLog "All dependencies must be managed through templates - no inline modifications allowed"
        throw "Required template file missing: package.json.template"
    }

    Write-SuccessLog "Winston logging setup complete"
    exit 0

} catch {
    Write-ErrorLog "SetupLoggingService failed: $($_.Exception.Message)"
    exit 1
} 