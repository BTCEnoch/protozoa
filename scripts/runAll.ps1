# runAll.ps1 – master automation runner (re-generated)
# Provides phase-based execution with progress bars and transcript logging

[CmdletBinding()]
param(
  [string]$ProjectRoot = $PSScriptRoot,
  [switch]$ContinueOnError
)

Import-Module "$PSScriptRoot\utils.psm1" -Force
$ErrorActionPreference = "Stop"

# -----------------------------------------------------------------------------
#  Script list – maintain order by phase then step                                         
# -----------------------------------------------------------------------------
$ScriptSequence = @(
  # Phase 0 – Foundation
  @{ Phase = 0; File = '00-InitEnvironment.ps1';              Desc = 'Init environment' },
  @{ Phase = 0; File = '01-ScaffoldProjectStructure.ps1';      Desc = 'Scaffold structure' },
  @{ Phase = 0; File = '02-GenerateDomainStubs.ps1';           Desc = 'Domain stubs' },
  @{ Phase = 0; File = '20-SetupPreCommitValidation.ps1';      Desc = 'Pre-commit hooks' },

  # Phase 1 – Shared infra
  @{ Phase = 1; File = '16-GenerateSharedTypesService.ps1';    Desc = 'Shared types' },
  @{ Phase = 1; File = '17-GenerateEnvironmentConfig.ps1';     Desc = 'Env config' },

  # Phase 2 – Dev tooling
  @{ Phase = 2; File = '21-ConfigureDevEnvironment.ps1';       Desc = 'Dev environment' },

  # Phase 3 – Core services
  @{ Phase = 3; File = '22-SetupBitcoinProtocol.ps1';          Desc = 'Bitcoin protocol' },
  @{ Phase = 3; File = '23-GenerateRNGService.ps1';            Desc = 'RNG service' },
  @{ Phase = 3; File = '24-GeneratePhysicsService.ps1';        Desc = 'Physics service' },
  @{ Phase = 3; File = '25-SetupPhysicsWebWorkers.ps1';        Desc = 'Physics worker' },

  # Phase 4 – Additional domain services
  @{ Phase = 4; File = '41-GenerateGroupService.ps1';          Desc = 'Group service' },
  @{ Phase = 4; File = '11-GenerateFormationBlendingService.ps1'; Desc = 'Formation blending' },
  @{ Phase = 4; File = '10-GenerateParticleInitService.ps1';   Desc = 'Particle init' },

  # Phase 5 – Utilities
  @{ Phase = 5; File = '14-FixUtilityFunctions.ps1';           Desc = 'Utility helpers' },
  @{ Phase = 5; File = '29-SetupDataValidationLayer.ps1';      Desc = 'Validation utils' },
  @{ Phase = 5; File = '34-EnhanceFormationSystem.ps1';        Desc = 'Formation enhancer' },

  # Phase 9 – Validation
  @{ Phase = 9; File = '99-ValidateTemplates.ps1';             Desc = 'Template validation' }
)

# -----------------------------------------------------------------------------
#  Logging setup
# -----------------------------------------------------------------------------
$LogPath = Join-Path $PSScriptRoot 'automation.log'
Remove-Item $LogPath -ErrorAction SilentlyContinue
Start-Transcript -Path $LogPath | Out-Null

Write-StepHeader "PROTOZOA AUTOMATION PIPELINE"

$total = $ScriptSequence.Count
$stepIndex = 0
$phaseGroups = $ScriptSequence | Group-Object Phase | Sort-Object Name

foreach ($phase in $phaseGroups) {
  Write-Host "`n=== Phase $($phase.Name) ===" -ForegroundColor Cyan
  foreach ($item in $phase.Group) {
    $stepIndex++
    $pct = [int](($stepIndex / $total) * 100)

    $title   = "[$stepIndex/$total] $($item.File)"
    $status  = "Running: $($item.Desc)"
    Write-Progress -Activity $title -Status $status -PercentComplete $pct

    $scriptFile = Join-Path $PSScriptRoot $item.File
    if (-not (Test-Path $scriptFile)) {
      Write-ErrorLog "Missing script: $($item.File)"; if (-not $ContinueOnError) { break }
      continue
    }

    try {
      & $scriptFile
      if ($LASTEXITCODE -ne 0) { throw "Exit code $LASTEXITCODE" }
      Write-SuccessLog "✔ $($item.Desc) completed"
    } catch {
      Write-ErrorLog "✖ $($item.Desc) failed: $($_.Exception.Message)"
      if (-not $ContinueOnError) { Stop-Transcript; exit 1 }
    }
  }
}

Stop-Transcript | Out-Null
Write-Host "`nPipeline finished. Detailed log: $LogPath" -ForegroundColor Green
