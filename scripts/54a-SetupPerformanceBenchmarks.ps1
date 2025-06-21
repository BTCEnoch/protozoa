# 54a-SetupPerformanceBenchmarks.ps1
# Adds vitest + tinybench benchmark harness for physics & particle algorithms
# Provides comprehensive performance testing and regression detection
# Usage: Executed by automation suite to establish performance monitoring infrastructure

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
    Write-StepHeader "Setup Performance Benchmarks (54)"
    Write-InfoLog "Installing benchmark packages and creating performance test suites"

    # Check for package manager
    $packageManager = "npm"
    if (Test-PnpmInstalled) {
        $packageManager = "pnpm"
        Write-InfoLog "Using pnpm for package installation"
    } else {
        Write-InfoLog "Using npm for package installation"
    }

    # Install performance testing packages
    $benchmarkPackages = @(
        "vitest@^1.0.4",
        "tinybench@^2.5.1",
        "@vitest/ui@^1.0.4",
        "benchmark@^2.1.4",
        "@types/benchmark@^2.1.2"
    )

    Write-InfoLog "Installing performance benchmark packages..."
    if (-not $DryRun) {
        $installCmd = "$packageManager add -D " + ($benchmarkPackages -join " ")
        Write-DebugLog "Executing: $installCmd"
        
        Invoke-Expression $installCmd
        if ($LASTEXITCODE -ne 0) {
            throw "Package installation failed with exit code $LASTEXITCODE"
        }
    }
    Write-SuccessLog "Performance benchmark packages installed successfully"

    # Create performance tests directory
    $perfTestsPath = Join-Path $ProjectRoot "tests/performance"
    if (-not (Test-Path $perfTestsPath)) {
        Write-InfoLog "Creating performance tests directory"
        if (-not $DryRun) {
            New-Item -ItemType Directory -Path $perfTestsPath -Force | Out-Null
        }
    }

    # Generate particle performance tests
    $particlePerfPath = Join-Path $perfTestsPath "particle.perf.test.ts"
    $particlePerfContent = @'
/**
 * Particle system performance benchmarks
 * Tests particle allocation, updates, and memory management
 * 
 * @author Protozoa Automation Suite
 * @generated 54-SetupPerformanceBenchmarks.ps1
 */

import { describe, test, expect, beforeEach } from 'vitest'
import { Bench } from 'tinybench'
import { ParticleService } from '@/domains/particle/services/ParticleService'
import { PhysicsService } from '@/domains/physics/services/PhysicsService'
import { RNGService } from '@/domains/rng/services/RNGService'

describe('Particle System Performance', () => {
  let particleService: ParticleService
  let physicsService: PhysicsService
  let rngService: RNGService

  beforeEach(() => {
    rngService = new RNGService()
    physicsService = new PhysicsService()
    particleService = new ParticleService(rngService, physicsService)
  })

  test('Particle Allocation Benchmarks', async () => {
    const bench = new Bench({ time: 1000 })

    bench
      .add('allocate 100 particles', () => {
        for (let i = 0; i < 100; i++) {
          particleService.createParticle({
            position: { x: 0, y: 0, z: 0 },
            velocity: { x: 1, y: 1, z: 1 },
            type: 'basic'
          })
        }
      })
      .add('allocate 500 particles', () => {
        for (let i = 0; i < 500; i++) {
          particleService.createParticle({
            position: { x: 0, y: 0, z: 0 },
            velocity: { x: 1, y: 1, z: 1 },
            type: 'basic'
          })
        }
      })
      .add('allocate 1000 particles', () => {
        for (let i = 0; i < 1000; i++) {
          particleService.createParticle({
            position: { x: 0, y: 0, z: 0 },
            velocity: { x: 1, y: 1, z: 1 },
            type: 'basic'
          })
        }
      })

    await bench.run()

    console.table(bench.table())

    // Performance assertions
    const allocate100 = bench.tasks.find(t => t.name === 'allocate 100 particles')
    const allocate500 = bench.tasks.find(t => t.name === 'allocate 500 particles')
    const allocate1000 = bench.tasks.find(t => t.name === 'allocate 1000 particles')

    // Should be able to allocate 100 particles in under 10ms
    expect(allocate100?.result?.mean).toBeLessThan(10)
    
    // 500 particles should scale reasonably (under 50ms)
    expect(allocate500?.result?.mean).toBeLessThan(50)
    
    // 1000 particles should still be performant (under 100ms)
    expect(allocate1000?.result?.mean).toBeLessThan(100)
  })

  test('Particle Update Performance', async () => {
    // Pre-allocate particles for testing
    const particles = []
    for (let i = 0; i < 1000; i++) {
      particles.push(particleService.createParticle({
        position: { x: rngService.random() * 100, y: rngService.random() * 100, z: rngService.random() * 100 },
        velocity: { x: rngService.random() * 10, y: rngService.random() * 10, z: rngService.random() * 10 },
        type: 'basic'
      }))
    }

    const bench = new Bench({ time: 1000 })

    bench
      .add('update 100 particles', () => {
        for (let i = 0; i < 100; i++) {
          particleService.updateParticle(particles[i], 0.016) // 60fps delta
        }
      })
      .add('update 500 particles', () => {
        for (let i = 0; i < 500; i++) {
          particleService.updateParticle(particles[i], 0.016)
        }
      })
      .add('update 1000 particles', () => {
        for (let i = 0; i < 1000; i++) {
          particleService.updateParticle(particles[i], 0.016)
        }
      })

    await bench.run()

    console.table(bench.table())

    // Performance assertions for 60fps target (16.67ms frame budget)
    const update100 = bench.tasks.find(t => t.name === 'update 100 particles')
    const update500 = bench.tasks.find(t => t.name === 'update 500 particles')
    const update1000 = bench.tasks.find(t => t.name === 'update 1000 particles')

    // Should update 100 particles well within frame budget
    expect(update100?.result?.mean).toBeLessThan(2)
    
    // 500 particles should still be fast
    expect(update500?.result?.mean).toBeLessThan(8)
    
    // 1000 particles should be manageable
    expect(update1000?.result?.mean).toBeLessThan(16)
  })

  test('Memory Pool Performance', async () => {
    const bench = new Bench({ time: 1000 })

    bench
      .add('allocate and release 1000 particles', () => {
        const allocated = []
        
        // Allocate
        for (let i = 0; i < 1000; i++) {
          allocated.push(particleService.createParticle({
            position: { x: 0, y: 0, z: 0 },
            velocity: { x: 1, y: 1, z: 1 },
            type: 'basic'
          }))
        }
        
        // Release
        allocated.forEach(particle => {
          particleService.destroyParticle(particle.id)
        })
      })
      .add('reuse pooled particles', () => {
        const allocated = []
        
        // First allocation cycle
        for (let i = 0; i < 100; i++) {
          allocated.push(particleService.createParticle({
            position: { x: 0, y: 0, z: 0 },
            velocity: { x: 1, y: 1, z: 1 },
            type: 'basic'
          }))
        }
        
        allocated.forEach(particle => {
          particleService.destroyParticle(particle.id)
        })
        
        // Second allocation cycle (should reuse pooled objects)
        for (let i = 0; i < 100; i++) {
          allocated.push(particleService.createParticle({
            position: { x: 0, y: 0, z: 0 },
            velocity: { x: 1, y: 1, z: 1 },
            type: 'basic'
          }))
        }
        
        allocated.forEach(particle => {
          particleService.destroyParticle(particle.id)
        })
      })

    await bench.run()
    console.table(bench.table())
  })
})
'@

    Write-InfoLog "Generating particle performance tests"
    if (-not $DryRun) {
        Set-Content -Path $particlePerfPath -Value $particlePerfContent -Encoding UTF8
    }
    Write-SuccessLog "particle.perf.test.ts created successfully"

    # Generate physics performance tests
    $physicsPerfPath = Join-Path $perfTestsPath "physics.perf.test.ts"
    $physicsPerfContent = @'
/**
 * Physics system performance benchmarks
 * Tests collision detection, force calculations, and integration
 * 
 * @author Protozoa Automation Suite
 * @generated 54-SetupPerformanceBenchmarks.ps1
 */

import { describe, test, expect, beforeEach } from 'vitest'
import { Bench } from 'tinybench'
import { PhysicsService } from '@/domains/physics/services/PhysicsService'
import { RNGService } from '@/domains/rng/services/RNGService'

describe('Physics System Performance', () => {
  let physicsService: PhysicsService
  let rngService: RNGService

  beforeEach(() => {
    rngService = new RNGService()
    physicsService = new PhysicsService()
  })

  test('Collision Detection Benchmarks', async () => {
    // Generate test particles
    const particles = []
    for (let i = 0; i < 1000; i++) {
      particles.push({
        id: `particle_${i}`,
        position: { 
          x: rngService.random() * 200 - 100,
          y: rngService.random() * 200 - 100,
          z: rngService.random() * 200 - 100
        },
        velocity: { x: 0, y: 0, z: 0 },
        radius: 1.0,
        mass: 1.0
      })
    }

    const bench = new Bench({ time: 1000 })

    bench
      .add('naive collision detection (100 particles)', () => {
        const subset = particles.slice(0, 100)
        const collisions = []
        
        for (let i = 0; i < subset.length; i++) {
          for (let j = i + 1; j < subset.length; j++) {
            if (physicsService.checkCollision(subset[i], subset[j])) {
              collisions.push([i, j])
            }
          }
        }
      })
      .add('spatial hash collision detection (100 particles)', () => {
        const subset = particles.slice(0, 100)
        physicsService.detectCollisionsSpatialHash(subset)
      })
      .add('naive collision detection (500 particles)', () => {
        const subset = particles.slice(0, 500)
        const collisions = []
        
        for (let i = 0; i < subset.length; i++) {
          for (let j = i + 1; j < subset.length; j++) {
            if (physicsService.checkCollision(subset[i], subset[j])) {
              collisions.push([i, j])
            }
          }
        }
      })
      .add('spatial hash collision detection (500 particles)', () => {
        const subset = particles.slice(0, 500)
        physicsService.detectCollisionsSpatialHash(subset)
      })

    await bench.run()
    console.table(bench.table())

    // Performance assertions
    const spatialHash100 = bench.tasks.find(t => t.name === 'spatial hash collision detection (100 particles)')
    const spatialHash500 = bench.tasks.find(t => t.name === 'spatial hash collision detection (500 particles)')

    // Spatial hash should be efficient for collision detection
    expect(spatialHash100?.result?.mean).toBeLessThan(5)
    expect(spatialHash500?.result?.mean).toBeLessThan(25)
  })

  test('Force Calculation Performance', async () => {
    const particles = []
    for (let i = 0; i < 100; i++) {
      particles.push({
        id: `particle_${i}`,
        position: { 
          x: rngService.random() * 100,
          y: rngService.random() * 100,
          z: rngService.random() * 100
        },
        velocity: { x: 0, y: 0, z: 0 },
        mass: 1.0 + rngService.random() * 5.0,
        charge: rngService.random() * 2 - 1
      })
    }

    const bench = new Bench({ time: 1000 })

    bench
      .add('gravitational forces', () => {
        for (let i = 0; i < particles.length; i++) {
          physicsService.calculateGravitationalForce(particles[i], particles)
        }
      })
      .add('electromagnetic forces', () => {
        for (let i = 0; i < particles.length; i++) {
          physicsService.calculateElectromagneticForce(particles[i], particles)
        }
      })
      .add('combined forces', () => {
        for (let i = 0; i < particles.length; i++) {
          const gravity = physicsService.calculateGravitationalForce(particles[i], particles)
          const electromagnetic = physicsService.calculateElectromagneticForce(particles[i], particles)
          
          // Combine forces
          const totalForce = {
            x: gravity.x + electromagnetic.x,
            y: gravity.y + electromagnetic.y,
            z: gravity.z + electromagnetic.z
          }
        }
      })

    await bench.run()
    console.table(bench.table())
  })

  test('Integration Algorithm Performance', async () => {
    const particle = {
      position: { x: 0, y: 0, z: 0 },
      velocity: { x: 1, y: 1, z: 1 },
      acceleration: { x: 0.1, y: -9.81, z: 0 },
      mass: 1.0
    }

    const bench = new Bench({ time: 1000 })

    bench
      .add('Euler integration (1000 steps)', () => {
        const p = { ...particle }
        for (let i = 0; i < 1000; i++) {
          physicsService.integrateEuler(p, 0.016)
        }
      })
      .add('Verlet integration (1000 steps)', () => {
        const p = { ...particle }
        for (let i = 0; i < 1000; i++) {
          physicsService.integrateVerlet(p, 0.016)
        }
      })
      .add('RK4 integration (1000 steps)', () => {
        const p = { ...particle }
        for (let i = 0; i < 1000; i++) {
          physicsService.integrateRK4(p, 0.016)
        }
      })

    await bench.run()
    console.table(bench.table())

    // Performance assertions for 60fps simulation
    const euler = bench.tasks.find(t => t.name === 'Euler integration (1000 steps)')
    const verlet = bench.tasks.find(t => t.name === 'Verlet integration (1000 steps)')

    // Integration should be fast enough for real-time simulation
    expect(euler?.result?.mean).toBeLessThan(10)
    expect(verlet?.result?.mean).toBeLessThan(15)
  })
})
'@

    Write-InfoLog "Generating physics performance tests"
    if (-not $DryRun) {
        Set-Content -Path $physicsPerfPath -Value $physicsPerfContent -Encoding UTF8
    }
    Write-SuccessLog "physics.perf.test.ts created successfully"

    # Update package.json with benchmark scripts
    $packageJsonPath = Join-Path $ProjectRoot "package.json"
    if (Test-Path $packageJsonPath) {
        Write-InfoLog "Adding benchmark scripts to package.json"
        
        $packageJson = Get-Content $packageJsonPath -Raw | ConvertFrom-Json
        
        if (-not $packageJson.scripts) {
            $packageJson.scripts = @{}
        }
        
        $packageJson.scripts."bench" = "vitest bench"
        $packageJson.scripts."bench:ui" = "vitest bench --ui"
        $packageJson.scripts."bench:run" = "vitest bench --run"
        $packageJson.scripts."bench:particle" = "vitest bench tests/performance/particle.perf.test.ts"
        $packageJson.scripts."bench:physics" = "vitest bench tests/performance/physics.perf.test.ts"
        
        if (-not $DryRun) {
            $packageJson | ConvertTo-Json -Depth 10 | Set-Content -Path $packageJsonPath -Encoding UTF8
        }
        Write-SuccessLog "Benchmark scripts added to package.json"
    }

    # Create benchmark configuration
    $benchConfigPath = Join-Path $ProjectRoot "vitest.bench.config.ts"
    $benchConfigContent = @'
/**
 * Vitest benchmark configuration
 * Optimized for performance testing and CI integration
 * 
 * @author Protozoa Automation Suite
 * @generated 54-SetupPerformanceBenchmarks.ps1
 */

import { defineConfig } from 'vitest/config'
import { resolve } from 'path'

export default defineConfig({
  test: {
    include: ['tests/performance/**/*.perf.test.ts'],
    benchmark: {
      include: ['tests/performance/**/*.perf.test.ts'],
      exclude: ['tests/**/*.test.ts'],
      outputFile: './benchmark-results.json'
    },
    reporters: ['verbose', 'json'],
    outputFile: {
      json: './test-results.json'
    }
  },
  resolve: {
    alias: {
      '@': resolve(__dirname, './src')
    }
  },
  define: {
    'process.env.NODE_ENV': '"test"'
  }
})
'@

    Write-InfoLog "Creating benchmark configuration"
    if (-not $DryRun) {
        Set-Content -Path $benchConfigPath -Value $benchConfigContent -Encoding UTF8
    }
    Write-SuccessLog "vitest.bench.config.ts created successfully"

    # Create CI benchmark workflow
    $githubWorkflowsPath = Join-Path $ProjectRoot ".github/workflows"
    if (-not (Test-Path $githubWorkflowsPath)) {
        if (-not $DryRun) {
            New-Item -ItemType Directory -Path $githubWorkflowsPath -Force | Out-Null
        }
    }

    $benchWorkflowPath = Join-Path $githubWorkflowsPath "benchmarks.yml"
    $benchWorkflowContent = @'
name: Performance Benchmarks

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]
  schedule:
    - cron: '0 2 * * 1' # Run weekly on Monday at 2 AM

jobs:
  benchmark:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
        cache: 'npm'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Run benchmarks
      run: npm run bench:run
    
    - name: Upload benchmark results
      uses: actions/upload-artifact@v3
      with:
        name: benchmark-results
        path: benchmark-results.json
        
    - name: Performance regression check
      run: |
        if [ -f "benchmark-results.json" ]; then
          echo "Checking for performance regressions..."
          node -e "
            const results = require('./benchmark-results.json');
            const failures = results.filter(r => r.error || r.duration > r.expected);
            if (failures.length > 0) {
              console.error('Performance regression detected:', failures);
              process.exit(1);
            }
            console.log('All benchmarks passed performance targets');
          "
        fi
'@

    Write-InfoLog "Creating GitHub Actions benchmark workflow"
    if (-not $DryRun) {
        Set-Content -Path $benchWorkflowPath -Value $benchWorkflowContent -Encoding UTF8
    }

    Write-SuccessLog "Performance benchmarks setup completed successfully"
    Write-InfoLog "Generated: particle.perf.test.ts, physics.perf.test.ts, vitest.bench.config.ts"
    Write-InfoLog "Added: benchmark scripts, GitHub Actions workflow"
    Write-InfoLog "Performance testing infrastructure ready for continuous monitoring"
    
    exit 0

} catch {
    Write-ErrorLog "Setup Performance Benchmarks failed: $($_.Exception.Message)"
    exit 1
} 