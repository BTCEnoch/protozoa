# Automation Scripts

The `scripts` folder contains PowerShell utilities used to scaffold and maintain the project. Key scripts include:

| Script | Purpose |
|-------|---------|
| `00-InitEnvironment.ps1` | install Node and dependencies |
| `01-ScaffoldProjectStructure.ps1` | create domain folders and tests |
| `02-GenerateDomainStubs.ps1` | generate TypeScript service stubs |
| `03-MoveAndCleanCodebase.ps1` | move legacy files and fix imports |
| `04-EnforceSingletonPatterns.ps1` | ensure all services use the singleton pattern |
| `05-VerifyCompliance.ps1` | check file sizes and domain boundaries |
| `06-DomainLint.ps1` | run ESLint per domain and detect cross imports |
| `07-BuildAndTest.ps1` | compile and run tests |
| `08-DeployToGitHub.ps1` | deployment automation |
| `runAll.ps1` | orchestrates the entire sequence |

Each script logs its progress to `automation.log` and exits with non‑zero status on failure.
