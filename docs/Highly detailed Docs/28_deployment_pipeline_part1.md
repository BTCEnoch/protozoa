# Ordinals Deployment Pipeline

## Overview

This document outlines the deployment pipeline for inscribing the Bitcoin Protozoa project on Bitcoin using the Ordinals protocol. The pipeline covers the process from build preparation to final inscription and verification.

## Ordinals Inscription Fundamentals

### What are Ordinals?

Ordinals are a way to assign unique identifiers to individual satoshis (the smallest unit of Bitcoin) and track them across transactions. This allows for the creation of digital artifacts on the Bitcoin blockchain, similar to NFTs on other chains.

### Inscription Process

Inscriptions are created by embedding data (HTML, JavaScript, CSS, images, etc.) directly into Bitcoin transactions using witness data. These inscriptions can then be viewed and interacted with using Ordinals-compatible wallets and explorers.

### Recursive Inscriptions

Recursive inscriptions allow one inscription to reference and load another inscription. This is crucial for our project as it enables code splitting and dependency management across multiple inscriptions.

## Pre-Deployment Preparation

### 1. Build Optimization

Before deployment, the codebase must be optimized for inscription:

```bash
# Build production-ready code
npm run build

# Analyze bundle size
npm run analyze

# Optimize chunks for inscription
npm run optimize-chunks
```

### 2. Chunk Preparation

Split the application into optimal chunks for inscription:

1. **Core Dependencies**
   - React
   - React DOM
   - Three.js
   - Zustand

2. **Application Core**
   - Main application code
   - Core services
   - RNG system

3. **Domain-Specific Chunks**
   - Particle system
   - Physics engine
   - Force field system
   - UI components

4. **Asset Chunks**
   - Textures
   - Shaders
   - Configuration data

### 3. Inscription Order Planning

Plan the order of inscriptions to ensure proper loading:

1. Core dependencies must be inscribed first
2. Application core follows dependencies
3. Domain-specific chunks follow the core
4. Asset chunks can be inscribed last
