# utils.psm1 - Enhanced shared utilities for new-protozoa automation scripts
# Implements PowerShell best practices with centralized logging, parameter validation, and error handling

#Requires -Version 5.1

# Import required modules
if (-not (Get-Module -Name Microsoft.PowerShell.Utility -ListAvailable)) {
    throw "Required PowerShell.Utility module not available"
}

# Global configuration
$script:LogLevel = "Info"
$script:LogFile = Join-Path $PSScriptRoot "automation.log"
$script:MaxLogSize = 10MB

# Initialize log file with rotation
function Initialize-LogFile {
    [CmdletBinding()]
    param()
    
    if (Test-Path $script:LogFile) {
        $logInfo = Get-Item $script:LogFile
        if ($logInfo.Length -gt $script:MaxLogSize) {
            $backupLog = $script:LogFile -replace '\.log$', "_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
            Move-Item $script:LogFile $backupLog -Force
            Write-Host "[SYSTEM] Log rotated to: $backupLog" -ForegroundColor DarkGray
        }
    }
}

# Enhanced logging functions with file output and levels
function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet("Debug", "Info", "Warning", "Error", "Success")]
        [string]$Level = "Info",
        
        [Parameter(Mandatory = $false)]
        [switch]$NoConsole
    )
    
    if ([string]::IsNullOrWhiteSpace($Message)) {
        $Message = '<empty>'
    }
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    
    # Write to log file
    try {
        Add-Content -Path $script:LogFile -Value $logEntry -ErrorAction Stop
    }
    catch {
        Write-Warning "Failed to write to log file: $($_.Exception.Message)"
    }
    
    # Write to console unless suppressed
    if (-not $NoConsole) {
        $color = switch ($Level) {
            "Debug" { "DarkGray" }
            "Info" { "Cyan" }
            "Warning" { "Yellow" }
            "Error" { "Red" }
            "Success" { "Green" }
            default { "White" }
        }
        Write-Host "[$($Level.ToUpper().PadRight(7))] $Message" -ForegroundColor $color
    }
}

# Wrapper functions with approved PowerShell verbs
function Write-InfoLog {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)][string]$Message)
    Write-Log -Message $Message -Level "Info"
}

function Write-SuccessLog {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)][string]$Message)
    Write-Log -Message $Message -Level "Success"
}

function Write-WarningLog {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)][string]$Message)
    Write-Log -Message $Message -Level "Warning"
}

function Write-ErrorLog {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)][string]$Message)
    Write-Log -Message $Message -Level "Error"
}

function Write-DebugLog {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)][string]$Message)
    if ($VerbosePreference -ne 'SilentlyContinue') {
        Write-Log -Message $Message -Level "Debug"
    }
}

function Write-StepHeader {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)][string]$StepName)
    $separator = "=" * 50
    Write-Host "`n$separator" -ForegroundColor Magenta
    Write-Host " $StepName " -ForegroundColor Magenta
    Write-Host "$separator`n" -ForegroundColor Magenta
    Write-Log -Message "=== $StepName ===" -Level "Info" -NoConsole
}

# Backward compatibility aliases (will show warnings but work)
Set-Alias -Name "Log-Info" -Value "Write-InfoLog"
Set-Alias -Name "Log-Success" -Value "Write-SuccessLog" 
Set-Alias -Name "Log-Warning" -Value "Write-WarningLog"
Set-Alias -Name "Log-Error" -Value "Write-ErrorLog"
Set-Alias -Name "Log-Debug" -Value "Write-DebugLog"
Set-Alias -Name "Log-Step" -Value "Write-StepHeader"

# Enhanced validation helpers with proper error handling
function Test-NodeInstalled {
    [CmdletBinding()]
    [OutputType([bool])]
    param()
    
    try {
        $null = Get-Command node -ErrorAction Stop
        $version = node --version 2>$null
        Write-DebugLog "Node.js detected: $version"
        return $true
    }
    catch {
        Write-DebugLog "Node.js not found in PATH"
        return $false
    }
}

function Test-PnpmInstalled {
    [CmdletBinding()]
    [OutputType([bool])]
    param()
    
    try {
        $null = Get-Command pnpm -ErrorAction Stop
        $version = pnpm --version 2>$null
        Write-DebugLog "pnpm detected: $version"
        return $true
    }
    catch {
        Write-DebugLog "pnpm not found in PATH"
        return $false
    }
}

function Test-GitInstalled {
    [CmdletBinding()]
    [OutputType([bool])]
    param()
    
    try {
        $null = Get-Command git -ErrorAction Stop
        $version = git --version 2>$null
        Write-DebugLog "Git detected: $version"
        return $true
    }
    catch {
        Write-DebugLog "Git not found in PATH"
        return $false
    }
}

# Missing utility functions that were causing errors
function Test-DirectoryStructure {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $false)]
        [string]$ProjectRoot = "."
    )
    
    try {
        $requiredDirs = @(
            "src",
            "src/domains", 
            "src/shared",
            "src/shared/lib",
            "src/shared/types",
            "src/shared/config",
            "tests"
        )
        
        $domains = Get-DomainList
        foreach ($domain in $domains) {
            $requiredDirs += @(
                "src/domains/$domain",
                "src/domains/$domain/services",
                "src/domains/$domain/types",
                "tests/$domain"
            )
        }
        
        foreach ($dir in $requiredDirs) {
            $fullPath = Join-Path $ProjectRoot $dir
            if (-not (Test-Path $fullPath)) {
                Write-WarningLog "Missing required directory: $fullPath"
                return $false
            }
        }
        
        Write-DebugLog "Directory structure validation passed"
        return $true
    }
    catch {
        Write-ErrorLog "Directory structure validation failed: $($_.Exception.Message)"
        return $false
    }
}

function Test-ProjectStructure {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $false)]
        [string]$ProjectRoot = "."
    )
    
    try {
        # Check for required configuration files
        $requiredFiles = @(
            "package.json",
            "tsconfig.json",
            ".eslintrc.json"
        )
        
        $allValid = $true
        
        foreach ($file in $requiredFiles) {
            $fullPath = Join-Path $ProjectRoot $file
            if (-not (Test-Path $fullPath)) {
                Write-WarningLog "Missing configuration file: $fullPath"
                $allValid = $false
            }
        }
        
        # Check directory structure
        if (-not (Test-DirectoryStructure -ProjectRoot $ProjectRoot)) {
            $allValid = $false
        }
        
        if ($allValid) {
            Write-DebugLog "Project structure validation passed"
        }
        
        return $allValid
    }
    catch {
        Write-ErrorLog "Project structure validation failed: $($_.Exception.Message)"
        return $false
    }
}

function Test-PowerShellVersion {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $false)]
        [string]$MinimumVersion = "5.1"
    )
    
    try {
        $currentVersion = $PSVersionTable.PSVersion
        $minimumVersionObj = [version]$MinimumVersion
        
        if ($currentVersion -ge $minimumVersionObj) {
            Write-DebugLog "PowerShell version check passed: $currentVersion >= $MinimumVersion"
            return $true
        } else {
            Write-WarningLog "PowerShell version too old: $currentVersion < $MinimumVersion"
            return $false
        }
    }
    catch {
        Write-ErrorLog "PowerShell version check failed: $($_.Exception.Message)"
        return $false
    }
}

function Test-ExecutionPolicy {
    [CmdletBinding()]
    [OutputType([bool])]
    param()
    
    try {
        $policy = Get-ExecutionPolicy
        $allowedPolicies = @("RemoteSigned", "Unrestricted", "Bypass")
        
        if ($policy -in $allowedPolicies) {
            Write-DebugLog "Execution policy is acceptable: $policy"
            return $true
        } else {
            Write-WarningLog "Execution policy may cause issues: $policy"
            return $false
        }
    }
    catch {
        Write-ErrorLog "Execution policy check failed: $($_.Exception.Message)"
        return $false
    }
}

function Get-DomainList {
    [CmdletBinding()]
    [OutputType([string[]])]
    param()
    
    # Centralized domain list - matches build_design.md specifications
    return @(
        "rendering",
        "animation", 
        "effect",
        "trait",
        "physics",
        "particle",
        "formation",
        "group",
        "rng",
        "bitcoin"
    )
}

# Enhanced directory creation with idempotency and validation
function New-DirectoryTree {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Paths,
        
        [Parameter(Mandatory = $false)]
        [switch]$Force
    )
    
    foreach ($path in $Paths) {
        try {
            if (Test-Path $path) {
                Write-DebugLog "Directory already exists: $path"
                continue
            }
            
            if ($PSCmdlet.ShouldProcess($path, "Create Directory")) {
                $null = New-Item -Path $path -ItemType Directory -Force:$Force -ErrorAction Stop
                Write-DebugLog "Created directory: $path"
            }
        }
        catch {
            $errorMsg = "Failed to create directory '$path': $($_.Exception.Message)"
            Write-ErrorLog $errorMsg
            throw $errorMsg
        }
    }
}

function Get-ServiceName {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Domain
    )
    
    # Convert domain name to PascalCase service name
    $serviceName = (Get-Culture).TextInfo.ToTitleCase($Domain.ToLower()) + "Service"
    Write-DebugLog "Generated service name for domain '$Domain': $serviceName"
    return $serviceName
}

function Get-DomainPhaseNumber {
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Domain
    )
    
    # Phase mapping based on build_checklist.md
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
    
    $phase = $phaseMap[$Domain]
    if (-not $phase) {
        Write-WarningLog "Unknown domain phase for '$Domain', defaulting to 8"
        return 8
    }
    
    return $phase
}

# File operation helpers with enhanced error handling
function Backup-File {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateScript({Test-Path $_})]
        [string]$FilePath,
        
        [Parameter(Mandatory = $false)]
        [string]$BackupSuffix = "_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    )
    
    $backupPath = $FilePath + $BackupSuffix
    
    try {
        if ($PSCmdlet.ShouldProcess($FilePath, "Backup to $backupPath")) {
            Copy-Item -Path $FilePath -Destination $backupPath -ErrorAction Stop
            Write-DebugLog "File backed up: $FilePath -> $backupPath"
            return $backupPath
        }
    }
    catch {
        $errorMsg = "Failed to backup file '$FilePath': $($_.Exception.Message)"
        Write-ErrorLog $errorMsg
        throw $errorMsg
    }
}

function Remove-FilesSafely {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Patterns,
        
        [Parameter(Mandatory = $false)]
        [string]$SearchPath = ".",
        
        [Parameter(Mandatory = $false)]
        [switch]$Recurse
    )
    
    $removedCount = 0
    
    foreach ($pattern in $Patterns) {
        try {
            $files = Get-ChildItem -Path $SearchPath -Filter $pattern -Recurse:$Recurse -ErrorAction SilentlyContinue
            
            foreach ($file in $files) {
                if ($PSCmdlet.ShouldProcess($file.FullName, "Remove File")) {
                    Remove-Item $file.FullName -Force -ErrorAction Stop
                    Write-DebugLog "Removed file: $($file.FullName)"
                    $removedCount++
                }
            }
        }
        catch {
            Write-WarningLog "Failed to remove files matching '$pattern': $($_.Exception.Message)"
        }
    }
    
    if ($removedCount -gt 0) {
        Write-InfoLog "Removed $removedCount files matching patterns: $($Patterns -join ', ')"
    }
    
    return $removedCount
}

# Error handling wrapper for script execution
function Invoke-ScriptWithErrorHandling {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$OperationName,
        
        [Parameter(Mandatory = $true)]
        [scriptblock]$ScriptBlock,
        
        [Parameter(Mandatory = $false)]
        [switch]$ContinueOnError
    )
    
    try {
        Write-DebugLog "Starting operation: $OperationName"
        $result = & $ScriptBlock
        Write-DebugLog "Operation completed successfully: $OperationName"
        return $result
    }
    catch {
        $errorMsg = "Operation failed '$OperationName': $($_.Exception.Message)"
        Write-ErrorLog $errorMsg
        
        if (-not $ContinueOnError) {
            throw
        }
        
        return $null
    }
}

# File content generation helpers
function New-TypeScriptConfig {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $false)]
        [string[]]$AdditionalPaths = @()
    )
    
    $config = @{
        compilerOptions = @{
            target = "ES2022"
            lib = @("ES2022", "DOM", "DOM.Iterable")
            allowJs = $true
            skipLibCheck = $true
            esModuleInterop = $true
            allowSyntheticDefaultImports = $true
            strict = $true
            forceConsistentCasingInFileNames = $true
            noFallthroughCasesInSwitch = $true
            module = "ESNext"
            moduleResolution = "bundler"
            resolveJsonModule = $true
            isolatedModules = $true
            noEmit = $true
            jsx = "react-jsx"
            baseUrl = "."
            paths = @{
                "@/*" = @("./src/*")
                "@/domains/*" = @("./src/domains/*")
                "@/shared/*" = @("./src/shared/*")
                "@/components/*" = @("./src/components/*")
            }
        }
        include = @(
            "src/**/*",
            "src/**/*.tsx"
        )
        exclude = @(
            "node_modules",
            "dist",
            "build",
            "tests"
        )
    }
    
    return ($config | ConvertTo-Json -Depth 10)
}

function New-ESLintConfig {
    [CmdletBinding()]
    [OutputType([string])]
    param()
    
    $config = @{
        env = @{
            browser = $true
            es2021 = $true
            node = $true
        }
        extends = @(
            "eslint:recommended",
            "@typescript-eslint/recommended"
        )
        parser = "@typescript-eslint/parser"
        parserOptions = @{
            ecmaVersion = "latest"
            sourceType = "module"
        }
        plugins = @(
            "@typescript-eslint"
        )
        rules = @{
            "@typescript-eslint/no-unused-vars" = "error"
            "@typescript-eslint/no-explicit-any" = "warn"
            "no-console" = "warn"
            "prefer-const" = "error"
        }
        overrides = @(
            @{
                files = @("src/domains/*/services/*.ts")
                rules = @{
                    "max-lines" = @("error", 500)
                }
            }
        )
    }
    
    return ($config | ConvertTo-Json -Depth 10)
}

function New-PackageJson {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $false)]
        [string]$ProjectName = "new-protozoa",
        
        [Parameter(Mandatory = $false)]
        [string]$Version = "1.0.0"
    )
    
    $packageConfig = @{
        name = $ProjectName
        version = $Version
        description = "Bitcoin Ordinals Digital Organism Simulation"
        main = "src/index.ts"
        type = "module"
        scripts = @{
            dev = "vite"
            build = "tsc && vite build"
            lint = "eslint src --ext ts,tsx --report-unused-disable-directives --max-warnings 0"
            "lint:fix" = "eslint src --ext ts,tsx --fix"
            preview = "vite preview"
            test = "vitest"
            "type-check" = "tsc --noEmit"
        }
        dependencies = @{
            winston = "^3.11.0"
            three = "^0.158.0"
            zustand = "^4.4.7"
            "cross-fetch" = "^4.0.0"
        }
        devDependencies = @{
            "@types/node" = "^20.9.0"
            "@types/three" = "^0.158.0"
            "@typescript-eslint/eslint-plugin" = "^6.11.0"
            "@typescript-eslint/parser" = "^6.11.0"
            eslint = "^8.54.0"
            typescript = "^5.2.2"
            vite = "^5.0.0"
            vitest = "^0.34.6"
        }
        keywords = @(
            "bitcoin",
            "ordinals", 
            "blockchain",
            "three.js",
            "typescript",
            "digital-organisms"
        )
        author = "Protozoa Development Team"
        license = "MIT"
    }
    
    return ($packageConfig | ConvertTo-Json -Depth 10)
}

# Add consolidated regex helpers and console styling utilities

# ============================================================================
# REGEX HELPER FUNCTIONS (Consolidated)
# ============================================================================

function Select-RegexMatches {
    <#
        .SYNOPSIS
            Returns all matches for a pattern in the provided input string.
        .DESCRIPTION
            Wrapper around [regex]::Matches for simpler consumption in scripts.
        .PARAMETER Input
            The input string to search.
        .PARAMETER Pattern
            The regex pattern.
        .PARAMETER Options
            Optional RegexOptions flags (defaults to None).
        .OUTPUTS
            System.Text.RegularExpressions.Match[]
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$Input,
        [Parameter(Mandatory = $true)][string]$Pattern,
        [Parameter(Mandatory = $false)][System.Text.RegularExpressions.RegexOptions]$Options = [System.Text.RegularExpressions.RegexOptions]::None
    )

    return [regex]::Matches($Input, $Pattern, $Options)
}

function Test-RegexMatch {
    <#
        .SYNOPSIS
            Tests whether the pattern exists in the input string.
        .OUTPUTS
            [bool]
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)][string]$Input,
        [Parameter(Mandatory = $true)][string]$Pattern,
        [Parameter(Mandatory = $false)][System.Text.RegularExpressions.RegexOptions]$Options = [System.Text.RegularExpressions.RegexOptions]::None
    )
    return [regex]::IsMatch($Input, $Pattern, $Options)
}

function ConvertFrom-SemVer {
    <#
        .SYNOPSIS
            Parses a semantic version string into its components.
        .OUTPUTS
            [pscustomobject] with Major, Minor, Patch, PreRelease, Build
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$Version
    )
    $pattern = '^(?<major>\d+)\.(?<minor>\d+)\.(?<patch>\d+)(?:-(?<pre>[0-9A-Za-z.-]+))?(?:\+(?<build>[0-9A-Za-z.-]+))?$'
    $m = [regex]::Match($Version, $pattern)
    if (-not $m.Success) { throw "Invalid semantic version: $Version" }
    return [pscustomobject]@{
        Major = [int]$m.Groups['major'].Value
        Minor = [int]$m.Groups['minor'].Value
        Patch = [int]$m.Groups['patch'].Value
        PreRelease = $m.Groups['pre'].Value
        Build = $m.Groups['build'].Value
    }
}

# ============================================================================
# CONSOLE STYLING HELPERS (Consolidated)
# ============================================================================

function Write-Colored {
    <#
        .SYNOPSIS
            Writes a colored message to the host.
        .PARAMETER Message
            The message to display.
        .PARAMETER Color
            Console foreground color (Default: White).
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$Message,
        [Parameter(Mandatory = $false)][System.ConsoleColor]$Color = [System.ConsoleColor]::White
    )
    Write-Host $Message -ForegroundColor $Color
}

function Write-SectionHeader {
    <#
        .SYNOPSIS
            Writes a prominent section header to the console using a uniform style.
    #>
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)][string]$Title)
    $sep = '=' * 60
    Write-Colored "`n$sep" 'DarkCyan'
    Write-Colored "  $Title" 'Cyan'
    Write-Colored "$sep`n" 'DarkCyan'
}

# === File Utilities ===
function Get-FileLineCount {
    <#
        .SYNOPSIS
            Returns the total number of lines in a text file.
        .DESCRIPTION
            Lightweight helper used by various build-automation scripts for statistics and validation.
            Reads the file in chunks (via -ReadCount) so it remains memory-efficient even for large files.
        .PARAMETER Path
            The path to the file whose lines should be counted.
        .OUTPUTS
            [int]  – total line count (0 on error)
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $_ -PathType Leaf })]
        [string]$Path
    )

    try {
        Write-DebugLog "Counting lines in file: $Path"
        $lineCount = 0
        Get-Content -Path $Path -ReadCount 1000 -ErrorAction Stop | ForEach-Object { $lineCount += $_.Count }
        return $lineCount
    }
    catch {
        Write-WarningLog "Get-FileLineCount failed for '$Path': $($_.Exception.Message)"
        return 0
    }
}

# === Messaging Helpers ===
function Write-StatusMessage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)][string]$Message = '',
        [Parameter(Mandatory=$false)][ValidateSet('Info','Success','Warning','Error','Debug')][string]$Level = 'Info'
    )
    if ([string]::IsNullOrWhiteSpace($Message)) {
        $Message = '<empty>'
    }
    switch ($Level) {
        'Success' { Write-SuccessLog $Message }
        'Warning' { Write-WarningLog $Message }
        'Error'   { Write-ErrorLog   $Message }
        'Debug'   { Write-DebugLog   $Message }
        default   { Write-InfoLog    $Message }
    }
}

# === Build Helpers ===
function Test-TypeScriptCompiles {
    [CmdletBinding()]
    [OutputType([bool])]
    param([string]$ProjectRoot = '.')
    try {
        Push-Location $ProjectRoot
        Write-InfoLog 'Running tsc --noEmit for compilation check'
        $null = & npx tsc --noEmit 2>&1
        $ok = ($LASTEXITCODE -eq 0)
        if ($ok) { Write-SuccessLog 'TypeScript compile pass' } else { Write-WarningLog 'TypeScript compile errors' }
        return $ok
    }
    catch {
        Write-ErrorLog "Test-TypeScriptCompiles failed: $($_.Exception.Message)"
        return $false
    }
    finally { Pop-Location }
}

# === TEMPLATE PROCESSING ===
function Write-TemplateFile {
    <#
        .SYNOPSIS
            Writes a file based on a template and optional token replacement.
        .DESCRIPTION
            Reads a template (usually located under the /templates directory) and writes
            it to the desired destination. Optionally performs token substitution using
            the provided -TokenMap hashtable. By default, any token in the template of
            the form {{TOKEN_NAME}} will be replaced with the corresponding value in
            the TokenMap (case-insensitive key match). The destination path is inferred
            by stripping the ".template" extension from the template relative path if
            -DestinationPath is not supplied.
        .PARAMETER TemplateRelPath
            Path of the template file relative to the /templates directory.
        .PARAMETER DestinationPath
            Absolute or relative destination path for the generated file. When omitted,
            the path will be <ProjectRoot>/<TemplateRelPath> with the trailing
            ".template" segment removed.
        .PARAMETER TokenMap
            Hashtable containing token/value pairs for placeholder replacement.
        .PARAMETER ProjectRoot
            Root of the repository – defaults to the parent directory of the current
            script (works for both scripts/ and scripts/script_scrub/ callers).
        .PARAMETER Force
            Overwrite existing destination file without prompting. When not specified
            the file will be backed up (Backup-File) and then overwritten.
        .EXAMPLE
            Write-TemplateFile -TemplateRelPath 'components/App.tsx.template'
        .NOTES
            This util centralises template handling for 35+ scripts that generate code
            from the /templates directory, eliminating previous missing-function errors.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true)]
        [string]$TemplateRelPath,

        [Parameter(Mandatory = $false)]
        [string]$DestinationPath,

        [Parameter(Mandatory = $false)]
        [hashtable]$TokenMap = @{},

        [Parameter(Mandatory = $false)]
        [string]$ProjectRoot = (Split-Path $PSScriptRoot -Parent),

        [Parameter(Mandatory = $false)]
        [switch]$Force
    )

    try {
        # Resolve paths
        $templatePath = Join-Path (Join-Path $ProjectRoot 'templates') $TemplateRelPath
        if (-not (Test-Path $templatePath)) {
            throw "Template not found: $templatePath"
        }
        if (-not $DestinationPath) {
            # Strip trailing .template and place relative to ProjectRoot
            $relativeOut = $TemplateRelPath -replace '\.template$',''
            $DestinationPath = Join-Path $ProjectRoot $relativeOut
        }
        $destDir = Split-Path $DestinationPath -Parent
        if (-not (Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }

        # Read template content
        $content = Get-Content -Path $templatePath -Raw

        # Token replacement – {{TOKEN}}
        foreach ($key in $TokenMap.Keys) {
            $pattern = "{{${key}}}"
            $content = $content -replace [regex]::Escape($pattern), [string]$TokenMap[$key]
        }

        # Backup existing file when not -Force
        if (Test-Path $DestinationPath -and -not $Force) {
            Backup-File -FilePath $DestinationPath | Out-Null
        }

        if ($PSCmdlet.ShouldProcess($DestinationPath, 'Write Template File')) {
            Set-Content -Path $DestinationPath -Value $content -Encoding UTF8
            Write-SuccessLog "Template '$TemplateRelPath' written to '$DestinationPath'"
        }
    }
    catch {
        Write-ErrorLog "Write-TemplateFile failed: $($_.Exception.Message)"
        throw
    }
}

# >>> INSERTED: Template validation helper (moved here so export succeeds)
function Test-TemplateSyntax {
    <#
        .SYNOPSIS
            Validates template file syntax for common error patterns.
        .DESCRIPTION
            Performs lightweight checks on template files (e.g. .ts.template, .json.template)
            to ensure placeholder formatting and – for JSON – basic structural validity.
        .PARAMETER TemplatePath
            The absolute or relative path to the template file to validate.
        .OUTPUTS
            [bool] – $true when valid, otherwise $false.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$TemplatePath
    )

    try {
        if (-not (Test-Path $TemplatePath)) {
            Write-WarningLog "Template file not found: $TemplatePath"
            return $false
        }

        $content = Get-Content $TemplatePath -Raw -ErrorAction Stop

        # Validate TypeScript/TSX templates – placeholder pattern only
        if ($TemplatePath -match '\.tsx?\.template$') {
            if ($content -notmatch '{{[^}]+}}') {
                Write-WarningLog "Template appears to have no placeholders: $TemplatePath"
            }
        }
        # Validate JSON templates by temporarily replacing {{TOKEN}} with a string literal
        elseif ($TemplatePath -match '\.json\.template$') {
            try {
                $jsonTest = $content -replace '{{[^}]+}}', '"placeholder"'
                $null = $jsonTest | ConvertFrom-Json -ErrorAction Stop
            }
            catch {
                Write-WarningLog "Invalid JSON template syntax: $TemplatePath"
                return $false
            }
        }

        Write-DebugLog "Template syntax validation passed: $TemplatePath"
        return $true
    }
    catch {
        Write-ErrorLog "Template syntax validation failed for ${TemplatePath}: $($_.Exception.Message)"
        return $false
    }
}
# <<< END INSERTED FUNCTION

# Initialize logging on module import
Initialize-LogFile

# Export functions with approved verbs and aliases
Export-ModuleMember -Function @(
    'Write-Log', 'Write-InfoLog', 'Write-SuccessLog', 'Write-WarningLog', 'Write-ErrorLog', 'Write-DebugLog', 'Write-StepHeader',
    'Write-Colored', 'Write-SectionHeader',
    'Write-StatusMessage',
    'Select-RegexMatches', 'Test-RegexMatch', 'ConvertFrom-SemVer',
    'Test-NodeInstalled', 'Test-PnpmInstalled', 'Test-GitInstalled',
    'Test-DirectoryStructure', 'Test-ProjectStructure', 'Test-PowerShellVersion', 'Test-ExecutionPolicy',
    'New-DirectoryTree', 'Get-DomainList', 'Get-ServiceName', 'Get-DomainPhaseNumber',
    'Backup-File', 'Remove-FilesSafely',
    'Invoke-ScriptWithErrorHandling',
    'New-TypeScriptConfig', 'New-ESLintConfig', 'New-PackageJson',
    'Get-FileLineCount', 'Test-TypeScriptCompiles',
    'Initialize-ProjectDependencies', 'Test-ScriptDependencies', 'Repair-UtilityModule',
    'Write-TemplateFile',
    'Test-TemplateSyntax'
) -Alias @(
    'Log-Info', 'Log-Success', 'Log-Warning', 'Log-Error', 'Log-Debug', 'Log-Step'
)

# Note: Additional utility functions were previously defined here but
# have been consolidated above to avoid duplicate definitions

# End of module - all utility functions consolidated above
