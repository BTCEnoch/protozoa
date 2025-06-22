# 00b-ValidateNpmEnvironment.ps1
# npm environment validation and package integrity checks
# Ensures npm environment is properly configured for Protozoa development
# Validates Node.js, npm, package.json integrity, and dependency consistency

#Requires -Version 5.1

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [switch]$Detailed,

    [Parameter(Mandatory = $false)]
    [switch]$FixIssues,

    [Parameter(Mandatory = $false)]
    [string]$LogLevel = "Info"
)

# Import utilities
try {
    Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop
}
catch {
    Write-Error "Failed to import utilities module: $($_.Exception.Message)"
    exit 1
}

$ErrorActionPreference = "Stop"

# Initialize logging
Initialize-LogFile

Write-StepHeader "npm Environment Validation"
Write-InfoLog "Validating npm environment and package integrity"
Write-InfoLog "Detailed mode: $Detailed"
Write-InfoLog "Fix issues: $FixIssues"

# Navigate to project root
$projectRoot = Split-Path $PSScriptRoot -Parent
Push-Location $projectRoot

$validationResults = @{
    NodeJs = $false
    Npm = $false
    PackageJson = $false
    Dependencies = $false
    LockFile = $false
    Configuration = $false
    Registry = $false
    Issues = @()
    Warnings = @()
}

try {
    # Validate Node.js installation
    Write-InfoLog "Validating Node.js installation..."
    
    if (Test-NodeInstalled) {
        $nodeVersion = node --version
        $nodeVersionNumber = $nodeVersion -replace '^v', ''
        $majorVersion = [int]($nodeVersionNumber -split '\.')[0]
        
        Write-SuccessLog "Node.js detected: $nodeVersion"
        
        if ($majorVersion -ge 18) {
            Write-SuccessLog "Node.js version meets React/Vite requirements (v18+)"
            $validationResults.NodeJs = $true
        } else {
            $issue = "Node.js version $nodeVersion is below minimum requirement (v18.x)"
            $validationResults.Issues += $issue
            Write-ErrorLog $issue
        }
        
        if ($Detailed) {
            $nodeInfo = node -e "console.log(JSON.stringify(process.versions, null, 2))" | ConvertFrom-Json
            Write-InfoLog "Node.js details:"
            Write-InfoLog "  V8 engine: $($nodeInfo.v8)"
            Write-InfoLog "  OpenSSL: $($nodeInfo.openssl)"
            Write-InfoLog "  UV: $($nodeInfo.uv)"
        }
    } else {
        $issue = "Node.js is not installed or not in PATH"
        $validationResults.Issues += $issue
        Write-ErrorLog $issue
    }

    # Validate npm installation
    Write-InfoLog "Validating npm installation..."
    
    if (Get-Command npm -ErrorAction SilentlyContinue) {
        $npmVersion = npm --version
        Write-SuccessLog "npm detected: $npmVersion"
        
        # Test npm functionality
        $npmTest = npm config get registry 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-SuccessLog "npm functionality verified"
            $validationResults.Npm = $true
            
            if ($Detailed) {
                Write-InfoLog "npm registry: $npmTest"
                $npmRoot = npm root -g 2>$null
                if ($npmRoot) {
                    Write-InfoLog "npm global root: $npmRoot"
                }
            }
        } else {
            $issue = "npm functionality test failed: $npmTest"
            $validationResults.Issues += $issue
            Write-ErrorLog $issue
        }
    } else {
        $issue = "npm is not installed or not in PATH"
        $validationResults.Issues += $issue
        Write-ErrorLog $issue
    }

    # Validate package.json
    Write-InfoLog "Validating package.json..."
    
    if (Test-Path "package.json") {
        try {
            $packageJson = Get-Content "package.json" -Raw | ConvertFrom-Json
            Write-SuccessLog "package.json found and valid JSON"
            
            # Check essential fields
            $requiredFields = @('name', 'version', 'dependencies', 'devDependencies', 'scripts')
            $missingFields = @()
            
            foreach ($field in $requiredFields) {
                if (-not $packageJson.$field) {
                    $missingFields += $field
                }
            }
            
            if ($missingFields.Count -eq 0) {
                Write-SuccessLog "All required package.json fields present"
                $validationResults.PackageJson = $true
                
                # Check packageManager field
                if ($packageJson.packageManager -and $packageJson.packageManager -like "npm*") {
                    Write-SuccessLog "packageManager field correctly set to npm"
                } else {
                    $warning = "packageManager field not set to npm"
                    $validationResults.Warnings += $warning
                    Write-WarningLog $warning
                }
            } else {
                $issue = "Missing required package.json fields: $($missingFields -join ', ')"
                $validationResults.Issues += $issue
                Write-ErrorLog $issue
            }
            
            if ($Detailed) {
                $depCount = if ($packageJson.dependencies) { $packageJson.dependencies.PSObject.Properties.Count } else { 0 }
                $devDepCount = if ($packageJson.devDependencies) { $packageJson.devDependencies.PSObject.Properties.Count } else { 0 }
                Write-InfoLog "Package details:"
                Write-InfoLog "  Name: $($packageJson.name)"
                Write-InfoLog "  Version: $($packageJson.version)"
                Write-InfoLog "  Dependencies: $depCount"
                Write-InfoLog "  Dev dependencies: $devDepCount"
            }
        }
        catch {
            $issue = "Invalid package.json: $($_.Exception.Message)"
            $validationResults.Issues += $issue
            Write-ErrorLog $issue
        }
    } else {
        $issue = "package.json not found"
        $validationResults.Issues += $issue
        Write-ErrorLog $issue
    }

    # Validate npm registry connectivity
    Write-InfoLog "Validating npm registry connectivity..."
    
    try {
        $registryTest = npm ping --silent 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-SuccessLog "npm registry connectivity verified"
            $validationResults.Registry = $true
        } else {
            $warning = "npm registry ping failed: $registryTest"
            $validationResults.Warnings += $warning
            Write-WarningLog $warning
        }
    }
    catch {
        $warning = "Could not test npm registry connectivity: $($_.Exception.Message)"
        $validationResults.Warnings += $warning
        Write-WarningLog $warning
    }

    # Check for legacy package manager files
    Write-InfoLog "Checking for legacy package manager files..."
    
    $legacyFiles = @()
    if (Test-Path "pnpm-lock.yaml") { $legacyFiles += "pnpm-lock.yaml" }
    if (Test-Path "yarn.lock") { $legacyFiles += "yarn.lock" }
    
    if ($legacyFiles.Count -gt 0) {
        $warning = "Legacy package manager files found: $($legacyFiles -join ', ')"
        $validationResults.Warnings += $warning
        Write-WarningLog $warning
        
        if ($FixIssues) {
            Write-InfoLog "Removing legacy package manager files..."
            foreach ($file in $legacyFiles) {
                Remove-Item -Path $file -Force
                Write-InfoLog "Removed $file"
            }
            Write-SuccessLog "Legacy files cleanup completed"
        }
    } else {
        Write-SuccessLog "No legacy package manager files found"
    }
    
}
catch {
    $issue = "Validation error: $($_.Exception.Message)"
    $validationResults.Issues += $issue
    Write-ErrorLog $issue
}
finally {
    Pop-Location -ErrorAction SilentlyContinue
}

# Generate validation summary
Write-StepHeader "npm Environment Validation Summary"

$allChecks = @('NodeJs', 'Npm', 'PackageJson', 'Registry')
$passedChecks = $allChecks | Where-Object { $validationResults.$_ -eq $true }
$failedChecks = $allChecks | Where-Object { $validationResults.$_ -eq $false }

Write-InfoLog "Validation results:"
foreach ($check in $allChecks) {
            $status = if ($validationResults.$check) { "[OK] PASS" } else { "[FAIL] FAIL" }
    Write-InfoLog "  $check`: $status"
}

if ($validationResults.Issues.Count -gt 0) {
    Write-ErrorLog " "
    Write-ErrorLog "Issues found ($($validationResults.Issues.Count)):"
    foreach ($issue in $validationResults.Issues) {
        Write-ErrorLog "  - $issue"
    }
}

if ($validationResults.Warnings.Count -gt 0) {
    Write-WarningLog " "
    Write-WarningLog "Warnings ($($validationResults.Warnings.Count)):"
    foreach ($warning in $validationResults.Warnings) {
        Write-WarningLog "  - $warning"
    }
}

Write-InfoLog " "
if ($failedChecks.Count -eq 0 -and $validationResults.Issues.Count -eq 0) {
    Write-SuccessLog "[SUCCESS] All validation checks passed!"
    Write-InfoLog "Environment is ready for Protozoa development with pure npm approach"
    Write-InfoLog " "
    Write-InfoLog "Next steps:"
    Write-InfoLog "  1. Run 'npm install' or use 00a-NpmInstallWithProgress.ps1"
    Write-InfoLog "  2. Use 'npm run dev' to start development server"
    exit 0
} else {
            Write-ErrorLog "[ERROR] Validation failed - $($failedChecks.Count) checks failed, $($validationResults.Issues.Count) issues found"    
    Write-InfoLog " "
    Write-InfoLog "Recommended actions:"
    if ('NodeJs' -in $failedChecks) {
        Write-InfoLog "  - Install or update Node.js to v18+ from https://nodejs.org/"
    }
    if ('Npm' -in $failedChecks) {
        Write-InfoLog "  - Ensure npm is properly installed (comes with Node.js)"
    }
    if ('PackageJson' -in $failedChecks) {
        Write-InfoLog "  - Fix package.json issues or restore from template"
    }
    if ('Registry' -in $failedChecks) {
        Write-InfoLog "  - Check network connectivity and proxy settings"
    }
    if ($FixIssues) {
        Write-InfoLog "  - Some issues were automatically fixed"
    } else {
        Write-InfoLog "  - Run with -FixIssues to attempt automatic repairs"
    }
    exit 1
}

# Return validation results for programmatic use
return $validationResults 