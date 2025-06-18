# dependency-graph.psm1
# Dependency relationship mapping and analysis utilities
# Used to build and analyze dependency graphs between PowerShell scripts

#Requires -Version 5.1

<#
.SYNOPSIS
    Analyzes script dependencies and builds a dependency graph
.PARAMETER ScriptDirectory
    Directory containing PowerShell scripts to analyze
.RETURNS
    Hashtable representing the dependency graph
#>
function New-DependencyGraph {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ScriptDirectory
    )
    
    if (-not (Test-Path $ScriptDirectory)) {
        throw "Script directory not found: $ScriptDirectory"
    }
    
    $scripts = Get-ChildItem -Path $ScriptDirectory -Filter "*.ps1" -Recurse
    $dependencyGraph = @{}
    
    foreach ($script in $scripts) {
        $scriptName = $script.BaseName
        $dependencies = Get-ScriptDependencies -ScriptPath $script.FullName
        if (-not $dependencies) { $dependencies = @() }
        
        $cleanDeps = $dependencies | Where-Object { $_ -and $_ -ne 'False' }
        $dependencyGraph[$scriptName] = @{
            FilePath = $script.FullName
            Dependencies = $cleanDeps
            Dependents = @()  # Will be populated in second pass
        }
    }
    
    # Second pass: populate dependents (reverse dependencies)
    foreach ($scriptName in $dependencyGraph.Keys) {
        foreach ($dependency in $dependencyGraph[$scriptName].Dependencies) {
            if ($dependencyGraph.ContainsKey($dependency)) {
                $dependencyGraph[$dependency].Dependents += $scriptName
            }
        }
    }
    
    return $dependencyGraph
}

<#
.SYNOPSIS
    Extracts dependencies from a single PowerShell script
.PARAMETER ScriptPath
    Path to the PowerShell script to analyze
.RETURNS
    Array of script dependencies (other scripts this one depends on)
#>
function Get-ScriptDependencies {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ScriptPath
    )
    
    $dependencies = @()
    $content = Get-Content -Path $ScriptPath -Raw
    
    # Look for explicit script execution patterns
    $scriptCallPatterns = @(
        '& "([^"]+\.ps1)"',           # & "script.ps1"
        "& '([^']+\.ps1)'",           # & 'script.ps1'  
        '\. "([^"]+\.ps1)"',          # . "script.ps1" (dot sourcing)
        "\. '([^']+\.ps1)'",          # . 'script.ps1'
        'Invoke-Expression.*"([^"]+\.ps1)"',  # Invoke-Expression calls
        'Start-Process.*"([^"]+\.ps1)"'       # Start-Process calls
    )
    
    foreach ($pattern in $scriptCallPatterns) {
        $regexMatches = [regex]::Matches($content, $pattern, 'IgnoreCase')
        foreach ($match in $regexMatches) {
            $scriptPath = $match.Groups[1].Value
            $scriptName = [System.IO.Path]::GetFileNameWithoutExtension($scriptPath)
            if ($scriptName -and $dependencies -notcontains $scriptName) {
                $dependencies += $scriptName
            }
        }
    }
    
    # Look for Import-Module calls to other scripts
    $importPattern = "Import-Module.*[`"']([^`"']*\.ps1)[`"']"
    $importRegexMatches = [regex]::Matches($content, $importPattern, 'IgnoreCase')
    foreach ($match in $importRegexMatches) {
        $modulePath = $match.Groups[1].Value
        $moduleName = [System.IO.Path]::GetFileNameWithoutExtension($modulePath)
        if ($moduleName -and $dependencies -notcontains $moduleName) {
            $dependencies += $moduleName
        }
    }
    
    # Remove spurious literal "false" matches
    $dependencies = $dependencies | Where-Object { $_ -and $_ -ne 'False' -and $_ -notmatch '^false$' }
    return $dependencies
}

<#
.SYNOPSIS
    Detects circular dependencies in the dependency graph
.PARAMETER DependencyGraph
    Dependency graph from Build-DependencyGraph
.RETURNS
    Array of circular dependency chains
#>
function Test-CircularDependencies {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$DependencyGraph
    )
    
    $visited = @{}
    $recursionStack = @{}
    $circularChains = @()
    
    function Find-Cycle {
        param($node, $path)
        
        if ($recursionStack[$node]) {
            # Found a cycle - extract the circular part
            $cycleStart = $path.IndexOf($node)
            $cycle = $path[$cycleStart..($path.Count - 1)] + $node
            $unique = $cycle | Select-Object -Unique
            if ($unique.Count -gt 1) {
                $circularChains += , $cycle
            }
            return $true
        }
        
        if ($visited[$node]) {
            return $false
        }
        
        $visited[$node] = $true
        $recursionStack[$node] = $true
        $newPath = $path + $node
        
        foreach ($dependency in $DependencyGraph[$node].Dependencies) {
            if ($DependencyGraph.ContainsKey($dependency)) {
                Find-Cycle -node $dependency -path $newPath
            }
        }
        
        $recursionStack[$node] = $false
        return $false
    }
    
    foreach ($script in $DependencyGraph.Keys) {
        if ($DependencyGraph[$script].Dependencies.Count -eq 0) { continue }
        if (-not $visited[$script]) {
            Find-Cycle -node $script -path @()
        }
    }
    
    return $circularChains
}

<#
.SYNOPSIS
    Generates a dependency graph visualization in DOT format
.PARAMETER DependencyGraph
    Dependency graph from Build-DependencyGraph
.RETURNS
    String containing DOT format graph visualization
#>
function ConvertTo-DependencyGraphDot {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$DependencyGraph
    )
    
    $dotContent = @"
digraph DependencyGraph {
    rankdir=LR;
    node [shape=box, style=rounded];
    
"@
    
    foreach ($script in $DependencyGraph.Keys) {
        foreach ($dependency in $DependencyGraph[$script].Dependencies) {
            $dotContent += "    `"$script`" -> `"$dependency`";`n"
        }
    }
    
    $dotContent += "}`n"
    return $dotContent
}

# Export functions
Export-ModuleMember -Function New-DependencyGraph, Get-ScriptDependencies, Test-CircularDependencies, ConvertTo-DependencyGraphDot 