# 01-ScaffoldProjectStructure.ps1
# Creates domain-driven directory structure with enhanced error handling
# Referenced from build_design.md Section 1 - "Project Structure and Scaffolding"

#Requires -Version 5.1

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $false)]
    [string]$ProjectRoot = $PWD,

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
/**
 * Shared Types Index
 * Central export point for all shared types and interfaces
 */

// Export THREE.js Vector3 as the standard vector type
export { Vector3 } from "three";

// Core entity types
export * from "./entityTypes";

// Service configuration types  
export * from "./configTypes";

// Event types for domain communication
export * from "./eventTypes";

// Logging types
export * from "./loggingTypes";

// Organism traits structure
export interface OrganismTraits {
  visual: {
    color: { r: number; g: number; b: number };
    size: number;
    opacity: number;
  };
  behavioral: {
    speed: number;
    aggressiveness: number;
    socialness: number;
  };
  evolutionary: {
    mutationRate: number;
    adaptability: number;
    survivability: number;
  };
}

// Trait component interfaces
export interface VisualTraits {
  color: { r: number; g: number; b: number };
  size: number;
  opacity: number;
}

export interface BehavioralTraits {
  speed: number;
  aggressiveness: number;
  socialness: number;
}

export interface EvolutionaryTraits {
  mutationRate: number;
  adaptability: number;
  survivability: number;
}

export interface MutationTraits {
  rate: number;
  intensity: number;
  stability: number;
}

// Common trait value type
export type TraitValue = string | number | boolean;

// Particle type definitions
export type ParticleType = "core" | "membrane" | "nucleus" | "cytoplasm" | "organelle" | "effect";

// Particle creation data
export interface ParticleCreationData {
  id: string;
  position: Vector3;
  traits: OrganismTraits;
  type: ParticleType;
}

// Particle performance metrics
export interface ParticleMetrics {
  count: number;
  activeCount: number;
  memoryUsage: number;
  creationRate: number;
  removalRate: number;
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

# Create individual type files
Write-InfoLog "Creating individual type definition files..."

# Entity types
$entityTypesContent = @'
/**
 * Core entity type definitions
 */

import { Vector3 } from "three";

// Base entity interface
export interface BaseEntity {
  id: string;
  position: Vector3;
  createdAt: number;
  updatedAt: number;
}

// Particle entity
export interface ParticleEntity extends BaseEntity {
  velocity: Vector3;
  scale: Vector3;
  rotation: number;
  age: number;
  lifetime: number;
  active: boolean;
}

// Group entity
export interface GroupEntity extends BaseEntity {
  memberIds: string[];
  bounds: Vector3;
  centerOfMass: Vector3;
}
'@

Set-Content -Path "src/shared/types/entityTypes.ts" -Value $entityTypesContent

# Config types
$configTypesContent = @'
/**
 * Configuration type definitions
 */

// Service configuration base
export interface ServiceConfig {
  enabled: boolean;
  logLevel: string;
  maxRetries: number;
}

// Rendering configuration
export interface RenderingConfig extends ServiceConfig {
  antialias: boolean;
  shadows: boolean;
  maxFPS: number;
}

// Physics configuration
export interface PhysicsConfig extends ServiceConfig {
  gravity: number;
  timeStep: number;
  iterations: number;
}

// Bitcoin API configuration
export interface BitcoinConfig extends ServiceConfig {
  apiUrl: string;
  cacheTimeout: number;
  rateLimit: number;
}
'@

Set-Content -Path "src/shared/types/configTypes.ts" -Value $configTypesContent

# Event types
$eventTypesContent = @'
/**
 * Event type definitions for inter-domain communication
 */

// Base event interface
export interface BaseEvent {
  type: string;
  timestamp: number;
  source: string;
  data: Record<string, any>;
}

// Particle events
export interface ParticleEvent extends BaseEvent {
  particleId: string;
}

export interface ParticleBirthEvent extends ParticleEvent {
  type: "particle:birth";
  data: {
    position: { x: number; y: number; z: number };
    traits: Record<string, any>;
  };
}

export interface ParticleDeathEvent extends ParticleEvent {
  type: "particle:death";
  data: {
    age: number;
    cause: string;
  };
}

// Group events
export interface GroupEvent extends BaseEvent {
  groupId: string;
}

export interface GroupFormationEvent extends GroupEvent {
  type: "group:formation";
  data: {
    memberIds: string[];
    pattern: string;
  };
}

// Animation events
export interface AnimationEvent extends BaseEvent {
  animationId: string;
}

export interface AnimationCompleteEvent extends AnimationEvent {
  type: "animation:complete";
  data: {
    duration: number;
    success: boolean;
  };
}
'@

Set-Content -Path "src/shared/types/eventTypes.ts" -Value $eventTypesContent

# Logging types
$loggingTypesContent = @'
/**
 * Logging type definitions
 */

// Log levels
export type LogLevel = "error" | "warn" | "info" | "debug" | "trace";

// Log entry interface
export interface LogEntry {
  level: LogLevel;
  message: string;
  timestamp: number;
  service: string;
  data?: Record<string, any>;
  error?: Error;
}

// Performance log entry
export interface PerformanceLogEntry extends LogEntry {
  operation: string;
  duration: number;
  memoryUsage?: number;
}

// Error log entry
export interface ErrorLogEntry extends LogEntry {
  level: "error";
  error: Error;
  stackTrace?: string;
}
'@

Set-Content -Path "src/shared/types/loggingTypes.ts" -Value $loggingTypesContent

Write-SuccessLog "Created individual type definition files"

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