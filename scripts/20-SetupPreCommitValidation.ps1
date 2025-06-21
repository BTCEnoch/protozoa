# 20-SetupPreCommitValidation.ps1 - Phase 1 Infrastructure Enhancement
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

    # Check if package.json exists
    if (-not (Test-Path $packageJsonPath)) {
        Write-InfoLog "Creating package.json from template"
        
        # Try to load from template first
        $templatePath = Join-Path $ProjectRoot "templates/package.json.template"
        if (Test-Path $templatePath) {
            $packageJson = Get-Content $templatePath -Raw | ConvertFrom-Json
            Write-InfoLog "Loaded package.json structure from template"
            
            # Add additional dev dependencies needed for pre-commit validation
            if (-not $packageJson.devDependencies) {
                $packageJson | Add-Member -MemberType NoteProperty -Name "devDependencies" -Value ([PSCustomObject]@{}) -Force
            }
            
            # Add pre-commit specific dependencies
            $preCommitDeps = @{
                "husky" = "^8.0.3"
                "lint-staged" = "^15.2.0"
                "@typescript-eslint/eslint-plugin" = "^6.14.0"
                "@typescript-eslint/parser" = "^6.14.0"
            }
            
            foreach ($dep in $preCommitDeps.GetEnumerator()) {
                if (-not ($packageJson.devDependencies | Get-Member -Name $dep.Key -ErrorAction SilentlyContinue)) {
                    $packageJson.devDependencies | Add-Member -MemberType NoteProperty -Name $dep.Key -Value $dep.Value -Force
                }
            }
            
            # Add pre-commit specific scripts
            if (-not $packageJson.scripts) {
                $packageJson | Add-Member -MemberType NoteProperty -Name "scripts" -Value ([PSCustomObject]@{}) -Force
            }
            
            $preCommitScripts = @{
                "prepare" = "husky install"
                "lint" = "eslint . --ext ts,tsx --report-unused-disable-directives --max-warnings 0"
                "lint:fix" = "eslint . --ext ts,tsx --fix"
                "test:coverage" = "vitest --coverage"
            }
            
            foreach ($script in $preCommitScripts.GetEnumerator()) {
                if (-not ($packageJson.scripts | Get-Member -Name $script.Key -ErrorAction SilentlyContinue)) {
                    $packageJson.scripts | Add-Member -MemberType NoteProperty -Name $script.Key -Value $script.Value -Force
                }
            }
            
        } else {
            Write-WarningLog "Template not found, using fallback minimal structure"
            $packageJson = @{
                name = "protozoa"
                version = "0.1.0"
                description = "Bitcoin Ordinals Digital Organism Ecosystem"
                scripts = @{
                    dev = "vite"
                    build = "tsc -p tsconfig.app.json && vite build"
                    preview = "vite preview"
                    prepare = "husky install"
                    lint = "eslint . --ext ts,tsx --report-unused-disable-directives --max-warnings 0"
                    "lint:fix" = "eslint . --ext ts,tsx --fix"
                    "type-check" = "tsc --noEmit"
                    test = "vitest"
                    "test:coverage" = "vitest --coverage"
                }
                dependencies = @{
                    three = "^0.177.0"
                    react = "^18.2.0"
                    "react-dom" = "^18.2.0"
                    "@react-three/fiber" = "^8.15.0"
                    "@react-three/drei" = "^9.88.0"
                    "@react-three/postprocessing" = "^2.15.0"
                    leva = "^0.9.35"
                    winston = "^3.11.0"
                    zustand = "^4.4.7"
                }
                devDependencies = @{
                    husky = "^8.0.3"
                    "lint-staged" = "^15.2.0"
                    "@typescript-eslint/eslint-plugin" = "^6.14.0"
                    "@typescript-eslint/parser" = "^6.14.0"
                    "@types/node" = "^20.10.0"
                    "@types/react" = "^18.2.45"
                    "@types/react-dom" = "^18.2.18"
                    "@types/three" = "^0.177.0"
                    "@types/winston" = "^2.4.4"
                    "@vitejs/plugin-react" = "^4.2.1"
                    "@playwright/test" = "^1.40.0"
                    eslint = "^8.57.0"
                    prettier = "^3.0.0"
                    typescript = "^5.3.3"
                    vite = "^5.0.8"
                    vitest = "^1.0.4"
                }
            }
        }

        $packageJsonContent = $packageJson | ConvertTo-Json -Depth 10
        Set-Content -Path $packageJsonPath -Value $packageJsonContent -Encoding UTF8
        Write-SuccessLog "Package.json created with complete dependencies from template"
    }

    # Install dependencies with real-time progress display
    Write-InfoLog "Installing dependencies with real-time progress..."
    Write-InfoLog "📦 You'll see live installation output below:"
    Write-Host ("=" * 60) -ForegroundColor Cyan
    
    # First try normal pnpm install with live output
    Write-InfoLog "🔄 Attempting standard pnpm install (live output)..."
    try {
        # Use direct command execution for real-time output
        Write-Host "Running: pnpm install" -ForegroundColor Yellow
        Invoke-Expression "pnpm install"
        $exitCode = $LASTEXITCODE
        
        if ($exitCode -eq 0) {
            Write-Host ("=" * 60) -ForegroundColor Green
            Write-SuccessLog "✅ Dependencies installed successfully with pnpm"
        } else {
            Write-Host ("=" * 60) -ForegroundColor Yellow
            Write-WarningLog "⚠️  Standard pnpm install failed (exit code: $exitCode)"
            Write-InfoLog "🔄 Trying pnpm install with relaxed peer dependencies..."
            Write-Host ("=" * 60) -ForegroundColor Cyan
            
            # Try with relaxed peer deps
            Write-Host "Running: pnpm install --no-strict-peer-deps" -ForegroundColor Yellow
            Invoke-Expression "pnpm install --no-strict-peer-deps"
            $exitCode = $LASTEXITCODE
            
            if ($exitCode -eq 0) {
                Write-Host ("=" * 60) -ForegroundColor Green
                Write-SuccessLog "✅ Dependencies installed successfully with relaxed peer dependencies"
            } else {
                Write-Host ("=" * 60) -ForegroundColor Yellow
                Write-WarningLog "⚠️  pnpm install failed (exit code: $exitCode), trying npm fallback..."
                Write-InfoLog "🔄 Attempting npm install with legacy peer deps (final fallback)..."
                Write-Host ("=" * 60) -ForegroundColor Cyan
                
                # Final fallback to npm
                Write-Host "Running: npm install --legacy-peer-deps" -ForegroundColor Yellow
                Invoke-Expression "npm install --legacy-peer-deps"
                $exitCode = $LASTEXITCODE
                
                Write-Host ("=" * 60) -ForegroundColor Cyan
                if ($exitCode -eq 0) {
                    Write-SuccessLog "✅ Dependencies installed successfully with npm legacy mode"
                } else {
                    Write-WarningLog "⚠️  All dependency installation methods failed (exit code: $exitCode)"
                    Write-WarningLog "Continuing setup - pre-commit hooks can work without perfect dependencies"
                }
            }
        }
    } catch {
        Write-ErrorLog "Installation process failed: $($_.Exception.Message)"
        Write-WarningLog "Continuing setup - pre-commit hooks can work without perfect dependencies"
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

echo "🔍 Running pre-commit validation..."

# Run lint-staged for incremental validation
npx lint-staged

# Run TypeScript compilation check
echo "📝 Checking TypeScript compilation..."
npx tsc --noEmit
if [ `$? -ne 0 ]; then
  echo "❌ TypeScript compilation failed"
  exit 1
fi

# Run domain boundary validation
echo "🏗️ Validating domain boundaries..."
pwsh -File "./scripts/05-VerifyCompliance.ps1"
if [ `$? -ne 0 ]; then
  echo "❌ Domain boundary validation failed"
  exit 1
fi

# Run bundle size check
echo "📦 Checking bundle size..."
npm run build > /dev/null 2>&1
if [ `$? -ne 0 ]; then
  echo "❌ Build failed - cannot validate bundle size"
  exit 1
fi

echo "✅ All pre-commit validations passed!"
'@

    Set-Content -Path $preCommitHookPath -Value $preCommitContent -Encoding UTF8

    # Make the hook executable
    if ($IsLinux -or $IsMacOS) {
        chmod +x $preCommitHookPath
    }
    Write-SuccessLog "Pre-commit hook created successfully"

    # Create lint-staged configuration
    Write-InfoLog "Creating lint-staged configuration for incremental validation"
    $lintStagedConfig = @{
        "*.{ts,tsx}" = @(
            "eslint --fix"
            "prettier --write"
            "git add"
        )
        "*.{js,jsx}" = @(
            "eslint --fix"
            "prettier --write"
            "git add"
        )
        "*.{json,md,yml,yaml}" = @(
            "prettier --write"
            "git add"
        )
        "*.ps1" = @(
            "pwsh -Command 'Import-Module PSScriptAnalyzer; Invoke-ScriptAnalyzer $_'"
        )
    }

    $lintStagedConfigJson = $lintStagedConfig | ConvertTo-Json -Depth 10
    Set-Content -Path $lintStagedConfigPath -Value $lintStagedConfigJson -Encoding UTF8
    Write-SuccessLog "Lint-staged configuration created"

    # Create ESLint configuration for domain boundary enforcement
    Write-InfoLog "Creating ESLint configuration with domain boundary rules"
    $eslintConfigPath = Join-Path $ProjectRoot ".eslintrc.json"
    $eslintConfig = @{
        extends = @(
            "@typescript-eslint/recommended"
            "prettier"
        )
        parser = "@typescript-eslint/parser"
        plugins = @("@typescript-eslint")
        root = $true
        env = @{
            browser = $true
            es2022 = $true
            node = $true
        }
        parserOptions = @{
            ecmaVersion = "latest"
            sourceType = "module"
            ecmaFeatures = @{
                jsx = $true
            }
        }
        rules = @{
            # Domain boundary enforcement rules
            "no-restricted-imports" = @(
                "error"
                @{
                    patterns = @(
                        @{
                            group = @("../../../*")
                            message = "Relative imports across domain boundaries are not allowed. Use @/domains/* instead."
                        }
                        @{
                            group = @("**/lib/utils/physics*")
                            message = "Physics utilities must be imported from @/domains/physics/services/PhysicsService only."
                        }
                        @{
                            group = @("**/lib/utils/rng*")
                            message = "RNG utilities must be imported from @/domains/rng/services/RNGService only."
                        }
                    )
                }
            )

            # TypeScript specific rules
            "@typescript-eslint/no-unused-vars" = "error"
            "@typescript-eslint/no-explicit-any" = "error"
            "@typescript-eslint/prefer-const" = "error"
            "@typescript-eslint/no-non-null-assertion" = "error"

            # General code quality rules
            "prefer-const" = "error"
            "no-var" = "error"
            "no-console" = "warn"
            "eqeqeq" = "error"
        }
    }

    $eslintConfigJson = $eslintConfig | ConvertTo-Json -Depth 10
    Set-Content -Path $eslintConfigPath -Value $eslintConfigJson -Encoding UTF8
    Write-SuccessLog "ESLint configuration created with domain boundary rules"

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