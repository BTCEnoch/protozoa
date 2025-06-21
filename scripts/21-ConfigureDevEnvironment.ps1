# 21-ConfigureDevEnvironment.ps1 - Phase 1 Critical
# Copies dev-environment templates (.vscode, ESLint, Prettier, EditorConfig)

[CmdletBinding(SupportsShouldProcess)]
param(
  [Parameter(Mandatory=$false)]
  [string]$ProjectRoot = $PWD
)

try { Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop } catch { Write-Error "utils.psm1 import failed: $($_.Exception.Message)"; exit 1 }
$ErrorActionPreference = "Stop"

function Copy-TemplateFile($TemplateRel, $DestPath) {
  $template = Join-Path $ProjectRoot $TemplateRel
  Copy-Item -Path $template -Destination $DestPath -Force
  Write-InfoLog "Copied $(Split-Path $TemplateRel -Leaf)"
}

try {
  Write-StepHeader "Dev-Environment configuration"
  # .vscode directory
  $vscodeDir = Join-Path $ProjectRoot ".vscode"
  New-Item -Path $vscodeDir -ItemType Directory -Force | Out-Null

  # Copy VSCode settings & extensions
  Copy-TemplateFile "templates/.vscode/settings.json.template" (Join-Path $vscodeDir "settings.json")
  Copy-TemplateFile "templates/.vscode/extensions.json.template" (Join-Path $vscodeDir "extensions.json")

  # ESLint, Prettier, EditorConfig
  Copy-TemplateFile "templates/.eslintrc.json.template" (Join-Path $ProjectRoot ".eslintrc.json")
  Copy-TemplateFile "templates/.prettierrc.template"   (Join-Path $ProjectRoot ".prettierrc")
  Copy-TemplateFile "templates/.editorconfig.template"  (Join-Path $ProjectRoot ".editorconfig")

  Write-SuccessLog "Dev environment templates installed"
  exit 0
} catch {
  Write-ErrorLog "Dev environment configuration failed: $($_.Exception.Message)"; exit 1
}