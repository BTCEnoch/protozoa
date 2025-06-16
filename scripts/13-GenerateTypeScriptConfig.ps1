# 13-GenerateTypeScriptConfig.ps1
# Generates TypeScript, ESLint, and package.json configuration files
# Addresses Concern #4: TypeScript Configuration with domain boundary enforcement

#Requires -Version 5.1

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $false)]
    [string]$ProjectRoot = (Split-Path $PSScriptRoot -Parent),
    
    [Parameter(Mandatory = $false)]
    [switch]$Force,
    
    [Parameter(Mandatory = $false)]
    [string]$ProjectName = "new-protozoa",
    
    [Parameter(Mandatory = $false)]
    [string]$Version = "1.0.0"
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
    Write-StepHeader "TypeScript Configuration Generation - Phase 13"
    
    # Validate project root exists
    if (-not (Test-Path $ProjectRoot)) {
        throw "Project root does not exist: $ProjectRoot"
    }
    
    Push-Location $ProjectRoot
    Write-InfoLog "Working in project root: $ProjectRoot"
    
    # Generate package.json
    Invoke-ScriptWithErrorHandling -OperationName "Package.json Generation" -ScriptBlock {
        $packageJsonPath = "package.json"
        
        if ((Test-Path $packageJsonPath) -and -not $Force) {
            Write-WarningLog "package.json already exists. Use -Force to overwrite."
        } else {
            Write-InfoLog "Generating package.json with project dependencies..."
            $packageContent = New-PackageJson -ProjectName $ProjectName -Version $Version
            Set-Content -Path $packageJsonPath -Value $packageContent -Encoding UTF8
            Write-SuccessLog "Created package.json"
        }
    }
    
    # Generate tsconfig.json
    Invoke-ScriptWithErrorHandling -OperationName "TypeScript Configuration Generation" -ScriptBlock {
        $tsconfigPath = "tsconfig.json"
        
        if ((Test-Path $tsconfigPath) -and -not $Force) {
            Write-WarningLog "tsconfig.json already exists. Use -Force to overwrite."
        } else {
            Write-InfoLog "Generating tsconfig.json with domain path aliases..."
            $tsconfigContent = New-TypeScriptConfig
            Set-Content -Path $tsconfigPath -Value $tsconfigContent -Encoding UTF8
            Write-SuccessLog "Created tsconfig.json with path aliases:"
            Write-InfoLog "  @/* -> ./src/*"
            Write-InfoLog "  @/domains/* -> ./src/domains/*"
            Write-InfoLog "  @/shared/* -> ./src/shared/*"
            Write-InfoLog "  @/components/* -> ./src/components/*"
        }
    }
    
    # Generate .eslintrc.json
    Invoke-ScriptWithErrorHandling -OperationName "ESLint Configuration Generation" -ScriptBlock {
        $eslintrcPath = ".eslintrc.json"
        
        if ((Test-Path $eslintrcPath) -and -not $Force) {
            Write-WarningLog ".eslintrc.json already exists. Use -Force to overwrite."
        } else {
            Write-InfoLog "Generating .eslintrc.json with domain boundary rules..."
            $eslintContent = New-ESLintConfig
            Set-Content -Path $eslintrcPath -Value $eslintContent -Encoding UTF8
            Write-SuccessLog "Created .eslintrc.json with domain boundary enforcement"
            Write-InfoLog "  - 500 line limit for service files"
            Write-InfoLog "  - TypeScript strict rules enabled"
            Write-InfoLog "  - Cross-domain import detection ready"
        }
    }
    
    # Generate .gitignore
    Invoke-ScriptWithErrorHandling -OperationName "Git Ignore Generation" -ScriptBlock {
        $gitignorePath = ".gitignore"
        
        if ((Test-Path $gitignorePath) -and -not $Force) {
            Write-WarningLog ".gitignore already exists. Use -Force to overwrite."
        } else {
            $gitignoreContent = @"
# Dependencies
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
pnpm-debug.log*

# Build outputs
dist/
build/
*.tsbuildinfo

# Environment files
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# IDE files
.vscode/
.idea/
*.swp
*.swo

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Logs
logs/
*.log
automation.log*

# Runtime data
pids/
*.pid
*.seed
*.pid.lock

# Coverage directory used by tools like istanbul
coverage/
*.lcov

# Temporary folders
tmp/
temp/

# ESLint cache
.eslintcache

# Optional npm cache directory
.npm

# Optional eslint cache
.eslintcache

# Microbundle cache
.rpt2_cache/
.rts2_cache_cjs/
.rts2_cache_es/
.rts2_cache_umd/

# Optional REPL history
.node_repl_history

# Output of 'npm pack'
*.tgz

# Yarn Integrity file
.yarn-integrity

# dotenv environment variables file
.env
.env.test

# parcel-bundler cache (https://parceljs.org/)
.cache
.parcel-cache

# Next.js build output
.next

# Nuxt.js build / generate output
.nuxt

# Gatsby files
.cache/
public

# Storybook build outputs
.out
.storybook-out

# Temporary folders
tmp/
temp/
"@
            Set-Content -Path $gitignorePath -Value $gitignoreContent -Encoding UTF8
            Write-SuccessLog "Created .gitignore"
        }
    }
    
    Write-SuccessLog "TypeScript configuration generation completed!"
    Write-InfoLog ""
    Write-InfoLog "Generated files:"
    Write-InfoLog "  ✅ package.json - Project dependencies and scripts"
    Write-InfoLog "  ✅ tsconfig.json - TypeScript compiler configuration with path aliases"
    Write-InfoLog "  ✅ .eslintrc.json - ESLint rules with domain boundary enforcement"
    Write-InfoLog "  ✅ .gitignore - Git ignore patterns"
    Write-InfoLog ""
    Write-InfoLog "Next steps:"
    Write-InfoLog "  1. Run 'pnpm install' to install dependencies"
    Write-InfoLog "  2. Run '05-VerifyCompliance.ps1' to validate configuration"
    Write-InfoLog "  3. Begin domain implementation with Cursor AI"
    
    exit 0
}
catch {
    Write-ErrorLog "TypeScript configuration generation failed: $($_.Exception.Message)"
    exit 1
}
finally {
    try { Pop-Location -ErrorAction SilentlyContinue } catch { }
} 