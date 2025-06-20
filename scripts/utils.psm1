# utils.psm1 - Essential shared utilities for new-protozoa automation scripts
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

# Backward compatibility aliases
Set-Alias -Name "Log-Info" -Value "Write-InfoLog"
Set-Alias -Name "Log-Success" -Value "Write-SuccessLog" 
Set-Alias -Name "Log-Warning" -Value "Write-WarningLog"
Set-Alias -Name "Log-Error" -Value "Write-ErrorLog"
Set-Alias -Name "Log-Debug" -Value "Write-DebugLog"
Set-Alias -Name "Log-Step" -Value "Write-StepHeader"

# Enhanced validation helpers
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

# Template processing function
function Write-TemplateFile {
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

        # Token replacement
        foreach ($key in $TokenMap.Keys) {
            $pattern = "{{${key}}}"
            $content = $content -replace [regex]::Escape($pattern), [string]$TokenMap[$key]
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

# Enhanced error handling wrapper function
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
    
    Write-InfoLog "Starting operation: $OperationName"
    
    try {
        $result = & $ScriptBlock
        Write-SuccessLog "Operation completed successfully: $OperationName"
        return $result
    }
    catch {
        $errorMessage = "Operation failed: $OperationName - $($_.Exception.Message)"
        Write-ErrorLog $errorMessage
        Write-DebugLog "Stack trace: $($_.ScriptStackTrace)"
        
        if (-not $ContinueOnError) {
            throw $_
        } else {
            Write-WarningLog "Continuing execution despite error in: $OperationName"
            return $null
        }
    }
}

# Template validation helper function
function Test-TemplateSyntax {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$TemplatePath
    )
    
    try {
        if (-not (Test-Path $TemplatePath)) {
            Write-ErrorLog "Template file not found: $TemplatePath"
            return $false
        }
        
        $content = Get-Content -Path $TemplatePath -Raw -ErrorAction Stop
        
        # Basic syntax validation for common template issues
        $hasUnmatchedBraces = ($content -split '\{\{').Count -ne ($content -split '\}\}').Count
        if ($hasUnmatchedBraces) {
            Write-ErrorLog "Template has unmatched template braces: $TemplatePath"
            return $false
        }
        
        # Check for TypeScript/JavaScript syntax if applicable
        $fileExt = [System.IO.Path]::GetExtension($TemplatePath).ToLower()
        if ($fileExt -in @('.ts', '.tsx', '.js', '.jsx')) {
            # Basic validation - check for obvious syntax errors
            $hasUnmatchedParens = ($content -split '\(').Count -ne ($content -split '\)').Count
            $hasUnmatchedBrackets = ($content -split '\[').Count -ne ($content -split '\]').Count
            $hasUnmatchedCurlies = ($content -split '\{').Count -ne ($content -split '\}').Count
            
            if ($hasUnmatchedParens -or $hasUnmatchedBrackets -or $hasUnmatchedCurlies) {
                Write-ErrorLog "Template appears to have unmatched brackets/parentheses: $TemplatePath"
                return $false
            }
        }
        
        Write-DebugLog "Template syntax validation passed: $TemplatePath"
        return $true
    }
    catch {
        Write-ErrorLog "Template validation error for $TemplatePath`: $($_.Exception.Message)"
        return $false
    }
}

# PowerShell environment validation helpers
function Test-PowerShellVersion {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$MinimumVersion
    )
    
    try {
        $currentVersion = $PSVersionTable.PSVersion
        $minimumVersion = [System.Version]$MinimumVersion
        $result = $currentVersion -ge $minimumVersion
        
        Write-DebugLog "PowerShell version check: Current=$currentVersion, Required=$minimumVersion, Result=$result"
        return $result
    }
    catch {
        Write-ErrorLog "PowerShell version validation failed: $($_.Exception.Message)"
        return $false
    }
}

function Test-ExecutionPolicy {
    [CmdletBinding()]
    [OutputType([bool])]
    param()
    
    try {
        $currentPolicy = Get-ExecutionPolicy
        $acceptablePolicies = @('Unrestricted', 'RemoteSigned', 'Bypass')
        $result = $currentPolicy -in $acceptablePolicies
        
        Write-DebugLog "Execution policy check: Current=$currentPolicy, Acceptable=$($acceptablePolicies -join ','), Result=$result"
        return $result
    }
    catch {
        Write-ErrorLog "Execution policy validation failed: $($_.Exception.Message)"
        return $false
    }
}

function Test-TypeScriptCompiles {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $false)]
        [string]$ProjectRoot = (Split-Path $PSScriptRoot -Parent)
    )
    
    try {
        Write-DebugLog "Checking TypeScript compilation in: $ProjectRoot"
        
        # Check if tsconfig.json exists
        $tsconfigPath = Join-Path $ProjectRoot "tsconfig.json"
        if (-not (Test-Path $tsconfigPath)) {
            Write-DebugLog "No tsconfig.json found, skipping TypeScript compilation check"
            return $true
        }
        
        # Check if TypeScript is available
        $tscCommand = Get-Command tsc -ErrorAction SilentlyContinue
        if (-not $tscCommand) {
            Write-DebugLog "TypeScript compiler not found in PATH, checking node_modules..."
            $localTsc = Join-Path $ProjectRoot "node_modules\.bin\tsc.cmd"
            if (Test-Path $localTsc) {
                $tscCommand = $localTsc
                Write-DebugLog "Found local TypeScript compiler: $localTsc"
            } else {
                Write-DebugLog "TypeScript compiler not available, skipping compilation check"
                return $true
            }
        } else {
            $tscCommand = $tscCommand.Source
        }
        
        # Run TypeScript compilation check
        Push-Location $ProjectRoot
        try {
            $compileResult = & $tscCommand --noEmit --skipLibCheck 2>&1
            $success = $LASTEXITCODE -eq 0
            
            if ($success) {
                Write-DebugLog "TypeScript compilation check passed"
            } else {
                Write-DebugLog "TypeScript compilation has errors: $compileResult"
            }
            
            return $success
        }
        finally {
            Pop-Location
        }
    }
    catch {
        Write-DebugLog "TypeScript compilation check failed: $($_.Exception.Message)"
        return $false
    }
}

# Project structure validation functions
function Test-DirectoryStructure {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $false)]
        [string]$ProjectRoot = (Split-Path $PSScriptRoot -Parent)
    )
    
    try {
        Write-DebugLog "Testing directory structure in: $ProjectRoot"
        
        $requiredDirectories = @(
            "src",
            "src/domains",
            "src/shared",
            "scripts",
            "templates"
        )
        
        $missingDirs = @()
        foreach ($dir in $requiredDirectories) {
            $fullPath = Join-Path $ProjectRoot $dir
            if (-not (Test-Path $fullPath)) {
                $missingDirs += $dir
                Write-DebugLog "Missing directory: $dir"
            }
        }
        
        if ($missingDirs.Count -eq 0) {
            Write-DebugLog "Directory structure validation passed"
            return $true
        } else {
            Write-DebugLog "Directory structure validation failed. Missing: $($missingDirs -join ', ')"
            return $false
        }
    }
    catch {
        Write-ErrorLog "Directory structure test failed: $($_.Exception.Message)"
        return $false
    }
}

function Test-ProjectStructure {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $false)]
        [string]$ProjectRoot = (Split-Path $PSScriptRoot -Parent)
    )
    
    try {
        Write-DebugLog "Testing project structure in: $ProjectRoot"
        
        # Test directory structure first
        if (-not (Test-DirectoryStructure -ProjectRoot $ProjectRoot)) {
            throw "Directory structure validation failed"
        }
        
        # Test for critical files
        $requiredFiles = @(
            "package.json",
            "tsconfig.json",
            ".eslintrc.json"
        )
        
        $missingFiles = @()
        foreach ($file in $requiredFiles) {
            $fullPath = Join-Path $ProjectRoot $file
            if (-not (Test-Path $fullPath)) {
                $missingFiles += $file
                Write-DebugLog "Missing file: $file"
            }
        }
        
        # Test domain structure
        $domains = Get-DomainList
        $missingDomains = @()
        foreach ($domain in $domains) {
            $domainPath = Join-Path $ProjectRoot "src/domains/$domain"
            if (-not (Test-Path $domainPath)) {
                $missingDomains += $domain
                Write-DebugLog "Missing domain: $domain"
            }
        }
        
        $allIssues = @()
        if ($missingFiles.Count -gt 0) { $allIssues += "Missing files: $($missingFiles -join ', ')" }
        if ($missingDomains.Count -gt 0) { $allIssues += "Missing domains: $($missingDomains -join ', ')" }
        
        if ($allIssues.Count -eq 0) {
            Write-DebugLog "Project structure validation passed"
            return $true
        } else {
            Write-DebugLog "Project structure validation failed. Issues: $($allIssues -join '; ')"
            return $false
        }
    }
    catch {
        Write-ErrorLog "Project structure test failed: $($_.Exception.Message)"
        return $false
    }
}

# File utility functions
function Get-FileLineCount {
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )
    
    try {
        if (-not (Test-Path $FilePath)) {
            Write-DebugLog "File not found: $FilePath"
            return 0
        }
        
        $content = Get-Content -Path $FilePath -ErrorAction Stop
        $lineCount = if ($content) { $content.Count } else { 0 }
        
        Write-DebugLog "File $FilePath has $lineCount lines"
        return $lineCount
    }
    catch {
        Write-ErrorLog "Failed to count lines in file $FilePath`: $($_.Exception.Message)"
        return 0
    }
}

# Initialize logging on module import
Initialize-LogFile

# Progress bar utilities for installation and validation phases
function Write-InstallationProgress {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Activity,
        
        [Parameter(Mandatory = $true)]
        [string]$Status,
        
        [Parameter(Mandatory = $true)]
        [int]$PercentComplete,
        
        [Parameter(Mandatory = $false)]
        [string]$CurrentOperation,
        
        [Parameter(Mandatory = $false)]
        [int]$Id = 1
    )
    
    Write-Progress -Id $Id -Activity $Activity -Status $Status -PercentComplete $PercentComplete -CurrentOperation $CurrentOperation
    Write-DebugLog "Progress: $Activity - $Status ($PercentComplete%)"
}

function Write-ValidationProgress {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ValidationName,
        
        [Parameter(Mandatory = $true)]
        [int]$Current,
        
        [Parameter(Mandatory = $true)]
        [int]$Total,
        
        [Parameter(Mandatory = $false)]
        [string]$CurrentItem = ""
    )
    
    $percentComplete = [math]::Round(($Current / $Total) * 100, 2)
    $status = "Validating $Current of $Total"
    
    if ($CurrentItem) {
        $status += " - $CurrentItem"
    }
    
    Write-Progress -Id 2 -Activity "[VALIDATE] $ValidationName Validation" -Status $status -PercentComplete $percentComplete -CurrentOperation $CurrentItem
    Write-DebugLog "Validation Progress: $ValidationName - $Current/$Total ($percentComplete%)"
}

function Complete-Progress {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [int]$Id = 1
    )
    
    Write-Progress -Id $Id -Completed
}

function Write-DependencyInstallLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Package,
        
        [Parameter(Mandatory = $true)]
        [string]$Status,
        
        [Parameter(Mandatory = $false)]
        [string]$Version = "",
        
        [Parameter(Mandatory = $false)]
        [string]$InstallTime = "",
        
        [Parameter(Mandatory = $false)]
        [string]$Size = ""
    )
    
    $logMessage = "[PACKAGE] $Package"
    if ($Version) { $logMessage += " v$Version" }
    $logMessage += " - $Status"
    if ($InstallTime) { $logMessage += " (${InstallTime}s)" }
    if ($Size) { $logMessage += " [$Size]" }
    
    switch ($Status.ToLower()) {
        "installed" { Write-SuccessLog $logMessage }
        "skipped" { Write-InfoLog $logMessage }
        "failed" { Write-ErrorLog $logMessage }
        "downloading" { Write-InfoLog $logMessage }
        "cached" { Write-InfoLog $logMessage }
        default { Write-InfoLog $logMessage }
    }
}

function Start-InstallationPhase {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PhaseName,
        
        [Parameter(Mandatory = $true)]
        [int]$TotalSteps
    )
    
    Write-StepHeader "[INSTALL] $PhaseName Installation Phase"
    Write-InfoLog "Beginning $PhaseName installation with $TotalSteps steps"
    
    return @{
        PhaseName = $PhaseName
        TotalSteps = $TotalSteps
        CurrentStep = 0
        StartTime = Get-Date
    }
}

function Complete-InstallationPhase {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$PhaseInfo
    )
    
    $endTime = Get-Date
    $duration = ($endTime - $PhaseInfo.StartTime).TotalSeconds
    
    Complete-Progress -Id 1
    Complete-Progress -Id 2
    
    Write-SuccessLog "[SUCCESS] $($PhaseInfo.PhaseName) installation completed successfully!"
    Write-InfoLog "   Duration: $([math]::Round($duration, 2)) seconds"
    Write-InfoLog "   Steps completed: $($PhaseInfo.CurrentStep)/$($PhaseInfo.TotalSteps)"
}

# Export functions with approved verbs and aliases
Export-ModuleMember -Function @(
    'Write-Log', 'Write-InfoLog', 'Write-SuccessLog', 'Write-WarningLog', 'Write-ErrorLog', 'Write-DebugLog', 'Write-StepHeader',
    'Test-NodeInstalled', 'Test-PnpmInstalled', 'Test-GitInstalled',
    'New-DirectoryTree', 'Get-DomainList', 'Get-ServiceName',
    'Write-TemplateFile', 'Invoke-ScriptWithErrorHandling', 'Test-TemplateSyntax',
    'Test-PowerShellVersion', 'Test-ExecutionPolicy', 'Test-TypeScriptCompiles',
    'Test-DirectoryStructure', 'Test-ProjectStructure', 'Get-FileLineCount',
    'Write-InstallationProgress', 'Write-ValidationProgress', 'Complete-Progress', 
    'Write-DependencyInstallLog', 'Start-InstallationPhase', 'Complete-InstallationPhase'
) -Alias @(
    'Log-Info', 'Log-Success', 'Log-Warning', 'Log-Error', 'Log-Debug', 'Log-Step'
) 