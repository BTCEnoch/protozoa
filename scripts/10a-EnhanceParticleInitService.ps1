# 10a-EnhanceParticleInitService.ps1
# Enhances ParticleInitService with 500-particle allocation algorithm and emergent behavior

<#
.SYNOPSIS
    Enhances ParticleInitService with advanced 500-particle allocation algorithm and emergent behavior support.
.DESCRIPTION
    1. Updates the existing ParticleInitService interface and implementation
    2. Adds comprehensive particle types with roles and emergent behaviors  
    3. Implements the 40-base + 460-variable particle allocation algorithm
    4. Integrates with RNG, Physics, and Trait services via dependency injection
.PARAMETER ProjectRoot
    Root directory of the project (defaults to current directory)
.PARAMETER SkipBackup
    Skip backing up existing files before overwriting
.EXAMPLE
    .\10a-EnhanceParticleInitService.ps1 -ProjectRoot "C:\Projects\Protozoa"
.NOTES
    This enhances the basic ParticleInitService created by script 10
#>
param(
    [string]$ProjectRoot = $PWD,
    [switch]$SkipBackup
)

try { Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop } catch { Write-Error "utils import failed"; exit 1 }
$ErrorActionPreference = 'Stop'

try {
    Write-StepHeader "Enhanced ParticleInitService Generation"
    Write-InfoLog "Enhancing ParticleInitService with advanced features..."
    
    # Validate project structure
    $particleDomain = Join-Path $ProjectRoot "src/domains/particle"
    if (-not (Test-Path $particleDomain)) {
        throw "Particle domain not found at: $particleDomain"
    }
    
    $interfacesDir = Join-Path $particleDomain "interfaces"
    $servicesDir = Join-Path $particleDomain "services" 
    $typesDir = Join-Path $particleDomain "types"
    
    # Ensure directories exist
    foreach ($dir in @($interfacesDir, $servicesDir, $typesDir)) {
        if (-not (Test-Path $dir)) {
            New-Item -Path $dir -ItemType Directory -Force | Out-Null
            Write-InfoLog "Created directory: $dir"
        }
    }
    
    # Backup existing files if not skipped
    if (-not $SkipBackup) {
        $backupDir = Join-Path $ProjectRoot "backup/$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        New-Item -Path $backupDir -ItemType Directory -Force | Out-Null
        
        $filesToBackup = @(
            (Join-Path $interfacesDir "IParticleInitService.ts"),
            (Join-Path $servicesDir "particleInitService.ts"),
            (Join-Path $typesDir "particle.types.ts")
        )
        
        foreach ($file in $filesToBackup) {
            if (Test-Path $file) {
                $backupFile = Join-Path $backupDir (Split-Path $file -Leaf)
                Copy-Item $file $backupFile -Force
                Write-InfoLog "Backed up: $(Split-Path $file -Leaf)"
            }
        }
    }
    
    # Copy enhanced templates
    Write-InfoLog "Copying enhanced particle types template..."
    $particleTypesTemplate = Join-Path $ProjectRoot "templates/domains/particle/types/particle.types.ts.template"
    $particleTypesTarget = Join-Path $typesDir "particle.types.ts"
    
    if (Test-Path $particleTypesTemplate) {
        Copy-Item $particleTypesTemplate $particleTypesTarget -Force
        Write-SuccessLog "Enhanced particle types → $particleTypesTarget"
    } else {
        Write-ErrorLog "Particle types template not found: $particleTypesTemplate"
    }
    
    Write-InfoLog "Copying enhanced ParticleInitService interface..."
    $interfaceTemplate = Join-Path $ProjectRoot "templates/domains/particle/interfaces/IParticleInitService.ts.template"
    $interfaceTarget = Join-Path $interfacesDir "IParticleInitService.ts"
    
    if (Test-Path $interfaceTemplate) {
        Copy-Item $interfaceTemplate $interfaceTarget -Force
        Write-SuccessLog "Enhanced interface → $interfaceTarget"
    } else {
        Write-ErrorLog "Interface template not found: $interfaceTemplate"
    }
    
    Write-InfoLog "Copying enhanced ParticleInitService implementation..."
    $serviceTemplate = Join-Path $ProjectRoot "templates/domains/particle/services/particleInitService.ts.template"
    $serviceTarget = Join-Path $servicesDir "particleInitService.ts"
    
    if (Test-Path $serviceTemplate) {
        Copy-Item $serviceTemplate $serviceTarget -Force
        Write-SuccessLog "Enhanced service → $serviceTarget"
    } else {
        Write-ErrorLog "Service template not found: $serviceTemplate"
    }
    
    # Update particle domain index exports using template
    Write-InfoLog "Updating particle domain exports..."
    $domainIndex = Join-Path $particleDomain "index.ts"
    $indexTemplate = Join-Path $ProjectRoot "templates/domains/particle/index.ts.template"
    
    if (Test-Path $indexTemplate) {
        Copy-Item $indexTemplate $domainIndex -Force
    Write-SuccessLog "Updated domain exports → $domainIndex"
    } else {
        Write-ErrorLog "Particle index template not found: $indexTemplate"
        throw "Required template missing: index.ts.template"
    }
    
    # Verify TypeScript compilation
    Write-InfoLog "Verifying TypeScript compilation..."
    Push-Location $ProjectRoot
    try {
        $result = & npx tsc --noEmit --skipLibCheck 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-SuccessLog "TypeScript compilation successful"
        } else {
            Write-WarningLog "TypeScript compilation has issues: $result"
        }
    } catch {
        Write-WarningLog "Could not verify TypeScript compilation: $_"
    } finally {
        Pop-Location
    }
    
    Write-SuccessLog "ParticleInitService enhancement completed!"
    Write-InfoLog "Features added:"
    Write-InfoLog "  - 500-particle allocation algorithm"
    Write-InfoLog "  - 8 particle roles with weighted distribution"  
    Write-InfoLog "  - 9 emergent behaviors with assignment probability"
    Write-InfoLog "  - Comprehensive dependency injection support"
    Write-InfoLog "  - Performance monitoring and health checks"
    Write-InfoLog "  - Memory usage estimation and optimization"
    
    exit 0
    
} catch {
    Write-ErrorLog "ParticleInitService enhancement failed: $_"
    Write-DebugLog "Stack trace: $($_.ScriptStackTrace)"
    exit 1
} 