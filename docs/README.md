# New-Protozoa Documentation Suite

**Complete architectural and implementation documentation for the Bitcoin Ordinals Digital Organism Simulation**

This documentation suite provides comprehensive technical specifications, implementation guides, and domain-driven architecture details extracted from `build_design.md`. All documentation follows strict architectural standards and implementation patterns designed for production-scale TypeScript development.

## 📋 Documentation Organization

### [Overview Documentation](overview/README.md)
Complete project overview including MVP specifications, architectural principles, and high-level system design.

- **[Architecture.md](overview/Architecture.md)** - Domain-driven architecture patterns, service layer design, and compliance standards
- **[MVP.md](overview/MVP.md)** - Minimum viable product specifications, feature requirements, and implementation roadmap
- **[README.md](overview/README.md)** - Overview navigation and quick-start documentation guide

### [Domain Specifications](domains/README.md)
Detailed technical specifications for each of the 10 isolated domains in the simulation system.

#### Core Rendering & Visual Systems
- **[rendering.md](domains/rendering.md)** - THREE.js integration, scene management, and GPU resource optimization
- **[animation.md](domains/animation.md)** - Particle animation systems, easing functions, and performance optimization
- **[effect.md](domains/effect.md)** - Visual effects engine, preset management, and Bitcoin data integration

#### Data & Blockchain Integration
- **[bitcoin.md](domains/bitcoin.md)** - Blockchain data fetching, caching strategies, and Ordinals protocol integration
- **[trait.md](domains/trait.md)** - Organism trait generation, mutation algorithms, and blockchain-seeded evolution

#### Particle System Core
- **[particle.md](domains/particle.md)** - Digital organism lifecycle management and state tracking
- **[physics.md](domains/physics.md)** - Particle physics calculations, gravity simulation, and collision detection
- **[formation.md](domains/formation.md)** - Geometric pattern arrangements and particle positioning algorithms
- **[group.md](domains/group.md)** - Particle clustering behavior and formation management

#### Utility Services
- **[rng.md](domains/rng.md)** - Deterministic random number generation with Bitcoin block seeding

### Automation & Scripts
PowerShell automation suite for project scaffolding, compliance verification, and deployment automation.

- **Project Structure Scaffolding** - Automated domain directory creation and TypeScript stub generation
- **Compliance Verification** - Automated checking of architectural standards and file size limits
- **Singleton Pattern Enforcement** - Service pattern standardization across all domains
- **Domain Boundary Validation** - Cross-domain import detection and boundary enforcement

## 🏗️ Architecture Standards

All documentation follows these core principles extracted from the comprehensive build design:

### Domain-Driven Design
- **10 Isolated Domains**: Each domain handles a specific aspect of the simulation with clear boundaries
- **Interface-First Design**: All services implement strict TypeScript interfaces for dependency injection
- **Singleton Pattern**: Consistent `static #instance` pattern with `getInstance()` and exported constants

### Code Quality Standards
- **500-Line File Limit**: All source files strictly under 500 lines for maintainability
- **Zero Cross-Domain Imports**: Domain boundaries enforced through dependency injection
- **Comprehensive Logging**: Winston-based logging with service, performance, and error loggers
- **Memory Management**: Mandatory `dispose()` methods for resource cleanup and leak prevention

### TypeScript Excellence
- **100% Type Coverage**: Strict TypeScript mode with comprehensive interface definitions
- **JSDoc3 Documentation**: All public methods documented with complete JSDoc comments
- **Path Alias Usage**: Standardized `@/domains/*` and `@/shared/*` import patterns

## 🚀 Implementation Phases

The documentation is organized around an 8-phase implementation strategy:

1. **Foundation & Infrastructure** - Project structure, logging, environment configuration
2. **Core Utility Domains** - RNG and Physics service implementation
3. **Data & Blockchain Integration** - Bitcoin service and trait management
4. **Particle System Core** - Particle lifecycle and formation systems
5. **Visual Systems** - Rendering engine and effects integration
6. **Animation & Interaction** - Animation systems and group management
7. **Automation & Compliance** - PowerShell scripts and quality assurance
8. **Integration & Testing** - Service composition and React UI integration

## 📚 Usage Guidelines

### For Developers
Each domain documentation provides:
- Complete service implementation examples
- Interface definitions and dependency injection patterns
- Logging and error handling implementations
- Performance optimization guidelines
- Resource cleanup and disposal patterns

### For Architects
Overview documentation includes:
- System-wide architectural decisions and rationale
- Domain boundary definitions and interaction patterns
- Scalability considerations and performance targets
- Compliance standards and automated enforcement

### For DevOps
Automation documentation covers:
- Complete PowerShell script suite for project management
- CI/CD integration patterns and quality gates
- Compliance verification and reporting systems
- Deployment automation and environment configuration

---

**All documentation derived from `build_design.md` - Complete domain-driven architecture for Bitcoin Ordinals digital organism simulation**
