# 20-SetupPreCommitValidation.ps1 - Phase 1 Infrastructure Enhancement
# Sets up Husky Git hooks and pre-commit validation for code quality enforcement
# ARCHITECTURE: Automated code quality gates with domain boundary validation
# Reference: script_checklist.md lines 20-SetupPreCommitValidation.ps1
# Reference: build_design.md lines 2300-2350 - Pre-commit hook configuration and validation
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
        Write-InfoLog "Creating package.json"
        $packageJson = @{
            name = "protozoa-bitcoin-organisms"
            version = "1.0.0"
            description = "Bitcoin Ordinals Digital Organism Ecosystem"
            main = "index.js"
            scripts = @{
                dev = "vite"
                build = "tsc && vite build"
                preview = "vite preview"
                prepare = "husky install"
                lint = "eslint . --ext ts,tsx --report-unused-disable-directives --max-warnings 0"
                "lint:fix" = "eslint . --ext ts,tsx --fix"
                "type-check" = "tsc --noEmit"
                test = "vitest"
                "test:coverage" = "vitest --coverage"
            }
            devDependencies = @{
                husky = "^8.0.3"
                "lint-staged" = "^15.2.0"
                "@typescript-eslint/eslint-plugin" = "^6.14.0"
                "@typescript-eslint/parser" = "^6.14.0"
                eslint = "^8.55.0"
                prettier = "^3.1.1"
                typescript = "^5.2.2"
                vite = "^5.0.8"
                vitest = "^1.0.4"
            }
        }

        $packageJsonContent = $packageJson | ConvertTo-Json -Depth 10
        Set-Content -Path $packageJsonPath -Value $packageJsonContent -Encoding UTF8
        Write-SuccessLog "Package.json created with required dependencies"
    }

    # Install dependencies
    & npm install
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to install npm dependencies"
    }
    Write-SuccessLog "Dependencies installed successfully"

    # Initialize Husky
    Write-InfoLog "Initializing Husky Git hooks"
    & npx husky install
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to initialize Husky"
    }
    Write-SuccessLog "Husky initialized successfully"

    # Create pre-commit hook
    Write-InfoLog "Creating pre-commit hook with comprehensive validation"
    $preCommitContent = @"
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
"@

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