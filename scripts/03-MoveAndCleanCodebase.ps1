# 03-MoveAndCleanCodebase.ps1
# Moves test files out of src, removes legacy/duplicate files, and updates import references
# Referenced from build_design.md Section 11 - "Automation Script – Codebase Restructure"

Import-Module "$PSScriptRoot\utils.psm1" -Force

Write-StepHeader "Codebase Migration and Cleanup"

# Step 1: Remove backup and legacy files
Write-InfoLog "Removing backup and legacy files..."
$backupPatterns = @("*.bak", "*.backup", "*.old", "*.temp", "*~", "*.orig")
foreach ($pattern in $backupPatterns) {
    Get-ChildItem -Path . -Filter $pattern -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
        Write-WarningLog "Removing backup file: $($_.FullName)"
        Remove-Item $_.FullName -Force
    }
}

# Remove debug and scratch files
$debugPatterns = @("debug-*", "temp-*", "scratch-*", "test-*")
foreach ($pattern in $debugPatterns) {
    Get-ChildItem -Path . -Filter $pattern -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
        if ($_.PSIsContainer -or $_.Extension -in @('.js', '.ts', '.html', '.md')) {
            Write-WarningLog "Removing debug file: $($_.FullName)"
            Remove-Item $_.FullName -Force -Recurse
        }
    }
}

# Step 2: Move test files from src to tests directory
Write-InfoLog "Moving test files out of src directory..."
if (Test-Path "src") {
    # Find all test files in src (files with "test" in name or .test.* extensions)
    $testFiles = Get-ChildItem -Path "src" -Recurse | Where-Object {
        $_.Name -match "test" -or 
        $_.Name -match "\.test\." -or 
        $_.Name -match "\.spec\." -or
        $_.Name -match "_test\." -or
        $_.Name -match "-test\."
    }
    
    foreach ($testFile in $testFiles) {
        # Calculate relative path from src
        $relativePath = $testFile.FullName.Substring((Resolve-Path "src").Path.Length + 1)
        $targetPath = Join-Path "tests" $relativePath
        $targetDir = Split-Path $targetPath -Parent
        
        # Create target directory if it doesn't exist
        if (!(Test-Path $targetDir)) {
            New-Item -Path $targetDir -ItemType Directory -Force | Out-Null
        }
        
        Write-InfoLog "Moving test file: $($testFile.Name) -> tests/$relativePath"
        Move-Item $testFile.FullName $targetPath -Force
    }
}

# Step 3: Remove specific duplicate or obsolete files identified in audit
Write-InfoLog "Removing duplicate and obsolete files..."

# Remove duplicate manager files in rendering domain
$duplicateFiles = @(
    "src/domains/rendering/services/effectManager.ts",
    "src/domains/rendering/services/renderingEffectManager.ts",
    "src/domains/rendering/services/renderingPatrolManager.ts",
    "src/domains/rendering/services/renderingServiceCore.ts"
)

foreach ($file in $duplicateFiles) {
    if (Test-Path $file) {
        Write-WarningLog "Removing duplicate file: $file"
        Remove-Item $file -Force
    }
}

# Remove PowerShell scripts from domain directories (they should be in scripts/)
Get-ChildItem -Path "src" -Filter "*.ps1" -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
    Write-WarningLog "Removing PowerShell script from src: $($_.FullName)"
    Remove-Item $_.FullName -Force
}

# Step 4: Remove oversize files (>500 lines) and log for manual review
Write-InfoLog "Checking for oversize files (>500 lines)..."
$oversizeFiles = @()
Get-ChildItem -Path "src" -Include "*.ts", "*.tsx" -Recurse | ForEach-Object {
    $lineCount = Get-FileLineCount $_.FullName
    if ($lineCount -gt 500) {
        $fileInfo = New-Object PSObject -Property @{
            Path = $_.FullName
            Lines = $lineCount
        }
        $oversizeFiles += $fileInfo
        Write-WarningLog "Oversize file detected ($lineCount lines): $($_.FullName)"
    }
}

if ($oversizeFiles.Count -gt 0) {
    Write-WarningLog "Found $($oversizeFiles.Count) oversize files - manual review required"
    # Create a report file for manual review
    $reportContent = "# Oversize Files Report`n`nThe following files exceed 500 lines and need manual refactoring:`n`n"
    foreach ($file in $oversizeFiles) {
        $reportContent += "- $($file.Path) ($($file.Lines) lines)`n"
    }
    Set-Content -Path "OVERSIZE_FILES_REPORT.md" -Value $reportContent
    Write-InfoLog "Created OVERSIZE_FILES_REPORT.md for manual review"
}

# Step 5: Update import paths to use new path aliases
Write-InfoLog "Updating import paths in TypeScript files..."
$importFixes = 0
Get-ChildItem -Path "src" -Include "*.ts", "*.tsx" -Recurse | ForEach-Object {
    $filePath = $_.FullName
    $content = Get-Content $filePath -Raw
    $originalContent = $content
    
    # Fix relative imports to use path aliases - escape regex properly for PowerShell
    $content = $content -replace "from\s+[""'](\.\./)+domains/([a-zA-Z]+)/", "from '@/domains/`$2/"
    $content = $content -replace "from\s+[""'](\.\./)+shared/", "from '@/shared/"
    $content = $content -replace "from\s+[""'](\.\./)+components/", "from '@/components/"
    
    # Fix old import patterns that reference src/ directly
    $content = $content -replace "from\s+[""']src/domains/([a-zA-Z]+)/", "from '@/domains/`$1/"
    $content = $content -replace "from\s+[""']src/shared/", "from '@/shared/"
    $content = $content -replace "from\s+[""']src/components/", "from '@/components/"
    
    if ($content -ne $originalContent) {
        Set-Content $filePath $content -NoNewline
        $importFixes++
        Write-InfoLog "Updated imports in: $($_.Name)"
    }
}

if ($importFixes -gt 0) {
    Write-SuccessLog "Updated imports in $importFixes files"
}

# Step 6: Clean up empty directories
Write-InfoLog "Removing empty directories..."
do {
    $emptyDirs = Get-ChildItem -Path "src" -Recurse -Directory | Where-Object {
        $_.GetFileSystemInfos().Count -eq 0
    }
    foreach ($dir in $emptyDirs) {
        Write-InfoLog "Removing empty directory: $($dir.FullName)"
        Remove-Item $dir.FullName -Force
    }
} while ($emptyDirs.Count -gt 0)

# Step 7: Verify directory structure compliance
Write-InfoLog "Verifying post-cleanup directory structure..."
$requiredPaths = @(
    'src/domains',
    'src/shared',
    'tests'
)

$structureValid = $true
foreach ($path in $requiredPaths) {
    if (!(Test-Path $path)) {
        Write-ErrorLog "Required path missing after cleanup: $path"
        $structureValid = $false
    }
}

# Verify no test files remain in src
$remainingTests = Get-ChildItem -Path "src" -Recurse | Where-Object {
    $_.Name -match "test" -or $_.Name -match "\.test\." -or $_.Name -match "\.spec\."
}

if ($remainingTests.Count -gt 0) {
    Write-ErrorLog "Test files still found in src after cleanup:"
    $remainingTests | ForEach-Object { Write-ErrorLog "  - $($_.FullName)" }
    $structureValid = $false
}

if ($structureValid) {
    Write-SuccessLog "Directory structure validation passed"
} else {
    Write-ErrorLog "Directory structure validation failed"
    exit 1
}

# Generate cleanup summary
Write-InfoLog "Cleanup Summary:"
Write-InfoLog "  - Backup files removed: $(($backupPatterns | ForEach-Object { (Get-ChildItem -Filter $_ -Recurse -ErrorAction SilentlyContinue).Count } | Measure-Object -Sum).Sum)"
Write-InfoLog "  - Test files moved to tests/: $($testFiles.Count)"
Write-InfoLog "  - Import paths updated: $importFixes files"
Write-InfoLog "  - Oversize files found: $($oversizeFiles.Count)"

Write-SuccessLog "Codebase migration and cleanup complete!"
Write-InfoLog "Next: Run 04-EnforceSingletonPatterns.ps1 to standardize service patterns" 