# Bitcoin Integration and Deployment

## Bitcoin-Only Approach

Beast Import will be deployed entirely on Bitcoin using the Ordinals protocol. This means:

1. **Immutable Deployment**: Once inscribed, the codebase will be permanently stored on Bitcoin and cannot be modified
2. **Recursive Inscription Structure**: The application will use recursive inscriptions to reference dependencies
3. **No External Dependencies**: All runtime dependencies must be sourced from Bitcoin inscriptions
4. **Bitcoin as Server**: Bitcoin network serves as the hosting infrastructure

## Ordinals Protocol Integration

### Deployment Strategy

The application will be deployed as a set of inscriptions on Bitcoin:

```
┌─────────────────────────────────────────────────────────┐
│                 Main Application Inscription             │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌─────────────┐   ┌─────────────┐   ┌─────────────┐   │
│  │ Dependency 1 │   │ Dependency 2 │   │ Dependency 3 │   │
│  │  Inscription │   │  Inscription │   │  Inscription │   │
│  └─────────────┘   └─────────────┘   └─────────────┘   │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Access Pattern

- Development/Testing: `https://ordinals.com/content/{inscriptionID}`
- Production: `/content/{inscriptionID}` (relative to Bitcoin node)

### Data Retrieval

The application will retrieve Bitcoin block data exclusively from the Ordinals.com API:

```typescript
async function fetchBlockInfo(blockNumber: number) {
  // Development endpoint
  const devEndpoint = `https://ordinals.com/r/blockinfo/${blockNumber}`;
  // Production endpoint (for final deployment)
  const prodEndpoint = `/r/blockinfo/${blockNumber}`;

  // Use appropriate endpoint based on environment
  const endpoint = process.env.NODE_ENV === 'development' ? devEndpoint : prodEndpoint;

  const response = await fetch(endpoint);
  // Process response
}
```

Key data retrieved:
- Block nonce (primary seed for RNG)
- Confirmation count (evolution trigger)
- Timestamp
- Block number

## On-Chain Dependencies

All runtime dependencies will be loaded from Bitcoin inscriptions. The application will use a dependency loader to fetch and execute these inscriptions.

### Core Dependencies

| Category | Dependencies |
|----------|--------------|
| Frontend Framework | React, ReactDOM, Scheduler, React Reconciler |
| 3D Rendering | Three.js, React Three Fiber, React Three Drei |
| Animation & Effects | GSAP, React-spring-core, Shader-composer |
| State Management | Zustand, valtio, jotai, immer |
| Utility Libraries | JSZip, fflate, pako, crypto-js, etc. |

### Dependency Loading Implementation

```javascript
// Sample code for the dependency loader
const DEPENDENCIES = {
  react: {
    id: '7f403153b6484f7d24f50a51e1cdf8187219a3baf103ef0df5ea2437fb9de874i0',
    priority: 1
  },
  reactDOM: {
    id: '89295aaf617708128b95d22e7099ce32108d4b918386e6f90994e7979d22ba72i0',
    priority: 2,
    requires: ['react']
  },
  // Additional dependencies...
};

// Load a dependency from its inscription
function loadDependency(inscriptionId, callback) {
  const script = document.createElement('script');

  // Use appropriate endpoint based on environment
  const baseUrl = process.env.NODE_ENV === 'development'
    ? 'https://ordinals.com'
    : '';

  script.src = `${baseUrl}/content/${inscriptionId}`;
  script.onload = callback;
  script.onerror = (error) => console.error(`Failed to load: ${inscriptionId}`, error);
  document.head.appendChild(script);
}

// Load dependencies in sequence
function loadDependencies(dependencies, onComplete) {
  if (dependencies.length === 0) {
    onComplete();
    return;
  }

  const [current, ...rest] = dependencies;
  loadDependency(current.id, () => loadDependencies(rest, onComplete));
}
```

The loader will:
1. Fetch inscriptions in the correct dependency order
2. Verify each inscription via its ID
3. Execute the code
4. Cache successfully loaded dependencies

## Development vs. Production

### Development Environment

- Local development with standard web tools
- Testing via ordinals.com API
- Full development UI for testing and parameter adjustment
- Comprehensive debugging tools

### Production Environment

- Stripped-down version with no development tools
- Immutable code inscribed on Bitcoin
- No ability to update after deployment
- Minimal, focused UI for end-users

## RNG System

The RNG system is critical for deterministic creature generation:

### Block Data as Seed

- Block nonce serves as the primary seed
- Each block height produces a unique but reproducible creature
- 500 particles per creature, with deterministic properties

### Rehash Chain System

- Generates multiple unique but deterministic values from a single nonce
- Used for trait generation, group characteristics, and other properties
- Maintains a chain of values for consistency

### Purpose-Specific RNG

Different aspects of the simulation use dedicated RNG streams:
- 'traits': Creature trait generation
- 'physics': Movement and behavior
- Future: abilities, attributes, stats, mutations

## Implementation Considerations

### Minimizing Inscription Size

- Optimize code for size efficiency
- Remove all development tools and debugging in production
- Use compression techniques where appropriate

### Fallback Strategies

- Implement graceful degradation for missing resources
- Prioritize core functionality over visual enhancements
- Ensure deterministic behavior even with limited resources

### Testing Requirements

- Verify deterministic behavior across different environments
- Ensure all dependencies load correctly from inscriptions
- Test with actual Bitcoin block data
- Validate visual output matches expectations
