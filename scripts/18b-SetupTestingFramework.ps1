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

    $pkgPath = Join-Path $ProjectRoot "package.json"
    if (Test-Path $pkgPath) {
        $pkg = Get-Content $pkgPath -Raw | ConvertFrom-Json
    } else {
        $pkg = @{ name = "protozoa"; version = "0.0.1"; scripts = @{}; dependencies = @{}; devDependencies = @{} }
    }

    # Add devDependencies
    $devDeps = $pkg.devDependencies
    $addDep = { param($name, $version) 
        if (-not ($devDeps | Get-Member -Name $name -ErrorAction SilentlyContinue)) { 
            $devDeps | Add-Member -MemberType NoteProperty -Name $name -Value $version -Force
        } 
    }
    & $addDep "vitest" "^1.5.0"
    & $addDep "@vitest/coverage-v8" "^1.5.0"
    & $addDep "@types/node" "^20.5.0"
    & $addDep "ts-node" "^10.9.1"

    # Add test scripts
    if (-not ($pkg.scripts | Get-Member -Name "test" -ErrorAction SilentlyContinue)) { 
        $pkg.scripts | Add-Member -MemberType NoteProperty -Name "test" -Value "vitest run" -Force 
    }
    if (-not ($pkg.scripts | Get-Member -Name "test:watch" -ErrorAction SilentlyContinue)) { 
        $pkg.scripts | Add-Member -MemberType NoteProperty -Name "test:watch" -Value "vitest" -Force 
    }
    if (-not ($pkg.scripts | Get-Member -Name "coverage" -ErrorAction SilentlyContinue)) { 
        $pkg.scripts | Add-Member -MemberType NoteProperty -Name "coverage" -Value "vitest run --coverage" -Force 
    }

    # Husky pre-commit hook integration
    if (-not ($pkg.devDependencies | Get-Member -Name "husky" -ErrorAction SilentlyContinue)) { 
        $pkg.devDependencies | Add-Member -MemberType NoteProperty -Name "husky" -Value "^8.0.0" -Force 
    }
    if (-not ($pkg.scripts | Get-Member -Name "prepare" -ErrorAction SilentlyContinue)) { 
        $pkg.scripts | Add-Member -MemberType NoteProperty -Name "prepare" -Value "husky install" -Force 
    }

    # Configure pre-commit hook if .husky folder not present
    $huskyDir = Join-Path $ProjectRoot '.husky'
    if (-not (Test-Path $huskyDir) -and -not $DryRun) {
        npx husky install | Out-Null
        npx husky add .husky/pre-commit "pnpm test" | Out-Null
        Write-InfoLog "Husky pre-commit hook added to run tests"
    }

    if (-not $DryRun) {
        $pkg | ConvertTo-Json -Depth 20 | Set-Content -Path $pkgPath -Encoding UTF8
        Write-SuccessLog "package.json updated with Vitest dev dependencies and scripts"
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
