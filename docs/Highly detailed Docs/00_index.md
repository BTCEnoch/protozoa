# Bitcoin Protozoa: Particle Creatures Architecture Documentation

## AI Assistant Limitations and Working Guidelines

> **Note to AI Assistant**: When working with this codebase, operate within these constraints to avoid timeouts and truncated responses:
>
> **Content Size Limitations**:
> - Keep responses under 2,000 words or 10-15KB of text
> - Limit code examples to 200-300 lines per response
> - Keep file generations under 500 lines of code
>
> **Processing Limitations**:
> - View files in chunks of 1,000 lines maximum using view_range
> - Break complex operations into multiple steps
> - Avoid analyzing multiple large files simultaneously
>
> **Working Strategy**:
> - Split large documents into logical parts with clear naming (e.g., part1, part2)
> - Implement features incrementally, one component at a time
> - Use cross-references between documents rather than duplicating information
> - Test each component individually before integration
> - Break web searches into specific, targeted queries
>
> Following these guidelines will ensure effective collaboration without technical disruptions.

## Quick Navigation

- [Project Fundamentals](#project-fundamentals)
- [Core Systems](#core-systems)
- [Bitcoin Integration](#bitcoin-integration)
- [Implementation Details](#implementation-details)
- [User Experience](#user-experience)
- [Development & Deployment](#development-and-deployment)
- [Asset Management](#asset-management)
- [Planning & Ideas](#planning-and-ideas)
- [Project Management](#project-management)

## Documentation Index

### Project Fundamentals

1. [Project Overview](01_project_overview.md)
   - Project Vision
   - Core Concept
   - Key Objectives
   - Target Applications
   - Unique Value Proposition

2. [System Architecture](02_system_architecture.md)
   - High-Level Architecture
   - Core Components
   - Integration Points

### Core Systems

3. [Particle System Design](03_particle_system.md)
   - Particle Types and Roles
   - Particle Properties
   - Lifecycle Management
   - Interaction System
   - Memory Management

5. [Physics Engine](05_physics_engine.md)
   - Core Physics Components
   - Spatial Organization
   - Movement Physics
   - Optimization Techniques
   - GPU Acceleration

6. [Memory and Worker Systems](06_memory_worker_systems.md)
   - Memory Management System
   - Advanced Worker System
   - Integration Between Systems
   - Performance Considerations
   - Implementation Guidelines

9. [Force Field System](09_force_field_system.md)
   - Gyroscopic Polygon Force Fields
   - Role Hierarchy Integration
   - Force Field Types and Behaviors
   - Implementation Details
   - Spatial Optimization

10. [RNG System](10_rng_system.md)
    - Block Data Integration
    - Rehash Chain System
    - Purpose-Specific RNG
    - Trait Generation Process
    - Role Determination

11. [Role Hierarchy](11_role_hierarchy.md)
    - Particle Roles
    - Role Relationships
    - Force Field Role Enforcement
    - Force Matrix
    - Visual Representations

26. [Force Calculations](26_force_calculations.md)
    - Force-Based Particle Interaction
    - Force Calculation Formula
    - Force Rule Generation
    - Role-Based Force Modifiers
    - Formation Calculations
    - Performance Optimizations

### Bitcoin Integration

4. [Blockchain Integration](04_blockchain_integration.md)
   - Key Features
   - Blockchain-to-Particle Mapping
   - Implementation Architecture
   - Supported Platforms
   - Security Considerations

8. [Bitcoin Integration and Deployment](08_bitcoin_integration.md)
   - Bitcoin-Only Approach
   - Ordinals Protocol Integration
   - On-Chain Dependencies
   - Development vs. Production
   - RNG System

16. [Bitcoin Integration Approach](16_bitcoin_integration_approach.md)
    - Inscription Process
    - Dependency Management
    - Error Handling Approach
    - Local Development Environment
    - Size Constraints and Optimization
    - Testing with Inscription Sources

19. [Evolution Mechanics](19_evolution_mechanics.md)
    - Confirmation-Based Mutation System
    - Mutation Types
    - Rarity System
    - Group Selection and Multi-Group Mutations
    - Implementation Considerations
    - Testing Approach

### Implementation Details

14. [Technical Implementation](14_technical_implementation.md)
    - Core Technology Stack
    - Performance Optimization Strategies
    - Web Workers Implementation
    - React Optimizations
    - Module Structure

15. [Particle System Design Decisions](15_particle_system_design_decisions.md)
    - Particle Traits and Appearance
    - Force Fields and Formations
    - Physics and Interactions
    - Particle Distribution
    - Animation and Movement
    - Special Effects

18. [Performance Optimization Strategies](18_performance_optimization_strategies.md)
    - Web Workers Implementation
    - Memory Management
    - WebGL Optimization
    - React Optimizations
    - Performance Monitoring
    - Implementation Phasing

21. [Trait System](21_trait_system.md)
    - Core Concepts
    - Group Attributes
    - Trait Categories with Rarity Tiers
    - Deterministic RNG-Based Trait Assignment
    - Rarity-Based Implementation
    - Future Expansion

22. [Testing Strategy](22_testing_strategy.md)
    - Testing Approach
    - Unit Testing
    - Integration Testing
    - Performance Testing
    - Bitcoin Integration Testing

23. [Module Structure](23_module_structure.md)
    - Domain-Based Organization
    - Core Modules
    - Service Modules
    - Utility Modules
    - Testing Modules

24. [Error Handling Strategy](24_error_handling_strategy.md)
    - Error Types
    - Error Boundaries
    - Fallback Mechanisms
    - Logging and Monitoring
    - User Feedback

25. [Code Splitting Strategy](25_code_splitting_strategy.md)
    - Code Splitting Philosophy
    - React Code Splitting
    - Domain-Based Splitting
    - Feature-Based Splitting
    - Worker-Based Splitting
    - Vite-Specific Optimizations
    - Bitcoin Inscription Considerations

### User Experience

12. [Development UI](12_development_ui.md)
    - Core Requirements
    - UI Components
    - Parameter Categories
    - Preset System
    - Transition to Production

17. [User Experience Approach](17_user_experience_approach.md)
    - Target Experience
    - Performance Targets
    - User Interface Design
    - User Flow
    - Responsive Design
    - Data Display

31. [Visual Design System](31_visual_design_system.md)
    - Color Palette
    - Typography
    - UI Components
    - Iconography
    - Particle Visual Effects
    - Responsive Design
    - Accessibility Guidelines
    - Animation Guidelines

32. [Color Themes](32_color_themes.md)
    - 50 Color Palettes
    - Role-Based Color Assignment
    - Implementation Guidelines
    - Technical Implementation

### Development and Deployment

27. [Development Workflow](27_development_workflow.md)
    - Development Phases
    - Development Tools and Practices
    - Testing Strategy
    - Bitcoin Dependencies During Development
    - Development Environment Setup
    - Development Workflow Steps
    - Inscription Workflow

28. [Deployment Pipeline](28_deployment_pipeline_part1.md)
    - Ordinals Inscription Fundamentals
    - Pre-Deployment Preparation
    - Deployment Tools
    - Deployment Process
    - Fallback Mechanisms
    - Monitoring and Maintenance
    - Security Considerations
    - Deployment Checklist
    - Troubleshooting

### Asset Management

29. [Asset Management](29_asset_management_part1.md)
    - Core Principles
    - Type Definitions
    - Class Definitions
    - Function Definitions
    - Service Definitions
    - Module Structure and Import/Export Chain
    - Asset Loading Strategy
    - Asset Versioning

### Planning and Ideas

7. [Roadmap and Questions](07_roadmap_and_questions.md)
   - Development Roadmap
   - Open Questions and Considerations
   - Next Steps

13. [Questions Checklist](13_questions_checklist.md)
    - Technical Implementation Questions
    - Particle System Design Questions
    - Bitcoin Integration Questions
    - User Experience Questions

20. [Brainstorm Ideas](20_brainstorm_ideas.md)
    - Birth Traits
    - Advanced Mutation Mechanics
    - Advanced Behavior Traits
    - Visual Enhancement Ideas
    - Combat Attributes System
    - Future Expansion Ideas

### Project Management

30. [Project Checklist](30_project_checklist.md)
    - Project Setup and Planning
    - Core Systems Implementation
    - Bitcoin Integration
    - User Interface and Experience
    - Performance Optimization
    - Testing and Quality Assurance
    - Deployment and Operations
    - Documentation
    - Project Management

33. [Project Inventory](33_project_inventory_main.md)
    - Documentation Status Tracking
    - References to Relevant Documentation
    - Priority Levels
    - Documentation Gaps Analysis
    - Implementation Status

## How to Use This Documentation

This architecture documentation serves as a blueprint for the Bitcoin Protozoa project. It outlines the overall structure, components, and design decisions that will guide the implementation.

### Quick Navigation

Use the Quick Navigation section at the top to jump to the category of documentation you need:

- **Project Fundamentals**: Core vision and high-level architecture
- **Core Systems**: Technical details of the particle system, physics, and force calculations
- **Bitcoin Integration**: How the system integrates with Bitcoin and Ordinals
- **Implementation Details**: Specific implementation strategies and decisions
- **User Experience**: UI/UX design and user flow
- **Development & Deployment**: Workflow and deployment pipeline
- **Asset Management**: Type definitions, classes, and module structure
- **Planning & Ideas**: Roadmap, questions, and future concepts
- **Project Management**: Comprehensive checklists and tracking tools

### For Developers
- Start with the Project Fundamentals to understand the vision
- Review the Core Systems documentation for technical details
- Use the Implementation Details section for specific coding guidance
- Refer to the Development & Deployment section for workflow
- Consult Asset Management for type definitions and module structure

### For Project Managers
- Use the Project Fundamentals to communicate the project vision
- Reference the Planning & Ideas section for roadmap and priorities
- Review the Development & Deployment section for workflow planning
- Monitor the Bitcoin Integration section for blockchain-specific considerations
- Utilize the Project Management section for comprehensive tracking and quality gates

### For Stakeholders
- The Project Fundamentals provide a concise summary of the project
- User Experience section highlights the end-user perspective
- Planning & Ideas section shows future potential

## Multi-Part Documents

Some larger documents have been split into multiple parts for easier management:

- **Deployment Pipeline**: Parts 1-4 (28_deployment_pipeline_part1.md through part4.md)
- **Asset Management**: Parts 1-5 (29_asset_management_part1.md through part5.md)

Read these documents in sequence for a complete understanding of the topic.

## Contributing to This Documentation

As the project evolves, this documentation should be updated to reflect changes in design and implementation. When making updates:

1. Maintain the existing structure and categorization for consistency
2. Update diagrams to reflect architectural changes
3. Keep the roadmap current with completed items and new priorities
4. Document any major design decisions and their rationale
5. For large documents, consider splitting into multiple parts with clear naming
