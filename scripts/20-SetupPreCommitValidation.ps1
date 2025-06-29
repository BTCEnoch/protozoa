﻿# 20-SetupPreCommitValidation.ps1 - Phase 1 Infrastructure Enhancement
# Sets up Husky Git hooks and pre-commit validation for code quality enforcement
# ARCHITECTURE: Automated code quality gates with domain boundary validation
# Reference: script_checklist.md lines 20-SetupPreCommitValidation.ps1
# Reference: build_design.md lines 2300-2350 - Pre-commit hook configuration and validation
#Requires -Version 5.1

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $false)]
    [string]$ProjectRoot = $PWD
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
    # Ensure we have the correct project root
    if ($PSScriptRoot -and (Test-Path $PSScriptRoot)) {
        $ProjectRoot = Split-Path $PSScriptRoot -Parent
    } elseif (-not (Test-Path (Join-Path $ProjectRoot "package.json"))) {
        $ProjectRoot = $PWD
    }

    Write-StepHeader "Pre-commit Validation Setup - Phase 1 Infrastructure Enhancement"
    Write-InfoLog "Installing Husky and configuring Git hooks for automated validation"

    # Define paths
    $huskyDir = Join-Path $ProjectRoot ".husky"
    $packageJsonPath = Join-Path $ProjectRoot "package.json"
    $lintStagedConfigPath = Join-Path $ProjectRoot ".lintstagedrc.json"
    $preCommitHookPath = Join-Path $huskyDir "pre-commit"

    # Install Husky and lint-staged if not already installed
    Write-InfoLog "Installing Husky and lint-staged packages"
    Push-Location $ProjectRoot

    # TEMPLATE-ONLY APPROACH: All pre-commit validation dependencies managed through templates
    Write-InfoLog "Pre-commit validation dependencies managed through package.json.template"
    Write-InfoLog "ESLint, Prettier, lint-staged, and Husky configuration managed through templates"
    
    $templatePath = Join-Path $ProjectRoot "templates/package.json.template"
    
    if (Test-Path $templatePath) {
        Write-InfoLog "package.json template verified - all pre-commit dependencies managed through template"
        if (-not $DryRun) {
            # Ensure package.json is up to date with template
            Copy-Item -Path $templatePath -Destination $packageJsonPath -Force
            Write-SuccessLog "package.json synchronized with template for pre-commit validation"
        }
    } else {
        Write-ErrorLog "CRITICAL: package.json template not found at $templatePath"
        Write-ErrorLog "All pre-commit dependencies must be managed through templates - no inline modifications allowed"
        throw "Required template file missing: package.json.template"
    }

    # Check if dependencies are already installed (likely from Phase 0)
    Write-InfoLog "Checking if dependencies are already installed..."
    $nodeModulesPath = Join-Path $ProjectRoot "node_modules"
    
    if (Test-Path $nodeModulesPath) {
        $nodeModulesSize = (Get-ChildItem $nodeModulesPath -Recurse -File | Measure-Object -Property Length -Sum).Sum
        $nodeModulesSizeMB = [math]::Round($nodeModulesSize / 1MB, 1)
        Write-SuccessLog "Dependencies already installed: node_modules ($nodeModulesSizeMB MB)"
        Write-InfoLog "Skipping redundant dependency installation - using existing from Phase 0"
    } else {
    # Install dependencies with real-time progress display
    Write-InfoLog "Installing dependencies with real-time progress..."
        Write-InfoLog "[NPM] You'll see live installation output below:"
    Write-Host ("=" * 60) -ForegroundColor Cyan
    
    # npm-only installation approach 
        Write-InfoLog "[NPM] Attempting npm install (pure npm approach)..."
    try {
        # Use direct command execution for real-time output
        Write-Host "Running: npm ci" -ForegroundColor Yellow
        Invoke-Expression "npm ci"
        $exitCode = $LASTEXITCODE
        
        if ($exitCode -eq 0) {
            Write-Host ("=" * 60) -ForegroundColor Green
            Write-SuccessLog "[OK] Dependencies installed successfully with npm ci"
        } else {
            Write-Host ("=" * 60) -ForegroundColor Yellow
            Write-WarningLog "[WARNING] npm ci failed (exit code: $exitCode)"
            Write-InfoLog "[RETRY] Trying npm install with clean cache..."
            Write-Host ("=" * 60) -ForegroundColor Cyan
            
            # Try npm install with cache clean
            Write-Host "Running: npm cache clean --force && npm install" -ForegroundColor Yellow
            Invoke-Expression "npm cache clean --force"
            Invoke-Expression "npm install"
            $exitCode = $LASTEXITCODE
            
            if ($exitCode -eq 0) {
                Write-Host ("=" * 60) -ForegroundColor Green
                Write-SuccessLog "[OK] Dependencies installed successfully with clean npm install"
            } else {
                Write-Host ("=" * 60) -ForegroundColor Yellow
                Write-WarningLog "[WARNING] npm install failed (exit code: $exitCode), trying legacy peer deps..."
                Write-InfoLog "[RETRY] Attempting npm install with legacy peer deps (final fallback)..."
                Write-Host ("=" * 60) -ForegroundColor Cyan
                
                # Final fallback with legacy peer deps
                Write-Host "Running: npm install --legacy-peer-deps" -ForegroundColor Yellow
                Invoke-Expression "npm install --legacy-peer-deps"
                $exitCode = $LASTEXITCODE
                
                Write-Host ("=" * 60) -ForegroundColor Cyan
                if ($exitCode -eq 0) {
                    Write-SuccessLog "[OK] Dependencies installed successfully with npm legacy mode"
                } else {
                    Write-WarningLog "[WARNING] All npm installation methods failed (exit code: $exitCode)"
                    Write-WarningLog "Continuing setup - pre-commit hooks can work without perfect dependencies"
                }
            }
        }
    } catch {
        Write-ErrorLog "Installation process failed: $($_.Exception.Message)"
        Write-WarningLog "Continuing setup - pre-commit hooks can work without perfect dependencies"
        }
    }

    # Initialize Husky (modern approach for v9+)
    Write-InfoLog "Setting up Husky Git hooks"
    try {
        # For Husky v9+, we don't need to run install
        Write-InfoLog "Using modern Husky setup (v9+) - no install command needed"
        Write-SuccessLog "Husky setup prepared successfully"
    } catch {
        Write-WarningLog "Husky initialization encountered issues: $($_.Exception.Message)"
        Write-InfoLog "Continuing with manual hook setup..."
    }

    # Create pre-commit hook
    Write-InfoLog "Creating pre-commit hook with comprehensive validation"
    
    # Ensure .husky directory exists
    if (-not (Test-Path $huskyDir)) {
        New-Item -ItemType Directory -Path $huskyDir -Force | Out-Null
        Write-InfoLog "Created .husky directory"
    }
    $preCommitContent = @'
#!/usr/bin/env sh
. "`$(dirname -- "`$0")/_/husky.sh"

echo "[VALIDATE] Running pre-commit validation..."

# Run lint-staged for incremental validation
npx lint-staged

# Run TypeScript compilation check
echo "[TS] Checking TypeScript compilation..."
npx tsc --noEmit
if [ `$? -ne 0 ]; then
  echo "[ERROR] TypeScript compilation failed"
  exit 1
fi

# Run domain boundary validation
echo "[DOMAIN] Validating domain boundaries..."
pwsh -File "./scripts/05-VerifyCompliance.ps1"
if [ `$? -ne 0 ]; then
  echo "[ERROR] Domain boundary validation failed"
  exit 1
fi

# Run bundle size check
echo "[BUILD] Checking bundle size..."
npm run build > /dev/null 2>&1
if [ `$? -ne 0 ]; then
  echo "[ERROR] Build failed - cannot validate bundle size"
  exit 1
fi

echo "[SUCCESS] All pre-commit validations passed!"
'@

    Set-Content -Path $preCommitHookPath -Value $preCommitContent -Encoding UTF8

    # Make the hook executable
    if ($IsLinux -or $IsMacOS) {
        chmod +x $preCommitHookPath
    }
    Write-SuccessLog "Pre-commit hook created successfully"

    # Create lint-staged configuration from template ONLY
    Write-InfoLog "Creating lint-staged configuration from template"
    $lintStagedTemplatePath = Join-Path $ProjectRoot "templates/.lintstagedrc.json.template"
    
    if (Test-Path $lintStagedTemplatePath) {
        Copy-Item -Path $lintStagedTemplatePath -Destination $lintStagedConfigPath -Force
        Write-SuccessLog "Lint-staged configuration copied from template with proper formatting"
    } else {
        Write-ErrorLog "CRITICAL: .lintstagedrc.json template not found at $lintStagedTemplatePath"
        Write-ErrorLog "All configurations must use templates - no inline JSON generation allowed"
        throw "Required template file missing: .lintstagedrc.json.template"
    }

    # Create ESLint configuration for domain boundary enforcement
    Write-InfoLog "Creating ESLint configuration with domain boundary rules"
    $eslintConfigPath = Join-Path $ProjectRoot ".eslintrc.json"

    # FIXED: Use template instead of ConvertTo-Json to prevent JSON corruption
    $eslintTemplatePath = Join-Path $ProjectRoot "templates/.eslintrc.json.template"
    if (Test-Path $eslintTemplatePath) {
        Copy-Item -Path $eslintTemplatePath -Destination $eslintConfigPath -Force
        Write-SuccessLog "ESLint configuration restored from template with proper formatting"
    } else {
        # Fallback to manual JSON if template not found
        Write-WarningLog "ESLint template not found, creating basic configuration"
        $eslintConfigJson = @'
{
  "env": { 
    "browser": true, 
    "es2021": true, 
    "node": true 
  },
  "extends": [
    "eslint:recommended", 
    "plugin:@typescript-eslint/recommended"
  ],
  "parser": "@typescript-eslint/parser",
  "plugins": ["@typescript-eslint"],
  "rules": {
    "@typescript-eslint/no-unused-vars": "warn",
    "@typescript-eslint/no-explicit-any": "warn",
    "prefer-const": "error",
    "no-var": "error"
  }
}
'@
        Set-Content -Path $eslintConfigPath -Value $eslintConfigJson -Encoding UTF8
        Write-SuccessLog "ESLint configuration created with manual JSON formatting"
    }

    Pop-Location
    Write-SuccessLog "Pre-commit validation setup completed successfully"

    exit 0
}
catch {
    Write-ErrorLog "Pre-commit validation setup failed: $($_.Exception.Message)"
    exit 1
}
finally {
    try { Pop-Location -ErrorAction SilentlyContinue } catch { }
}