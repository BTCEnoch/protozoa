# 41-GenerateGroupService.ps1 - Phase 6 Core Domain Implementation
# Generates GroupService and interface for managing particle groups
# Reference: script_checklist.md | build_design.md lines 1100-1250 (Group domain)
#Requires -Version 5.1

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $false)]
    [string]$ProjectRoot = (Split-Path $PSScriptRoot -Parent)
)

try {
    Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop
}
catch {
    Write-Error "Failed to import utilities module: $($_.Exception.Message)"
    exit 1
}

$ErrorActionPreference = "Stop"

try {
    Write-StepHeader "Group Service Generation - Phase 6 Core Domain Implementation"
    Write-InfoLog "Generating GroupService and interfaces"

    # Paths
    $groupDomainPath = Join-Path $ProjectRoot "src/domains/group"
    $servicesPath    = Join-Path $groupDomainPath "services"
    $interfacesPath  = Join-Path $groupDomainPath "interfaces"

    New-Item -Path $servicesPath   -ItemType Directory -Force | Out-Null
    New-Item -Path $interfacesPath -ItemType Directory -Force | Out-Null

    Write-SuccessLog "Group domain directories ensured"

    # Generate templates
    Write-TemplateFile -TemplateRelPath 'domains/group/interfaces/IGroupService.ts.template' `
                      -DestinationPath (Join-Path $interfacesPath 'IGroupService.ts')

    Write-TemplateFile -TemplateRelPath 'domains/group/services/groupService.ts.template' `
                      -DestinationPath (Join-Path $servicesPath 'GroupService.ts')

    # compatibility wrapper
    $wrapperContent = "export * from './GroupService'"
    Set-Content -Path (Join-Path $servicesPath 'groupService.ts') -Value $wrapperContent -Encoding UTF8
    Write-InfoLog "Added wrapper groupService.ts for casing compatibility"

    Write-SuccessLog "41-GenerateGroupService.ps1 completed successfully"
    exit 0
}
catch {
    Write-ErrorLog "Group Service Generation failed: $($_.Exception.Message)"
    exit 1
}
