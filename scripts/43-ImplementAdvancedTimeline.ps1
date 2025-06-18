# 43-ImplementAdvancedTimeline.ps1 - Phase 6 Enhancement
# Creates TimelineService for complex animation sequencing
# Reference: script_checklist.md lines 2150-2200
#Requires -Version 5.1

[CmdletBinding()]
param([string]$ProjectRoot=(Split-Path $PSScriptRoot -Parent))

try{Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop}catch{Write-Error $_;exit 1}
$ErrorActionPreference="Stop"

try{
 Write-StepHeader "Advanced Timeline Service Generation"
 $animPath=Join-Path $ProjectRoot 'src/domains/animation'
 $services=Join-Path $animPath 'services'
 $interfaces=Join-Path $animPath 'interfaces'
 New-Item -Path $services -ItemType Directory -Force | Out-Null
 New-Item -Path $interfaces -ItemType Directory -Force | Out-Null

 # Generate templates
 Write-TemplateFile -TemplateRelPath 'domains/animation/interfaces/ITimelineService.ts.template' `
                   -DestinationPath (Join-Path $interfaces 'ITimelineService.ts')

 Write-TemplateFile -TemplateRelPath 'domains/animation/services/timelineService.ts.template' `
                   -DestinationPath (Join-Path $services 'timelineService.ts')

 Write-SuccessLog "TimelineService generated"
 exit 0
}catch{Write-ErrorLog "Timeline generation failed: $($_.Exception.Message)";exit 1}
