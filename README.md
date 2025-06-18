# New-Protozoa: Bitcoin Ordinals Digital Organism Simulation

**🧬 On-chain evolution powered by Bitcoin blockchain data**

An advanced TypeScript simulation that creates and evolves digital unicellular organisms using Bitcoin Ordinals. Each organism is uniquely seeded from Bitcoin block data, ensuring deterministic but unique traits tied to blockchain history.

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/BTCEnoch/protozoa.git
cd protozoa

# Run the complete automation setup
cd scripts
powershell ./runAll.ps1
```

## 🎯 Features

- **Bitcoin-Seeded Evolution**: Organisms derive traits from Bitcoin block nonces and hashes
- **Domain-Driven Architecture**: 10 isolated domains (rendering, physics, traits, etc.)
- **THREE.js Visualization**: High-performance 3D rendering with GPU resource management
- **Deterministic Randomness**: Reproducible organism generation using blockchain entropy
- **TypeScript Excellence**: 100% typed with strict compliance standards
- **Memory-Safe**: Comprehensive resource cleanup and leak prevention

## 🏗️ Architecture

### Core Domains
```
src/domains/
├── rendering/     # THREE.js scene management
├── animation/     # Particle movement and easing
├── effect/        # Visual effects triggered by Bitcoin data
├── trait/         # Organism characteristics from blockchain
├── physics/       # Particle distribution and collision
├── particle/      # Organism lifecycle management
├── formation/     # Geometric pattern arrangements
├── group/         # Particle clustering behavior
├── rng/           # Seeded randomness using Bitcoin nonces
└── bitcoin/       # Blockchain data fetching with caching
```

### Service Architecture
- **Singleton Pattern**: All services use `static #instance` with `getInstance()`
- **Interface-First**: Every service implements `IServiceName` contract
- **Dependency Injection**: Clean separation between domain boundaries
- **Winston Logging**: Comprehensive logging for debugging and performance
- **Resource Cleanup**: Mandatory `dispose()` methods prevent memory leaks

## 🔗 Bitcoin Integration

- **Block Data API**: Fetches Bitcoin block information for trait seeding
- **Ordinals Protocol**: Stores organism data as Bitcoin inscriptions
- **Deterministic Traits**: Block nonces ensure reproducible organism characteristics
- **Environment Switching**: Automatic dev/production API endpoint configuration

## 📋 Compliance Standards

The project enforces strict architectural discipline:

- ✅ **500-line file limit** (automatically enforced)
- ✅ **Zero cross-domain imports** (domain boundary protection)
- ✅ **Singleton consistency** (pattern enforcement scripts)
- ✅ **Memory leak prevention** (mandatory cleanup methods)
- ✅ **TypeScript strict mode** (100% type coverage)

## 🛠️ Automation Scripts

Complete PowerShell automation package in `/scripts`:

- `00-InitEnvironment.ps1` - Install Node.js, pnpm, dependencies
- `01-ScaffoldProjectStructure.ps1` - Create domain directories
- `02-GenerateDomainStubs.ps1` - Generate TypeScript service stubs
- `03-MoveAndCleanCodebase.ps1` - Legacy cleanup and migration
- `runAll.ps1` - Master orchestrator for complete setup

## 🧪 Development Workflow

1. **Setup**: Run automation scripts for instant project scaffolding
2. **Implement**: Fill service stubs following domain-driven phases
3. **Validate**: Run compliance scripts after each phase
4. **Test**: Comprehensive unit and integration testing
5. **Deploy**: Automated CI/CD with quality gates

## 📚 Documentation

- **Build Checklist**: 8-phase implementation roadmap
- **Architecture Design**: Detailed service specifications
- **Compliance Rules**: Complete `.cursorrules` standards
- **API Integration**: Bitcoin Ordinals protocol documentation

## 🚦 Project Status

- ✅ **Phase 1**: Foundation and infrastructure setup
- ✅ **Phase 2-3**: Core utility and data integration domains
- 🚧 **Phase 4-6**: Particle system and visual domains (in progress)
- ⏳ **Phase 7-8**: Automation and integration testing

## 🤝 Contributing

This project follows strict architectural standards. Please:

1. Run `scripts/05-VerifyCompliance.ps1` before committing
2. Ensure all files stay under 500 lines
3. Follow singleton patterns for services
4. Maintain domain boundary isolation
5. Add comprehensive logging and error handling

## 📄 License

MIT License - Build the future of on-chain digital life!

---

**Ready to evolve digital organisms on the Bitcoin blockchain! 🧬⚡**
