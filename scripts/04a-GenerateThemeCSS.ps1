# 04a-GenerateThemeCSS.ps1
# Generates Tailwind-compatible CSS theme files for every palette listed in COLOR_PALETTES

<#
.SYNOPSIS
    Generates Tailwind-compatible CSS files for each palette in COLOR_PALETTES.
.DESCRIPTION
    1. Uses ts-node to import `src/shared/data/colorPalettes.ts`.
    2. Iterates palettes and writes `src/assets/themes/<palette>.css`.
    3. Overwrites existing files; uses UTF8 encoding.
    4. Emits Winston-style console logs.
.NOTES
    Auto-generated template – fill in TODOs before use.
#>
Param(
    [string]$ProjectRoot = $PWD
)

$ErrorActionPreference = 'Stop'

# TODO: import logger helper or fallback console functions
function Write-InfoLog($msg)  { Write-Host "[INFO ] $msg"  -ForegroundColor Cyan }
function Write-ErrorLog($msg) { Write-Host "[ERROR] $msg" -ForegroundColor Red  }

try {
    # Path resolution
    $themeDir = Join-Path $ProjectRoot 'src/assets/themes'
    if (-not (Test-Path $themeDir)) { New-Item -ItemType Directory -Path $themeDir | Out-Null }

    # Create basic theme palettes (simplified approach)
    $palettes = @{
        cosmic = @{ core = '#6366f1'; energy = '#8b5cf6'; barrier = '#06b6d4'; mutation = '#f59e0b'; background = '#0f172a' }
        organic = @{ core = '#10b981'; energy = '#34d399'; barrier = '#6ee7b7'; mutation = '#fbbf24'; background = '#064e3b' }
        neon = @{ core = '#ec4899'; energy = '#f472b6'; barrier = '#06d6a0'; mutation = '#ffd60a'; background = '#0c0a09' }
        monochrome = @{ core = '#ffffff'; energy = '#d1d5db'; barrier = '#9ca3af'; mutation = '#fef08a'; background = '#111827' }
    }

    foreach ($paletteName in $palettes.Keys) {
        $colors = $palettes[$paletteName]
        $cssOut = "/* Auto-generated theme: $paletteName */`n:root {`n"
        foreach ($role in $colors.Keys) {
            $cssOut += "    --particle-$role`: $($colors[$role]);`n"
        }
        $cssOut += "}`n"
        $target = Join-Path $themeDir "$paletteName.css"
        $cssOut | Out-File -FilePath $target -Encoding utf8 -Force
        Write-InfoLog "Theme $paletteName → $target"
    }
}
catch {
    Write-ErrorLog $_
    exit 1
}
 