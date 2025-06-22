# 54a-SetupPerformanceBenchmarks.ps1
# Template-driven performance benchmark setup
# ZERO inline code generation - Templates ONLY

<#
.SYNOPSIS
    Sets up performance benchmarks using templates only (NO inline generation)
.DESCRIPTION
    Creates performance test suite from comprehensive templates:
    - particle.perf.test.ts from template
    - physics.perf.test.ts from template
    - benchmark.config.ts from template
    - benchmark.yml workflow from template
    Follows template-first architecture with zero tolerance for inline generation
.PARAMETER ProjectRoot
    Root directory of the project (defaults to current directory)
.PARAMETER DryRun
    Preview changes without writing files
.EXAMPLE
    .\54a-SetupPerformanceBenchmarks.ps1 -ProjectRoot "C:\Projects\Protozoa"
.NOTES
    Template-first architecture enforcement - NO inline generation allowed
#>
param(
    [string]$ProjectRoot = $PWD,
    [switch]$DryRun
)

try { Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop } catch { Write-Error "utils import failed"; exit 1 }
$ErrorActionPreference = 'Stop'

try {
    Write-StepHeader "Template-Only Performance Benchmarks Setup"
    Write-InfoLog "Setting up performance benchmarks using templates only..."
    
    # Setup paths
    $perfTestsPath = Join-Path $ProjectRoot "tests/performance"
    $githubWorkflowsPath = Join-Path $ProjectRoot ".github/workflows"
    
    # Ensure performance tests directory exists
    if (-not (Test-Path $perfTestsPath)) {
        if (-not $DryRun) {
            New-Item -ItemType Directory -Path $perfTestsPath -Force | Out-Null
        }
        Write-InfoLog "Created performance tests directory: $perfTestsPath"
    }

    # Ensure GitHub workflows directory exists
    if (-not (Test-Path $githubWorkflowsPath)) {
        if (-not $DryRun) {
            New-Item -ItemType Directory -Path $githubWorkflowsPath -Force | Out-Null
        }
        Write-InfoLog "Created GitHub workflows directory: $githubWorkflowsPath"
    }

    # Generate particle performance tests from template
    Write-InfoLog "Generating particle performance tests from template"
    $particlePerfTemplate = Join-Path $ProjectRoot "templates/tests/performance/particle.perf.test.ts.template"
    $particlePerfPath = Join-Path $perfTestsPath "particle.perf.test.ts"
    
    if (Test-Path $particlePerfTemplate) {
        if (-not $DryRun) {
            Copy-Item $particlePerfTemplate $particlePerfPath -Force
        }
        Write-SuccessLog "particle.perf.test.ts generated from template successfully"
    } else {
        Write-ErrorLog "Particle performance template not found: $particlePerfTemplate"
        throw "Template file missing: particle.perf.test.ts.template"
    }

    # Generate physics performance tests from template
    Write-InfoLog "Generating physics performance tests from template"
    $physicsPerfTemplate = Join-Path $ProjectRoot "templates/tests/performance/physics.perf.test.ts.template"
    $physicsPerfPath = Join-Path $perfTestsPath "physics.perf.test.ts"
    
    if (Test-Path $physicsPerfTemplate) {
        if (-not $DryRun) {
            Copy-Item $physicsPerfTemplate $physicsPerfPath -Force
        }
        Write-SuccessLog "physics.perf.test.ts generated from template successfully"
    } else {
        Write-ErrorLog "Physics performance template not found: $physicsPerfTemplate"
        throw "Template file missing: physics.perf.test.ts.template"
    }

    # Generate benchmark configuration from template
    Write-InfoLog "Generating benchmark configuration from template"
    $benchConfigTemplate = Join-Path $ProjectRoot "templates/tests/performance/benchmark.config.ts.template"
    $benchConfigPath = Join-Path $perfTestsPath "benchmark.config.ts"
    
    if (Test-Path $benchConfigTemplate) {
        if (-not $DryRun) {
            Copy-Item $benchConfigTemplate $benchConfigPath -Force
        }
        Write-SuccessLog "benchmark.config.ts generated from template successfully"
    } else {
        Write-ErrorLog "Benchmark config template not found: $benchConfigTemplate"
        throw "Template file missing: benchmark.config.ts.template"
    }

    # Generate GitHub Actions benchmark workflow from template
    Write-InfoLog "Generating GitHub Actions benchmark workflow from template"
    $workflowTemplate = Join-Path $ProjectRoot "templates/.github/workflows/benchmark.yml.template"
    $workflowPath = Join-Path $githubWorkflowsPath "benchmark.yml"
    
    if (Test-Path $workflowTemplate) {
        if (-not $DryRun) {
            Copy-Item $workflowTemplate $workflowPath -Force
        }
        Write-SuccessLog "benchmark.yml workflow generated from template successfully"
    } else {
        Write-ErrorLog "Benchmark workflow template not found: $workflowTemplate"
        throw "Template file missing: benchmark.yml.template"
    }

    Write-SuccessLog "Performance benchmarks setup completed successfully!"
    Write-InfoLog "Generated files:"
    Write-InfoLog "  - particle.perf.test.ts (from template)"
    Write-InfoLog "  - physics.perf.test.ts (from template)"
    Write-InfoLog "  - benchmark.config.ts (from template)"
    Write-InfoLog "  - .github/workflows/benchmark.yml (from template)"
    Write-InfoLog "Architecture: 100% template-driven, ZERO inline generation"

    exit 0
    
} catch {
    Write-ErrorLog "Performance benchmarks setup failed: $_"
    Write-DebugLog "Stack trace: $($_.ScriptStackTrace)"
    exit 1
} 