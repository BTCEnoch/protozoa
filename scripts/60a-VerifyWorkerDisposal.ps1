# 60a-VerifyWorkerDisposal.ps1
# AST scan to verify worker.terminate() is called in every dispose() method
# Ensures proper cleanup of WebWorker resources to prevent memory leaks
# Usage: Executed by automation suite for compliance verification

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $false)]
    [string]$ProjectRoot = (Split-Path $PSScriptRoot -Parent),

    [Parameter(Mandatory = $false)]
    [switch]$DryRun,

    [Parameter(Mandatory = $false)]
    [switch]$FixViolations
)

$ErrorActionPreference = "Stop"

try {
    Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop
} catch {
    Write-Error "Failed to import utils module: $($_.Exception.Message)"
    exit 1
}

try {
    Write-StepHeader "Verify Worker Disposal Compliance (60)"
    Write-InfoLog "Scanning TypeScript files for proper worker disposal patterns"

    # Find all TypeScript service files
    $serviceFiles = @()
    $searchPaths = @(
        "src/domains/*/services/*.ts",
        "src/shared/services/*.ts",
        "src/shared/workers/*.ts",
        "src/shared/memory/*.ts"
    )

    foreach ($pattern in $searchPaths) {
        $fullPattern = Join-Path $ProjectRoot $pattern
        $files = Get-ChildItem -Path $fullPattern -ErrorAction SilentlyContinue
        $serviceFiles += $files
    }

    Write-InfoLog "Found $($serviceFiles.Count) service files to analyze"

    # Results tracking
    $violations = @()
    $compliantFiles = @()
    $workerFiles = @()

    foreach ($file in $serviceFiles) {
        Write-DebugLog "Analyzing file: $($file.Name)"
        
        $content = Get-Content $file.FullName -Raw
        
        # Check if file contains worker-related code
        $hasWorkerCode = $content -match "new Worker\(" -or 
                        $content -match "Worker.*=" -or 
                        $content -match "WorkerManager" -or
                        $content -match "\.spawn\(" -or
                        $content -match "worker\s*:" -or
                        $content -match "workers\s*:"

        if ($hasWorkerCode) {
            $workerFiles += $file
            Write-InfoLog "Worker-related code detected in: $($file.Name)"

            # Check for dispose method
            $hasDispose = $content -match "dispose\s*\(\s*\)\s*[:{]"
            
            if ($hasDispose) {
                # Extract dispose method content
                $disposeMatches = [regex]::Matches($content, "dispose\s*\(\s*\)\s*[:{].*?(?=\n\s*\w+\s*\(|$)", [System.Text.RegularExpressions.RegexOptions]::Singleline)
                
                $hasTerminate = $false
                foreach ($match in $disposeMatches) {
                    $disposeContent = $match.Value
                    
                    # Check for worker termination patterns
                    if ($disposeContent -match "\.terminate\(" -or 
                        $disposeContent -match "\.dispose\(" -or 
                        $disposeContent -match "WorkerManager.*dispose" -or
                        $disposeContent -match "workerManager\.dispose") {
                        $hasTerminate = $true
                        break
                    }
                }

                if (-not $hasTerminate) {
                    $violation = @{
                        File = $file.FullName
                        Issue = "dispose() method exists but does not terminate workers"
                        Severity = "High"
                        Pattern = "Missing worker.terminate() or workerManager.dispose() call"
                    }
                    $violations += $violation
                    Write-WarningLog "VIOLATION: $($file.Name) - dispose() method does not terminate workers"
                } else {
                    $compliantFiles += $file
                    Write-SuccessLog "COMPLIANT: $($file.Name) - proper worker disposal found"
                }
            } else {
                $violation = @{
                    File = $file.FullName
                    Issue = "Worker code present but no dispose() method found"
                    Severity = "Critical"
                    Pattern = "Missing dispose() method entirely"
                }
                $violations += $violation
                Write-ErrorLog "VIOLATION: $($file.Name) - worker code present but no dispose() method"
            }
        }
    }

    # Generate compliance report
    $reportPath = Join-Path $ProjectRoot "worker-disposal-compliance.json"
    $report = @{
        timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        totalFiles = $serviceFiles.Count
        workerFiles = $workerFiles.Count
        compliantFiles = $compliantFiles.Count
        violations = $violations.Count
        details = @{
            compliant = $compliantFiles | ForEach-Object { @{ file = $_.Name; path = $_.FullName } }
            violations = $violations
        }
        recommendations = @(
            "All services with worker code MUST implement dispose() method",
            "dispose() method MUST call worker.terminate() or workerManager.dispose()",
            "Use WorkerManager for centralized worker lifecycle management",
            "Implement proper error handling in disposal methods"
        )
    }

    if (-not $DryRun) {
        $report | ConvertTo-Json -Depth 10 | Set-Content -Path $reportPath -Encoding UTF8
    }
    Write-InfoLog "Compliance report generated: worker-disposal-compliance.json"

    # Fix violations if requested
    if ($FixViolations -and $violations.Count -gt 0) {
        Write-InfoLog "Attempting to fix worker disposal violations..."
        
        foreach ($violation in $violations) {
            $file = Get-Item $violation.File
            $content = Get-Content $file.FullName -Raw
            
            if ($violation.Issue -match "Missing dispose") {
                # Add dispose method to class
                $disposeMethod = @"

  /**
   * Dispose of all resources and cleanup workers
   * @generated 60-VerifyWorkerDisposal.ps1
   */
  dispose(): void {
    // Terminate all workers
    if (this.workerManager) {
      this.workerManager.dispose()
    }
    
    // Cleanup any individual workers
    Object.values(this).forEach(value => {
      if (value && typeof value.terminate === 'function') {
        value.terminate()
      }
    })
    
    logger.info('$(file.BaseName) disposed successfully')
  }
"@
                
                # Insert before closing class brace
                $fixedContent = $content -replace "(\n\s*}\s*$)", "$disposeMethod`n}"
                
                if (-not $DryRun) {
                    Set-Content -Path $file.FullName -Value $fixedContent -Encoding UTF8
                }
                Write-SuccessLog "FIXED: Added dispose() method to $($file.Name)"
            }
            elseif ($violation.Issue -match "does not terminate") {
                # Add worker termination to existing dispose method
                $terminationCode = @"

    // Terminate workers - added by 60-VerifyWorkerDisposal.ps1
    if (this.workerManager) {
      this.workerManager.dispose()
    }
    
    // Terminate individual workers
    Object.values(this).forEach(value => {
      if (value && typeof value.terminate === 'function') {
        value.terminate()
      }
    })
"@
                
                # Insert termination code in dispose method
                $fixedContent = $content -replace "(dispose\s*\(\s*\)\s*[:{]\s*)", "`$1$terminationCode"
                
                if (-not $DryRun) {
                    Set-Content -Path $file.FullName -Value $fixedContent -Encoding UTF8
                }
                Write-SuccessLog "FIXED: Added worker termination to dispose() in $($file.Name)"
            }
        }
    }

    # Summary
    Write-InfoLog " "
    Write-InfoLog "=== WORKER DISPOSAL COMPLIANCE SUMMARY ==="
    Write-InfoLog "Total files analyzed: $($serviceFiles.Count)"
    Write-InfoLog "Files with worker code: $($workerFiles.Count)"
    Write-InfoLog "Compliant files: $($compliantFiles.Count)"
    Write-InfoLog "Violation count: $($violations.Count)"

    if ($violations.Count -gt 0) {
        Write-ErrorLog " "
        Write-ErrorLog "COMPLIANCE VIOLATIONS DETECTED:"
        foreach ($violation in $violations) {
            Write-ErrorLog "- $($violation.Issue) in $(Split-Path $violation.File -Leaf)"
        }
        
        if (-not $FixViolations) {
            Write-WarningLog "Run with -FixViolations to automatically fix these issues"
        }
        
        exit 1
    } else {
        Write-SuccessLog " "
        Write-SuccessLog "[SUCCESS] ALL WORKER DISPOSAL COMPLIANCE CHECKS PASSED"
        Write-SuccessLog "Worker disposal verification completed successfully"
    }
    
    exit 0

} catch {
    Write-ErrorLog "Worker disposal verification failed: $($_.Exception.Message)"
    exit 1
} 