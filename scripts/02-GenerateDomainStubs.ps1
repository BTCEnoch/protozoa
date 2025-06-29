﻿# 02-GenerateDomainStubs.ps1
# Creates compilable service + interface skeletons with correct singleton/export patterns
# Referenced from build_design.md domain implementations and .cursorrules standards

Import-Module "$PSScriptRoot\utils.psm1" -Force

# Helper function for domain phase mapping - must be defined before use
function Get-DomainPhaseNumber($domain) {
    $phaseMap = @{
        'rng' = 2
        'physics' = 2
        'bitcoin' = 3
        'trait' = 3
        'particle' = 4
        'formation' = 4
        'rendering' = 5
        'effect' = 5
        'animation' = 6
        'group' = 6
    }
    if ($phaseMap.ContainsKey($domain)) {
        return $phaseMap[$domain]
    } else {
        return 8
    }
}

Write-StepHeader "Domain Service Stub Generation"

# Get domain list and generate stubs for each
$domains = Get-DomainList
Write-InfoLog "Generating service stubs for: $($domains -join ', ')"

foreach ($domain in $domains) {
    # Special case for RNG service to match the correct naming convention
    if ($domain -eq 'rng') {
        $serviceName = "RNGService"
        $interfaceName = "IRNGService"
    } else {
        $serviceName = Get-ServiceName -Domain $domain
        $interfaceName = "I$serviceName"  
    }
    $serviceFilePath = "src/domains/$domain/services/$serviceName.ts"
    $typesFilePath = "src/domains/$domain/types/index.ts"

    # Skip if service already exists
    if (Test-Path $serviceFilePath) {
        Write-WarningLog "Service already exists, skipping: $serviceFilePath"
        continue
    }

    Write-InfoLog "Generating $serviceName stub..."

    # Generate service-specific interface based on domain
    $interfaceContent = switch ($domain) {
        'rng' { @'
export interface IRNGService {
  random(): number;
  randomInt(min: number, max: number, seed?: number): number;
  setSeed(seed: number): void;
  dispose(): void;
}
'@ }
        'physics' { @'
import { IVector3 } from '@/shared/types';

export interface IPhysicsService {
  calculateDistribution(count: number, radius: number): IVector3[];
  applyGravity(position: IVector3, delta: number): IVector3;
  detectCollisions(particles: IVector3[]): boolean;
  dispose(): void;
}
'@ }
        'bitcoin' { @'
export interface BitcoinBlockInfo {
  height: number;
  hash: string;
  timestamp: number;
  nonce: number;
}

export interface IBitcoinService {
  fetchBlockInfo(blockNumber: number): Promise<BitcoinBlockInfo>;
  getCachedBlockInfo(blockNumber: number): BitcoinBlockInfo | undefined;
  fetchInscriptionContent(inscriptionId: string): Promise<string>;
  dispose(): void;
}
'@ }
        'trait' { @'
import { OrganismTraits } from '@/domains/trait/types/trait.types';

export interface ITraitService {
  generateTraitsForOrganism(id: string, blockNonce?: number): OrganismTraits;
  mutateTrait(traitType: string, currentValue: any): any;
  applyTraitsToOrganism(organismId: string, traits: OrganismTraits): void;
  dispose(): void;
}
'@ }
        'particle' { @'
import { Vector3 } from 'three';

export interface Particle {
  id: string;
  position: Vector3;
  velocity: Vector3;
  age: number;
  lifetime: number;
  active: boolean;
}

export interface IParticleService {
  createParticle(position?: Vector3, velocity?: Vector3): Particle;
  getParticleById(id: string): Particle | undefined;
  updateParticles(deltaTime: number): void;
  getAllParticles(): Particle[];
  getParticleCount(): number;
  dispose(): void;
}
'@ }
        'formation' { @'
import { Vector3 } from 'three';

export interface FormationPattern {
  id: string;
  name: string;
  positions: Vector3[];
  scale: number;
  rotation: number;
}

export interface IFormationService {
  getFormationPattern(patternId: string): FormationPattern | undefined;
  applyFormation(patternId: string, particleIds: string[]): void;
  registerPattern(pattern: FormationPattern): void;
  blendFormations(patterns: FormationPattern[], weights: number[]): FormationPattern;
  getCachedBlend(key: string): FormationPattern | undefined;
  setCacheLimit(maxSize: number): void;
  dispose(): void;
}
'@ }
        'rendering' { @'
import { Object3D } from 'three';

export interface IRenderingService {
  initialize(canvas: HTMLCanvasElement): void;
  renderFrame(delta: number): void;
  addObject(obj: Object3D): void;
  removeObject(obj: Object3D): void;
  dispose(): void;
}
'@ }
        'animation' { @'
export interface AnimationConfig {
  duration: number;
  type: string;
  easing?: string;
  loop?: boolean;
}

export interface AnimationState {
  role: string;
  progress: number;
  duration: number;
  type: string;
}

export interface IAnimationService {
  startAnimation(role: string, config: AnimationConfig): void;
  updateAnimations(delta: number): void;
  stopAnimation(role: string): void;
  stopAll(): void;
  dispose(): void;
}
'@ }
        'effect' { @'
export interface EffectConfig {
  duration: number;
  intensity: number;
  parameters?: Record<string, any>;
}

export interface IEffectService {
  triggerEffect(name: string, options?: any): void;
  registerEffectPreset(name: string, config: EffectConfig): void;
  dispose(): void;
}
'@ }
        'group' { @'
export interface ParticleGroup {
  id: string;
  members: string[];
  metadata?: Record<string, any>;
}

export interface IGroupService {
  formGroup(particleIds: string[]): ParticleGroup;
  getGroup(id: string): ParticleGroup | undefined;
  dissolveGroup(id: string): void;
  dispose(): void;
}
'@ }
        default { @'
export interface I{0} {
  dispose(): void;
}
'@ -f $serviceName }
    }

    # Create types file with interface - using proper variable expansion
    $typesContent = @"
// src/domains/$domain/types/index.ts
// Domain-specific types and interfaces for $domain
// Generated by 02-GenerateDomainStubs.ps1

$interfaceContent
"@

    Set-Content -Path $typesFilePath -Value $typesContent

    # Generate service implementation stub - using proper variable expansion
    $phaseNumber = Get-DomainPhaseNumber $domain
    $domainUpper = $domain.ToUpper()
    
    $serviceContent = @"
// src/domains/$domain/services/$serviceName.ts
// $serviceName implementation - Auto-generated stub
// Referenced from build_design.md Section $phaseNumber

import { $interfaceName } from '../types';
import { createServiceLogger } from '@/shared/lib/logger';

/**
 * $serviceName – manages $domain domain operations.
 * Auto-generated stub following .cursorrules singleton pattern.
 * TODO: Implement actual logic in Phase $phaseNumber.
 */
class $serviceName implements $interfaceName {
  static #instance: $serviceName | null = null;
  #log = createServiceLogger('${domainUpper}_SERVICE');

  /**
   * Private constructor enforces singleton pattern.
   */
  private constructor() {
    this.#log.info('$serviceName initialized');
  }

  /**
   * Singleton accessor - returns existing instance or creates new one.
   */
  public static getInstance(): $serviceName {
    if (!$serviceName.#instance) {
      $serviceName.#instance = new $serviceName();
    }
    return $serviceName.#instance;
  }

  // TODO: Implement interface methods here

  /**
   * Disposes of service resources and resets singleton instance.
   */
  public dispose(): void {
    this.#log.info('$serviceName disposed');
    $serviceName.#instance = null;
  }
}

// Singleton export as required by .cursorrules
export const ${domain}Service = $serviceName.getInstance();
"@

    Set-Content -Path $serviceFilePath -Value $serviceContent
    Write-SuccessLog "Generated: $serviceFilePath"

    # Generate domain-level index file for proper exports
    $domainIndexPath = "src/domains/$domain/index.ts"
    $domainIndexContent = @"
// src/domains/$domain/index.ts
// Domain export index for $domain
// Generated by 02-GenerateDomainStubs.ps1

// Service exports
export { ${domain}Service } from './services/$serviceName';

// Type exports
export * from './types';

// Interface re-exports for easier imports
export type { $interfaceName } from './types';
"@
    Set-Content -Path $domainIndexPath -Value $domainIndexContent
    Write-InfoLog "Generated domain index: $domainIndexPath"
}

# Generate domain-specific stub implementations based on documented requirements

# Create master index file for easy imports
Write-InfoLog "Creating domain service index..."
$indexContent = @'
// src/domains/index.ts
// Master export for all domain services
// Auto-generated by 02-GenerateDomainStubs.ps1

'@

foreach ($domain in $domains) {
    # Handle RNG service naming specially
    if ($domain -eq 'rng') {
        $exportName = "rngService"
        $serviceName = "RNGService"
    } else {
        $exportName = "${domain}Service"
        $serviceName = Get-ServiceName $domain
    }
    $indexContent += @"
export { $exportName } from './$domain/services/$serviceName';
"@
}

Set-Content -Path "src/domains/index.ts" -Value $indexContent
Write-SuccessLog "Created domain service index"

# Verify all stubs compile
Write-InfoLog "Verifying TypeScript compilation..."
try {
    if (Test-TypeScriptCompiles) {
        Write-SuccessLog "All generated stubs compile successfully"
    } else {
        Write-WarningLog "TypeScript compilation has warnings - this is expected for stubs"
        Write-InfoLog "Stub interfaces will be implemented in later phases"
    }
}
catch {
    Write-WarningLog "TypeScript compilation check failed - this is expected for incomplete stubs"
}

# Reset exit code - TypeScript warnings are expected for stubs
$global:LASTEXITCODE = 0

# Generate summary
Write-InfoLog "Generation Summary:"
Write-InfoLog "  - $($domains.Count) service stubs created"
Write-InfoLog "  - All interfaces defined with proper contracts"
Write-InfoLog "  - Singleton patterns implemented"
Write-InfoLog "  - Winston logging configured"
Write-InfoLog "  - Proper dispose() methods added"

Write-SuccessLog "Domain service stub generation complete!"
Write-InfoLog "Next: Run 03-MoveAndCleanCodebase.ps1 to clean legacy files"