# 21-ConfigureDevEnvironment.ps1 - Phase 1 Infrastructure Enhancement
# Configures VS Code workspace settings and development tooling for optimal DX
# ARCHITECTURE: Development environment optimization with extension recommendations
# Reference: script_checklist.md lines 21-ConfigureDevEnvironment.ps1
# Reference: build_design.md lines 2360-2400 - Development environment configuration
#Requires -Version 5.1

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $false)]
    [string]$ProjectRoot = (Split-Path $PSScriptRoot -Parent)
)

try {
    Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop
}
catch {
    Write-Error "Failed to import utilities module: $($_.Exception.Message)"
    exit 1
}

$ErrorActionPreference = "Stop"

try {
    Write-StepHeader "Development Environment Configuration - Phase 1 Infrastructure Enhancement"
    Write-InfoLog "Configuring VS Code workspace and development tooling"

    # Define paths
    $vscodeDir = Join-Path $ProjectRoot ".vscode"
    $settingsPath = Join-Path $vscodeDir "settings.json"
    $extensionsPath = Join-Path $vscodeDir "extensions.json"
    $launchPath = Join-Path $vscodeDir "launch.json"
    $tasksPath = Join-Path $vscodeDir "tasks.json"
    $prettierConfigPath = Join-Path $ProjectRoot ".prettierrc.json"
    $editorConfigPath = Join-Path $ProjectRoot ".editorconfig"

    # Create .vscode directory
    New-Item -Path $vscodeDir -ItemType Directory -Force | Out-Null
    Write-InfoLog "Created .vscode directory"

    # Generate VS Code workspace settings
    Write-InfoLog "Generating VS Code workspace settings"
    $vscodeSettings = @{
        # TypeScript settings
        "typescript.preferences.includePackageJsonAutoImports" = "auto"
        "typescript.suggest.autoImports" = $true
        "typescript.updateImportsOnFileMove.enabled" = "always"
        "typescript.preferences.importModuleSpecifier" = "relative"

        # Editor settings for code quality
        "editor.formatOnSave" = $true
        "editor.formatOnPaste" = $true
        "editor.codeActionsOnSave" = @{
            "source.fixAll.eslint" = $true
            "source.organizeImports" = $true
        }
        "editor.defaultFormatter" = "esbenp.prettier-vscode"
        "editor.tabSize" = 2
        "editor.insertSpaces" = $true
        "editor.detectIndentation" = $false

        # File associations
        "files.associations" = @{
            "*.tsx" = "typescriptreact"
            "*.ts" = "typescript"
        }

        # Search and file explorer
        "search.exclude" = @{
            "**/node_modules" = $true
            "**/dist" = $true
            "**/build" = $true
            "**/.git" = $true
        }
        "files.exclude" = @{
            "**/.git" = $true
            "**/.svn" = $true
            "**/.hg" = $true
            "**/CVS" = $true
            "**/.DS_Store" = $true
            "**/node_modules" = $true
            "**/dist" = $true
            "**/build" = $true
        }

        # ESLint settings
        "eslint.workingDirectories" = @(".")
        "eslint.validate" = @("typescript", "typescriptreact")

        # Prettier settings
        "prettier.requireConfig" = $true
        "prettier.useEditorConfig" = $true

        # Error Lens settings for inline error display
        "errorLens.enabledDiagnosticLevels" = @("error", "warning", "info")
        "errorLens.excludeBySource" = @("cSpell")

        # GitLens settings
        "gitlens.codeLens.enabled" = $true
        "gitlens.currentLine.enabled" = $true
        "gitlens.hovers.enabled" = $true

        # Auto Rename Tag settings
        "auto-rename-tag.activationOnLanguage" = @("*")

        # Bracket pair colorizer settings
        "editor.bracketPairColorization.enabled" = $true
        "editor.guides.bracketPairs" = $true
    }

    $vscodeSettingsJson = $vscodeSettings | ConvertTo-Json -Depth 10
    Set-Content -Path $settingsPath -Value $vscodeSettingsJson -Encoding UTF8
    Write-SuccessLog "VS Code workspace settings configured"

    # Generate recommended extensions
    Write-InfoLog "Generating recommended VS Code extensions"
    $extensions = @{
        recommendations = @(
            # Essential TypeScript and JavaScript
            "ms-vscode.vscode-typescript-next"
            "bradlc.vscode-tailwindcss"
            "esbenp.prettier-vscode"
            "dbaeumer.vscode-eslint"

            # TypeScript Hero for import management
            "rbbit.typescript-hero"

            # Error Lens for inline error display
            "usernamehw.errorlens"

            # GitLens for Git integration
            "eamodio.gitlens"

            # Auto Rename Tag for JSX consistency
            "formulahendry.auto-rename-tag"

            # Additional productivity extensions
            "ms-vscode.vscode-json"
            "redhat.vscode-yaml"
            "ms-vscode.powershell"
            "ms-vscode.vscode-markdown"

            # THREE.js and WebGL support
            "slevesque.shader"
            "dtoplak.vscode-glsllint"

            # Testing support
            "vitest.explorer"

            # Docker support for deployment
            "ms-azuretools.vscode-docker"
        )

        unwantedRecommendations = @(
            # Extensions that might conflict with our setup
            "ms-vscode.vscode-typescript"
            "hookyqr.beautify"
        )
    }

    $extensionsJson = $extensions | ConvertTo-Json -Depth 10
    Set-Content -Path $extensionsPath -Value $extensionsJson -Encoding UTF8
    Write-SuccessLog "VS Code extensions recommendations configured"

    # Generate Prettier configuration
    Write-InfoLog "Generating Prettier configuration"
    $prettierConfig = @{
        semi = $false
        singleQuote = $true
        trailingComma = "es5"
        tabWidth = 2
        useTabs = $false
        printWidth = 100
        bracketSpacing = $true
        bracketSameLine = $false
        arrowParens = "avoid"
        endOfLine = "lf"
        quoteProps = "as-needed"
        jsxSingleQuote = $true
        jsxBracketSameLine = $false
    }

    $prettierConfigJson = $prettierConfig | ConvertTo-Json -Depth 10
    Set-Content -Path $prettierConfigPath -Value $prettierConfigJson -Encoding UTF8
    Write-SuccessLog "Prettier configuration created"

    # Generate EditorConfig for cross-editor consistency
    Write-InfoLog "Generating EditorConfig for cross-editor consistency"
    $editorConfig = @"
# EditorConfig is awesome: https://EditorConfig.org

# top-most EditorConfig file
root = true

# All files
[*]
indent_style = space
indent_size = 2
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true

# TypeScript and JavaScript files
[*.{ts,tsx,js,jsx}]
indent_size = 2
max_line_length = 100

# JSON files
[*.json]
indent_size = 2

# Markdown files
[*.md]
trim_trailing_whitespace = false
max_line_length = off

# PowerShell files
[*.ps1]
indent_size = 4

# YAML files
[*.{yml,yaml}]
indent_size = 2

# HTML files
[*.html]
indent_size = 2

# CSS files
[*.{css,scss,sass}]
indent_size = 2
"@

    Set-Content -Path $editorConfigPath -Value $editorConfig -Encoding UTF8
    Write-SuccessLog "EditorConfig created for cross-editor consistency"

    # Generate VS Code tasks configuration
    Write-InfoLog "Generating VS Code tasks configuration"
    $tasks = @{
        version = "2.0.0"
        tasks = @(
            @{
                label = "TypeScript: Check"
                type = "typescript"
                tsconfig = "tsconfig.json"
                option = "watch"
                problemMatcher = "`$tsc-watch"
                group = "build"
            }
            @{
                label = "ESLint: Fix All"
                type = "shell"
                command = "npm"
                args = @("run", "lint:fix")
                group = "build"
                presentation = @{
                    echo = $true
                    reveal = "always"
                    panel = "new"
                }
            }
            @{
                label = "Domain Validation"
                type = "shell"
                command = "pwsh"
                args = @("-File", "./scripts/05-VerifyCompliance.ps1")
                group = "test"
                presentation = @{
                    echo = $true
                    reveal = "always"
                    panel = "new"
                }
            }
        )
    }

    $tasksJson = $tasks | ConvertTo-Json -Depth 10
    Set-Content -Path $tasksPath -Value $tasksJson -Encoding UTF8
    Write-SuccessLog "VS Code tasks configuration created"

    # Generate VS Code launch configuration for debugging
    Write-InfoLog "Generating VS Code launch configuration for debugging"
    $launch = @{
        version = "0.2.0"
        configurations = @(
            @{
                name = "Launch Development Server"
                type = "node"
                request = "launch"
                program = "`${workspaceFolder}/node_modules/.bin/vite"
                args = @("--host", "--port", "3000")
                console = "integratedTerminal"
                envFile = "`${workspaceFolder}/.env"
                cwd = "`${workspaceFolder}"
                skipFiles = @(
                    "<node_internals>/**"
                    "node_modules/**"
                )
            }
            @{
                name = "Debug in Chrome"
                type = "chrome"
                request = "launch"
                url = "http://localhost:3000"
                webRoot = "`${workspaceFolder}/src"
                sourceMapPathOverrides = @{
                    "webpack:///src/*" = "`${webRoot}/*"
                    "webpack:///./*" = "`${workspaceFolder}/*"
                    "webpack:///./~/*" = "`${workspaceFolder}/node_modules/*"
                }
                userDataDir = $false
                runtimeExecutable = ""
            }
            @{
                name = "Debug Bitcoin Service"
                type = "node"
                request = "launch"
                program = "`${workspaceFolder}/src/domains/bitcoin/services/bitcoinService.ts"
                args = @()
                console = "integratedTerminal"
                envFile = "`${workspaceFolder}/.env"
                cwd = "`${workspaceFolder}"
                env = @{
                    NODE_ENV = "development"
                    LOG_LEVEL = "debug"
                }
                skipFiles = @(
                    "<node_internals>/**"
                    "node_modules/**"
                )
                sourceMaps = $true
                outFiles = @(
                    "`${workspaceFolder}/dist/**/*.js"
                )
            }
            @{
                name = "Debug Physics Worker"
                type = "node"
                request = "launch"
                program = "`${workspaceFolder}/src/domains/physics/workers/physicsWorker.js"
                args = @()
                console = "integratedTerminal"
                envFile = "`${workspaceFolder}/.env"
                cwd = "`${workspaceFolder}"
                env = @{
                    NODE_ENV = "development"
                    LOG_LEVEL = "debug"
                }
                skipFiles = @(
                    "<node_internals>/**"
                    "node_modules/**"
                )
            }
            @{
                name = "Run Domain Validation Tests"
                type = "node"
                request = "launch"
                program = "`${workspaceFolder}/node_modules/.bin/vitest"
                args = @("run", "--reporter=verbose")
                console = "integratedTerminal"
                envFile = "`${workspaceFolder}/.env"
                cwd = "`${workspaceFolder}"
                env = @{
                    NODE_ENV = "test"
                }
                skipFiles = @(
                    "<node_internals>/**"
                    "node_modules/**"
                )
            }
            @{
                name = "Attach to Development Server"
                type = "node"
                request = "attach"
                port = 9229
                localRoot = "`${workspaceFolder}"
                remoteRoot = "`${workspaceFolder}"
                skipFiles = @(
                    "<node_internals>/**"
                    "node_modules/**"
                )
            }
        )
        compounds = @(
            @{
                name = "Launch Full Stack Debug"
                configurations = @(
                    "Launch Development Server"
                    "Debug in Chrome"
                )
                stopAll = $true
                preLaunchTask = "TypeScript: Check"
            }
        )
    }

    $launchJson = $launch | ConvertTo-Json -Depth 10
    Set-Content -Path $launchPath -Value $launchJson -Encoding UTF8
    Write-SuccessLog "VS Code launch configuration created for debugging"

    Write-InfoLog "Development environment configuration completed"

    exit 0
}
catch {
    Write-ErrorLog "Development environment configuration failed: $($_.Exception.Message)"
    exit 1
}
finally {
    try { Pop-Location -ErrorAction SilentlyContinue } catch { }
}