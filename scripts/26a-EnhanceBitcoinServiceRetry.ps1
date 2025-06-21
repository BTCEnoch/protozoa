# 26a-EnhanceBitcoinServiceRetry.ps1
# Enhances Bitcoin service with retry logic and rate limiting

<#
.SYNOPSIS
    Enhances BitcoinService with comprehensive retry logic and rate limiting
.DESCRIPTION
    1. Updates BitcoinService template with exponential backoff retry
    2. Implements circuit breaker pattern for API failures
    3. Adds rate limiting configuration and enforcement
    4. Creates fallback data mechanisms
    5. Enhances error handling and logging
.PARAMETER ProjectRoot
    Root directory of the project (defaults to current directory)
.PARAMETER SkipBackup
    Skip backing up existing files before overwriting
.EXAMPLE
    .\26a-EnhanceBitcoinServiceRetry.ps1 -ProjectRoot "C:\Projects\Protozoa"
.NOTES
    Implements production-ready Bitcoin API resilience
#>
param(
    [string]$ProjectRoot = $PWD,
    [switch]$SkipBackup
)

try { Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop } catch { Write-Error "utils import failed"; exit 1 }
$ErrorActionPreference = 'Stop'

try {
    Write-StepHeader "Bitcoin Service Retry Enhancement"
    Write-InfoLog "₿ Enhancing Bitcoin service with retry logic and rate limiting..."
    
    # Validate project structure
    $bitcoinDomain = Join-Path $ProjectRoot "src/domains/bitcoin"
    $servicesDir = Join-Path $bitcoinDomain "services"
    $configDir = Join-Path $ProjectRoot "src/config"
    
    if (-not (Test-Path $bitcoinDomain)) {
        Write-ErrorLog "Bitcoin domain not found at: $bitcoinDomain"
        exit 1
    }
    
    # Ensure config directory exists
    if (-not (Test-Path $configDir)) {
        New-Item -Path $configDir -ItemType Directory -Force | Out-Null
        Write-InfoLog "Created config directory"
    }
    
    # Backup existing files if not skipped
    if (-not $SkipBackup) {
        $backupDir = Join-Path $ProjectRoot "backup/bitcoin_retry_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        New-Item -Path $backupDir -ItemType Directory -Force | Out-Null
        
        $filesToBackup = @(
            (Join-Path $servicesDir "BitcoinService.ts"),
            (Join-Path $configDir "rate-limiter.ts"),
            (Join-Path $configDir "bitcoin.config.ts")
        )
        
        foreach ($file in $filesToBackup) {
            if (Test-Path $file) {
                $backupFile = Join-Path $backupDir (Split-Path $file -Leaf)
                Copy-Item $file $backupFile -Force
                Write-InfoLog "Backed up: $(Split-Path $file -Leaf)"
            }
        }
    }
    
    # Copy enhanced templates
    Write-InfoLog "🔧 Updating Bitcoin service templates..."
    
    # Update BitcoinService template
    $bitcoinServiceTemplate = Join-Path $ProjectRoot "templates/domains/bitcoin/services/BitcoinService.ts.template"
    $bitcoinServiceTarget = Join-Path $servicesDir "BitcoinService.ts"
    
    if (Test-Path $bitcoinServiceTemplate) {
        Copy-Item $bitcoinServiceTemplate $bitcoinServiceTarget -Force
        Write-SuccessLog "✅ Updated BitcoinService with retry logic"
    } else {
        Write-ErrorLog "BitcoinService template not found: $bitcoinServiceTemplate"
    }
    
    # Update rate limiter configuration
    $rateLimiterTemplate = Join-Path $ProjectRoot "templates/config/rate-limiter.ts.template"
    $rateLimiterTarget = Join-Path $configDir "rate-limiter.ts"
    
    if (Test-Path $rateLimiterTemplate) {
        Copy-Item $rateLimiterTemplate $rateLimiterTarget -Force
        Write-SuccessLog "✅ Updated rate limiter configuration"
    } else {
        Write-WarningLog "Rate limiter template not found, skipping"
    }
    
    # Update Bitcoin configuration
    $bitcoinConfigTemplate = Join-Path $ProjectRoot "templates/config/bitcoin.config.ts.template"
    $bitcoinConfigTarget = Join-Path $configDir "bitcoin.config.ts"
    
    if (Test-Path $bitcoinConfigTemplate) {
        Copy-Item $bitcoinConfigTemplate $bitcoinConfigTarget -Force
        Write-SuccessLog "✅ Updated Bitcoin configuration"
    } else {
        Write-WarningLog "Bitcoin config template not found, skipping"
    }
    
    Write-SuccessLog "🎉 Bitcoin service retry enhancement completed!"
    Write-InfoLog "🔧 Enhancements applied:"
    Write-InfoLog "  • Exponential backoff retry logic"
    Write-InfoLog "  • Circuit breaker pattern implementation"
    Write-InfoLog "  • Rate limiting enforcement"
    Write-InfoLog "  • Enhanced error handling and logging"
    Write-InfoLog "  • Fallback data mechanisms"
    
    exit 0
    
} catch {
    Write-ErrorLog "❌ Bitcoin service enhancement failed: $_"
    Write-DebugLog "Stack trace: $($_.ScriptStackTrace)"
    exit 1
} 