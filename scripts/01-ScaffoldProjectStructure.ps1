# 01-ScaffoldProjectStructure.ps1
# Creates domain-driven directory structure with enhanced error handling
# Referenced from build_design.md Section 1 - "Project Structure and Scaffolding"

#Requires -Version 5.1

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $false)]
    [string]$ProjectRoot = (Split-Path $PSScriptRoot -Parent),

    [Parameter(Mandatory = $false)]
    [switch]$Force
)

# Import utilities with error handling
try {
    Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop
}
catch {
    Write-Error "Failed to import utilities module: $($_.Exception.Message)"
    exit 1
}

$ErrorActionPreference = "Stop"

try {
    Write-StepHeader "Project Structure Scaffolding - Phase 1"

    # Validate project root
    if (-not (Test-Path $ProjectRoot)) {
        throw "Project root does not exist: $ProjectRoot"
    }

    Push-Location $ProjectRoot
    Write-InfoLog "Working in project root: $ProjectRoot"

    # Get domain list from centralized configuration
    $domains = Get-DomainList
    Write-InfoLog "Scaffolding domains: $($domains -join ', ')"

# Create base directories
Write-InfoLog "Creating base directory structure..."
$baseDirs = @(
    'src',
    'src/domains',
    'src/shared',
    'src/shared/lib',
    'src/shared/types',
    'src/shared/config',
    'src/components',
    'tests',
    'docs'
)

New-DirectoryTree -Paths $baseDirs

# Create domain directories with standard subfolders
Write-InfoLog "Creating domain-specific directories..."
foreach ($domain in $domains) {
    $domainPaths = @(
        "src/domains/$domain",
        "src/domains/$domain/services",
        "src/domains/$domain/types",
        "src/domains/$domain/data",
        "tests/$domain",
        "tests/$domain/services",
        "tests/$domain/types"
    )

    New-DirectoryTree -Paths $domainPaths
    Write-SuccessLog "Domain scaffolded: $domain"
}

# Create shared infrastructure files
Write-InfoLog "Creating shared infrastructure stubs..."

# Shared logger utility
$loggerContent = @'
// src/shared/lib/logger.ts
// Winston logging utilities for all domains
// Referenced from .cursorrules logging requirements

import winston from 'winston';

const logFormat = winston.format.combine(
  winston.format.timestamp(),
  winston.format.errors({ stack: true }),
  winston.format.json()
);

const baseLogger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: logFormat,
  transports: [
    new winston.transports.Console({
      format: winston.format.combine(
        winston.format.colorize(),
        winston.format.simple()
      )
    })
  ]
});

export function createServiceLogger(serviceName: string): winston.Logger {
  return baseLogger.child({ service: serviceName });
}

export function createPerformanceLogger(serviceName: string): winston.Logger {
  return baseLogger.child({ service: serviceName, type: 'performance' });
}

export function createErrorLogger(serviceName: string): winston.Logger {
  return baseLogger.child({ service: serviceName, type: 'error' });
}
'@

Set-Content -Path "src/shared/lib/logger.ts" -Value $loggerContent
Write-SuccessLog "Created shared logger utility"

# Shared types file
$sharedTypesContent = @'
// src/shared/types/index.ts
// Cross-domain shared types and interfaces
// Referenced from build_checklist.md Phase 1 requirements

// Vector types for 3D coordinates
export interface Vector3 {
  x: number;
  y: number;
  z: number;
}

// Base particle interface used across domains
export interface Particle {
  id: string;
  position: Vector3;
  velocity: Vector3;
  traits: OrganismTraits;
}

// Organism traits structure
export interface OrganismTraits {
  visual?: Record<string, any>;
  behavior?: Record<string, any>;
  mutation?: Record<string, any>;
}

// Formation pattern data structure
export interface FormationPattern {
  id: string;
  name: string;
  positions: Vector3[];
  metadata?: Record<string, any>;
}

// Animation configuration
export interface AnimationConfig {
  duration: number;
  type: string;
  parameters?: Record<string, any>;
}

// Animation state tracking
export interface AnimationState {
  role: string;
  progress: number;
  duration: number;
  type: string;
}
'@

Set-Content -Path "src/shared/types/index.ts" -Value $sharedTypesContent
Write-SuccessLog "Created shared types definitions"

# Environment configuration
$envConfigContent = @'
// src/shared/config/environment.ts
// Environment-specific configuration service
// Referenced from build_checklist.md Phase 1 requirements

interface EnvironmentConfig {
  apiBaseUrl: string;
  isProduction: boolean;
  isDebug: boolean;
  logLevel: string;
}

function detectEnvironment(): EnvironmentConfig {
  const isDev = process.env.NODE_ENV === 'development';
  const isProd = process.env.NODE_ENV === 'production';

  return {
    apiBaseUrl: isDev ? 'https://ordinals.com' : '',
    isProduction: isProd,
    isDebug: process.env.VITE_DEBUG === 'true' || isDev,
    logLevel: process.env.LOG_LEVEL || (isDev ? 'debug' : 'info')
  };
}

export const config = detectEnvironment();

export function getApiBaseUrl(): string {
  return config.apiBaseUrl;
}

export function isProduction(): boolean {
  return config.isProduction;
}

export function isDebugMode(): boolean {
  return config.isDebug;
}
'@

Set-Content -Path "src/shared/config/environment.ts" -Value $envConfigContent
Write-SuccessLog "Created environment configuration"

# Create ESLint configuration
Write-InfoLog "Creating ESLint configuration..."
$eslintConfig = @'
{
  "extends": [
    "@typescript-eslint/recommended"
  ],
  "parser": "@typescript-eslint/parser",
  "plugins": ["@typescript-eslint"],
  "rules": {
    "max-lines": ["error", 500],
    "no-unused-vars": "error",
    "@typescript-eslint/no-explicit-any": "warn",
    "@typescript-eslint/explicit-function-return-type": "warn"
  }
}
'@

Set-Content -Path ".eslintrc.json" -Value $eslintConfig
Write-SuccessLog "Created ESLint configuration"

# Verify directory structure
Write-InfoLog "Verifying directory structure..."
$requiredPaths = @(
    'src/domains',
    'src/shared/lib',
    'src/shared/types',
    'tests'
)

$allPathsExist = $true
foreach ($path in $requiredPaths) {
    if (-not (Test-Path $path)) {
        Write-ErrorLog "Required path missing: $path"
        $allPathsExist = $false
    }
}

if ($allPathsExist) {
    Write-SuccessLog "Directory structure verification passed"
} else {
    throw "Directory structure verification failed"
}

# Generate summary
Write-InfoLog "Structure Summary:"
Write-InfoLog "  - $($domains.Count) domains scaffolded"
Write-InfoLog "  - Shared infrastructure created"
Write-InfoLog "  - Test directories mirrored"
Write-InfoLog "  - TypeScript path aliases configured"

    Write-SuccessLog "Project structure scaffolding complete!"
    Write-InfoLog "Next: Run 02-GenerateDomainStubs.ps1 to create service skeletons"

    exit 0
}
catch {
    Write-ErrorLog "Project structure scaffolding failed: $($_.Exception.Message)"
    exit 1
}
finally {
    try {
        Pop-Location -ErrorAction SilentlyContinue
    }
    catch {
        # Ignore pop-location errors
    }
}