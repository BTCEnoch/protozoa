# 18b-SetupTestingFramework.ps1
# Sets up Vitest testing infrastructure with TS support and coverage
# Adds scripts to package.json and generates vitest.config.ts plus an example test file.

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $false)]
    [string]$ProjectRoot = (Split-Path $PSScriptRoot -Parent),

    [Parameter(Mandatory = $false)]
    [switch]$DryRun
)

try {
    Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop
} catch {
    Write-Error "Failed to import utils module: $($_.Exception.Message)"
    exit 1
}

$ErrorActionPreference = "Stop"

try {
    Write-StepHeader "Setup Vitest Testing Framework (18b)"
    Write-InfoLog "Scaffolding Vitest configuration and example tests"

    # TEMPLATE-ONLY APPROACH: All testing dependencies managed through package.json.template
    Write-InfoLog "Testing framework dependencies managed through package.json.template"
    Write-InfoLog "Vitest, coverage, and Husky configuration managed through templates"
    
    $pkgPath = Join-Path $ProjectRoot "package.json"
    $templatePath = Join-Path $ProjectRoot "templates/package.json.template"
    
    if (Test-Path $templatePath) {
        Write-InfoLog "package.json template verified - all testing dependencies managed through template"
        if (-not $DryRun) {
            # Ensure package.json is up to date with template
            Copy-Item -Path $templatePath -Destination $pkgPath -Force
            Write-SuccessLog "package.json synchronized with template for testing framework"
        }
    } else {
        Write-ErrorLog "CRITICAL: package.json template not found at $templatePath"
        Write-ErrorLog "All testing dependencies must be managed through templates - no inline modifications allowed"
        throw "Required template file missing: package.json.template"
    }

    # Configure pre-commit hook if .husky folder not present
    $huskyDir = Join-Path $ProjectRoot '.husky'
    if (-not (Test-Path $huskyDir) -and -not $DryRun) {
        Write-InfoLog "Setting up Husky pre-commit hooks"
        try {
            npx husky install | Out-Null
            npx husky add .husky/pre-commit "npm run test" | Out-Null
            Write-InfoLog "Husky pre-commit hook added to run tests"
        } catch {
            Write-WarningLog "Failed to setup Husky hooks: $($_.Exception.Message)"
        }
    }

    # Generate vitest.config.ts
    $vitestConfigPath = Join-Path $ProjectRoot "vitest.config.ts"
    $vitestConfig = @'
import { defineConfig } from "vitest/config"

export default defineConfig({
  test: {
    globals: true,
    environment: "node",
    coverage: { provider: "v8" },
    include: ["src/**/*.test.{ts,tsx}"],
  }
})
'@
    if (-not (Test-Path $vitestConfigPath)) {
        if (-not $DryRun) { Set-Content -Path $vitestConfigPath -Value $vitestConfig -Encoding UTF8 }
        Write-InfoLog "vitest.config.ts created"
    }

    # Create sample test file if tests folder empty
    $testsDir = Join-Path $ProjectRoot "src"
    $sampleTest = Join-Path $testsDir "sample.test.ts"
    if (-not (Test-Path $sampleTest)) {
        $sampleContent = @'
import { expect, test } from "vitest"

test("sample addition", () => {
  expect(1 + 1).toBe(2)
})
'@
        if (-not $DryRun) {
            if (-not (Test-Path $testsDir)) { New-Item -ItemType Directory -Path $testsDir -Force | Out-Null }
            Set-Content -Path $sampleTest -Value $sampleContent -Encoding UTF8
            Write-InfoLog "Sample test created: $sampleTest"
        }
    }

    Write-SuccessLog "Vitest scaffolding complete"
    exit 0
} catch {
    Write-ErrorLog "SetupTestingFramework failed: $($_.Exception.Message)"
    exit 1
}
