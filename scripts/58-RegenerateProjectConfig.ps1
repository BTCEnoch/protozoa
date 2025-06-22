# 58-RegenerateProjectConfig.ps1
# Regenerates project configuration files from updated templates
# Fixes TypeScript configuration and dependency issues

param(
    [Parameter(Mandatory = $false)]
    [string]$ProjectRoot = (Split-Path $PSScriptRoot -Parent)
)

Import-Module "$PSScriptRoot\utils.psm1" -Force

Write-StepHeader "Regenerating Project Configuration from Templates"

try {
    # Regenerate TypeScript configuration files
    Write-InfoLog "Regenerating tsconfig.json from template"
    Write-TemplateFile -TemplateRelPath "tsconfig.json.template" -DestinationPath (Join-Path $ProjectRoot "tsconfig.json") -Force

    Write-InfoLog "Regenerating tsconfig.app.json from template"
    Write-TemplateFile -TemplateRelPath "tsconfig.app.json.template" -DestinationPath (Join-Path $ProjectRoot "tsconfig.app.json") -Force

    Write-InfoLog "Regenerating tsconfig.node.json from template"
    Write-TemplateFile -TemplateRelPath "tsconfig.node.json.template" -DestinationPath (Join-Path $ProjectRoot "tsconfig.node.json") -Force

    # Backup current package.json
    $packageJsonPath = Join-Path $ProjectRoot "package.json"
    if (Test-Path $packageJsonPath) {
        $backupPath = Join-Path $ProjectRoot "package.json.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        Copy-Item $packageJsonPath $backupPath
        Write-InfoLog "Backed up current package.json to: $backupPath"
    }

    # Regenerate package.json from template
    Write-InfoLog "Regenerating package.json from template"
    Write-TemplateFile -TemplateRelPath "package.json.template" -DestinationPath $packageJsonPath -Force

    Write-SuccessLog "All configuration files regenerated successfully"
    Write-InfoLog "Next steps:"
    Write-InfoLog "  1. Run 'npm install' to install updated dependencies"
    Write-InfoLog "  2. Run 'npm run type-check' to verify TypeScript compilation"

} catch {
    Write-ErrorLog "Failed to regenerate project configuration: $($_.Exception.Message)"
    throw
} 