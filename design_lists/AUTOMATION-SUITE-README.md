# 🤖 Protozoa Automation Suite

## Overview

This is a **clean automation infrastructure package** that contains only the essential scripts, templates, and configuration needed to build and deploy the complete Protozoa Bitcoin Ordinals Digital Organism Ecosystem from scratch.

The automation suite implements an **8-phase pipeline** that generates ~600KB of production-ready TypeScript code, complete with:

- Domain-driven architecture with singleton services
- Bitcoin Ordinals Protocol integration
- THREE.js particle physics engine
- Comprehensive Winston logging
- Performance optimization for 60fps targets
- Enterprise-grade testing and CI/CD

## 📦 What's Included

### Essential Automation Infrastructure

```
📁 scripts/                    # 57 PowerShell automation scripts
  ├── 00-InitEnvironment.ps1   # Environment setup & dependencies
  ├── 01-31: Core Generation   # Project structure & services
  ├── 32-44: Domain Enhancement # Advanced features
  ├── 45-60: CI/CD & Testing   # Deployment, validation & browser setup
  ├── runAll.ps1              # Master orchestrator
  └── utils.psm1              # Shared utilities (1000+ lines)

📁 docs/                      # Complete technical documentation
  ├── overview/               # Architecture & MVP specs
  ├── domains/               # Domain-specific documentation
  └── design_lists/          # Build checklists & diagnostics

📁 templates/                 # Code generation templates
  ├── components/            # React component templates
  ├── domains/              # Service & interface templates
  ├── docker/              # Deployment templates
  └── .github/             # CI/CD workflow templates

📄 package.json             # Node.js dependencies
📄 environment-dependencies.json # Package updates config
```

### What Gets Generated (After Running Scripts)

The automation suite will generate a complete application with:

- **~30,000 lines** of TypeScript/React code
- **8 domain services** (RNG, Physics, Bitcoin, Particle, etc.)
- **Winston logging** system with multiple levels
- **Comprehensive test suite** with 80%+ coverage
- **Docker deployment** configuration
- **GitHub Actions** CI/CD pipelines
- **Performance benchmarking** tools

## 🚀 Quick Start

### Prerequisites

- **PowerShell 5.1+** (Windows) or **PowerShell Core 7+** (cross-platform)
- **Node.js 18+** and **npm/pnpm**
- **Git** for version control
- **Docker** (optional, for containerized deployment)

### Run the Complete Automation

```powershell
# Clone/extract the automation suite
cd protozoa-automation-suite

# Preview what will be generated (safe dry-run)
pwsh scripts/runAll.ps1 -WhatIf

# Execute the complete 8-phase pipeline
pwsh scripts/runAll.ps1
```

### Manual Phase Execution

```powershell
# Phase 0: Environment Setup
pwsh scripts/00-InitEnvironment.ps1
pwsh scripts/01-ScaffoldProjectStructure.ps1

# Phase 1: Core Services
pwsh scripts/23-GenerateRNGService.ps1
pwsh scripts/24-GeneratePhysicsService.ps1
pwsh scripts/26-GenerateBitcoinService.ps1

# See docs/design_lists/build_checklist.md for complete sequence
```

## 🏗️ Architecture Generated

### Domain-Driven Structure

```
src/
├── domains/                 # 8 core domains
│   ├── rng/                # Random number generation
│   ├── physics/            # Particle physics engine
│   ├── bitcoin/            # Bitcoin Ordinals integration
│   ├── particle/           # Particle type definitions
│   ├── rendering/          # THREE.js rendering
│   ├── animation/          # Particle animations
│   ├── formation/          # Particle formations
│   └── trait/             # Organism traits
├── components/             # React UI components
└── shared/                # Cross-domain utilities
```

### Service Architecture (Class-Based Excellence)

Each domain implements:

- **Singleton Services** with dependency injection
- **Interface Contracts** for testability
- **Winston Logging** throughout all methods
- **Error Handling** with retry logic
- **Performance Optimization** for 60fps targets

## 🔗 Bitcoin Ordinals Integration

The generated application integrates with Bitcoin Ordinals Protocol:

### API Endpoints

- **Dev**: `https://ordinals.com/r/blockinfo/{blockNumber}`
- **Production**: `/r/blockinfo/{blockNumber}`
- **Inscriptions**: `https://ordinals.com/content/{inscription_id}`

### Key Features Generated

- Block data parsing for organism trait generation
- Inscription content retrieval and validation
- Caching layer for blockchain data
- Error handling with retry logic
- Rate limiting for API compliance

## 📊 Performance Targets

The automation generates code optimized for:

- **60fps rendering** for particle systems
- **<3 second** initial page load
- **<200MB** memory usage for core application
- **Bundle size <2MB** initial load
- **80%+ test coverage** across all domains

## 🧪 Quality Assurance Generated

### Testing Infrastructure

- **Unit tests** for all service methods
- **Integration tests** for service interactions
- **E2E tests** for complete workflows
- **Performance benchmarks** for critical algorithms
- **Visual regression tests** for UI components

### Development Tools

- **ESLint** configuration with strict rules
- **TypeScript** with advanced type checking
- **Pre-commit hooks** for code validation
- **VS Code** configuration with recommended extensions
- **Docker** multi-stage builds for deployment

## 🔧 Customization

### Modifying the Generation Process

1. **Edit templates** in `/templates/` directory
2. **Modify scripts** in `/scripts/` directory
3. **Update configuration** in `package.json` or `environment-dependencies.json`
4. **Re-run specific phases** or complete pipeline

### Adding New Domains

1. Create templates in `/templates/domains/your-domain/`
2. Add generation script following naming pattern `XX-GenerateYourDomain.ps1`
3. Update `runAll.ps1` sequence
4. Add documentation in `/docs/domains/your-domain.md`

## 🛡️ Enterprise Features Generated

### Security

- Input validation and sanitization
- API rate limiting and error handling
- Secure Bitcoin API integration
- HTTPS enforcement in production

### Monitoring & Observability

- Winston logging with multiple levels
- Performance metrics collection
- Error tracking and alerting
- Health check endpoints

### Scalability

- Modular domain architecture
- Service-based dependency injection
- Efficient memory management
- Code splitting and lazy loading

## 📚 Documentation Structure

- **`/docs/overview/`** - High-level architecture and MVP
- **`/docs/domains/`** - Domain-specific implementation details
- **`/docs/design_lists/`** - Build checklists and diagnostics
- **Generated docs** - TypeDoc documentation for all services

## 🔄 Maintenance & Updates

### Updating Dependencies

```powershell
# Update package versions
pwsh scripts/17-GenerateEnvironmentConfig.ps1

# Regenerate package.json with latest versions
pwsh scripts/00-InitEnvironment.ps1
```

### Validating Generated Code

```powershell
# Run all validation checks
pwsh scripts/05-VerifyCompliance.ps1

# Domain-specific linting
pwsh scripts/06-DomainLint.ps1

# TypeScript compilation check
pwsh scripts/07-BuildAndTest.ps1
```

## 🎯 Success Metrics

After successful automation execution:

- ✅ **57 scripts** completed successfully
- ✅ **~600KB** of generated TypeScript code
- ✅ **30,000+ lines** across all domains
- ✅ **98% completion** of all checklist items
- ✅ **Production-ready** Bitcoin Ordinals application

## 🆘 Troubleshooting

### Common Issues

1. **PowerShell execution policy**: Run `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`
2. **Node.js version**: Ensure Node.js 18+ is installed
3. **Template parsing errors**: Run `pwsh scripts/fix-content-parsing.ps1`
4. **Permission errors**: Run PowerShell as Administrator (Windows)

### Validation Tools

```powershell
# Check all prerequisites
pwsh scripts/15-ValidateSetupComplete.ps1

# Analyze any issues
pwsh scripts/script_scrub/01-analyze-dependencies.ps1

# Generate comprehensive report
pwsh scripts/script_scrub/06-generate-final-report.ps1
```

## 📞 Support

- **Documentation**: See `/docs/` directory for complete technical specifications
- **Build Issues**: Check `/scripts/automation.log` for detailed execution logs
- **Script Validation**: Use `/scripts/script_scrub/` tools for analysis

---

**Built with ❤️ by the Protozoa Team**  
_Transforming Bitcoin Ordinals into digital organisms through advanced automation_
