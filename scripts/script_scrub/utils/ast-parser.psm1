# ast-parser.psm1
# PowerShell Abstract Syntax Tree parsing utilities for script analysis
# Used by script scrub analysis suite to extract code structure and patterns

#Requires -Version 5.1

using namespace System.Management.Automation.Language

# Import required assemblies for AST parsing
Add-Type -AssemblyName System.Management.Automation

<#
.SYNOPSIS
    Parses a PowerShell script file into an Abstract Syntax Tree
.PARAMETER ScriptPath
    Path to the PowerShell script file to parse
.RETURNS
    ScriptBlockAst object representing the parsed script
#>
function Get-ScriptAst {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ScriptPath
    )
    
    if (-not (Test-Path $ScriptPath)) {
        throw "Script file not found: $ScriptPath"
    }
    
    try {
        $scriptContent = Get-Content -Path $ScriptPath -Raw
        $tokens = $null
        $parseErrors = $null
        
        $ast = [Parser]::ParseInput($scriptContent, [ref]$tokens, [ref]$parseErrors)
        
        if ($parseErrors.Count -gt 0) {
            Write-Warning "Parse errors found in $ScriptPath"
            foreach ($error in $parseErrors) {
                Write-Warning "  Line $($error.Extent.StartLineNumber): $($error.Message)"
            }
        }
        
        return @{
            Ast = $ast
            Tokens = $tokens
            ParseErrors = $parseErrors
            FilePath = $ScriptPath
        }
    }
    catch {
        throw "Failed to parse script $ScriptPath : $($_.Exception.Message)"
    }
}

<#
.SYNOPSIS  
    Extracts all function definitions from a script AST
.PARAMETER ParsedScript
    Result from Get-ScriptAst containing the AST
.RETURNS
    Array of function definition objects with name, parameters, and location
#>
function Get-FunctionDefinitions {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$ParsedScript
    )
    
    $functions = @()
    $functionAsts = $ParsedScript.Ast.FindAll({
        param($node)
        $node -is [FunctionDefinitionAst]
    }, $true)
    
    foreach ($funcAst in $functionAsts) {
        $functions += @{
            Name = $funcAst.Name
            Parameters = $funcAst.Parameters | ForEach-Object { $_.Name.VariablePath.UserPath }
            StartLine = $funcAst.Extent.StartLineNumber
            EndLine = $funcAst.Extent.EndLineNumber
            FilePath = $ParsedScript.FilePath
            Body = $funcAst.Body.Extent.Text
            IsAdvancedFunction = ($null -ne $funcAst.Body.ParamBlock)
        }
    }
    
    return $functions
}

<#
.SYNOPSIS
    Extracts all function calls from a script AST
.PARAMETER ParsedScript
    Result from Get-ScriptAst containing the AST
.RETURNS
    Array of function call objects with name, parameters, and location
#>
function Get-FunctionCalls {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$ParsedScript
    )
    
    $calls = @()
    $commandAsts = $ParsedScript.Ast.FindAll({
        param($node)
        $node -is [CommandAst]
    }, $true)
    
    foreach ($cmdAst in $commandAsts) {
        if ($cmdAst.GetCommandName()) {
            $calls += @{
                CommandName = $cmdAst.GetCommandName()
                Parameters = $cmdAst.CommandElements | Select-Object -Skip 1 | ForEach-Object { $_.Extent.Text }
                StartLine = $cmdAst.Extent.StartLineNumber
                FilePath = $ParsedScript.FilePath
            }
        }
    }
    
    return $calls
}

<#
.SYNOPSIS
    Extracts import statements and module dependencies
.PARAMETER ParsedScript
    Result from Get-ScriptAst containing the AST
.RETURNS
    Array of import/dependency objects
#>
function Get-ImportStatements {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$ParsedScript
    )
    
    $imports = @()
    $commandAsts = $ParsedScript.Ast.FindAll({
        param($node)
        $node -is [CommandAst] -and 
        ($node.GetCommandName() -in @('Import-Module', 'using'))
    }, $true)
    
    foreach ($cmdAst in $commandAsts) {
        $commandName = $cmdAst.GetCommandName()
        $modulePath = $null
        
        if ($commandName -eq 'Import-Module' -and $cmdAst.CommandElements.Count -gt 1) {
            $modulePath = $cmdAst.CommandElements[1].Extent.Text -replace "[`"']", ''
        }
        
        $imports += @{
            Type = $commandName
            ModulePath = $modulePath
            StartLine = $cmdAst.Extent.StartLineNumber
            FilePath = $ParsedScript.FilePath
            FullText = $cmdAst.Extent.Text
        }
    }
    
    return $imports
}
