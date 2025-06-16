# Code Splitting Strategy

This document outlines the code splitting strategy for the Beast Import project, focusing on optimizing initial load time and overall performance.

## Code Splitting Philosophy

Since the application will be deployed as an inscription on Bitcoin, code splitting is crucial for:

1. **Minimizing Initial Load**: Reduce the size of the initial bundle
2. **Prioritizing Critical Code**: Load essential code first
3. **Deferring Non-Critical Code**: Load non-critical code on demand
4. **Optimizing for Inscription**: Ensure the splitting strategy works with Bitcoin inscriptions

## React Code Splitting

### Component-Level Splitting

Use React's `lazy` and `Suspense` for component-level code splitting:

```tsx
import React, { lazy, Suspense } from 'react';

// Eagerly loaded components (critical path)
import Layout from './components/Layout';
import LoadingScreen from './components/LoadingScreen';

// Lazily loaded components (non-critical)
const ParticleSimulation = lazy(() => import('./domains/particle/components/ParticleSimulation'));
const ControlPanel = lazy(() => import('./domains/ui/components/ControlPanel'));
const StatsPanel = lazy(() => import('./domains/ui/components/StatsPanel'));

const App = () => {
  return (
    <Layout>
      {/* Critical UI is loaded immediately */}
      <header>Beast Import</header>
      
      {/* Main simulation is loaded with a suspense boundary */}
      <Suspense fallback={<LoadingScreen message="Loading simulation..." />}>
        <ParticleSimulation />
      </Suspense>
      
      {/* Control panel is loaded separately */}
      <Suspense fallback={<div className="loading-controls">Loading controls...</div>}>
        <ControlPanel />
      </Suspense>
      
      {/* Stats panel is loaded separately */}
      <Suspense fallback={<div className="loading-stats">Loading statistics...</div>}>
        <StatsPanel />
      </Suspense>
    </Layout>
  );
};

export default App;
```

### Route-Based Splitting

For multi-page applications, split code by routes:

```tsx
import React, { lazy, Suspense } from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import LoadingScreen from './components/LoadingScreen';

// Lazily load route components
const Home = lazy(() => import('./pages/Home'));
const Creature = lazy(() => import('./pages/Creature'));
const About = lazy(() => import('./pages/About'));

const App = () => {
  return (
    <Router>
      <Suspense fallback={<LoadingScreen />}>
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/creature/:blockNumber" element={<Creature />} />
          <Route path="/about" element={<About />} />
        </Routes>
      </Suspense>
    </Router>
  );
};

export default App;
```

## Domain-Based Splitting

Split code along domain boundaries:

```tsx
// Core domains loaded eagerly
import { coreService } from './domains/core';
import { rngService } from './domains/rng';

// Other domains loaded lazily
const loadParticleDomain = () => import('./domains/particle');
const loadPhysicsDomain = () => import('./domains/physics');
const loadTraitDomain = () => import('./domains/trait');
const loadMutationDomain = () => import('./domains/mutation');

// Initialize core services immediately
coreService.initialize();
rngService.initialize();

// Load and initialize other domains when needed
const initializeParticleSystem = async () => {
  const { particleService } = await loadParticleDomain();
  particleService.initialize();
};

const initializePhysics = async () => {
  const { physicsService } = await loadPhysicsDomain();
  physicsService.initialize();
};
```

## Feature-Based Splitting

Split code based on features:

```tsx
// Basic features loaded eagerly
import { basicParticleRenderer } from './features/basic-renderer';

// Advanced features loaded lazily
const loadAdvancedRenderer = () => import('./features/advanced-renderer');
const loadVisualEffects = () => import('./features/visual-effects');
const loadDebugTools = () => import('./features/debug-tools');

// Initialize basic features immediately
basicParticleRenderer.initialize();

// Load advanced features based on user interaction or system capabilities
const enableAdvancedRenderer = async () => {
  const { advancedParticleRenderer } = await loadAdvancedRenderer();
  advancedParticleRenderer.initialize();
  return advancedParticleRenderer;
};

const enableVisualEffects = async () => {
  const { visualEffects } = await loadVisualEffects();
  visualEffects.initialize();
  return visualEffects;
};
```

## Worker-Based Splitting

Offload heavy computations to Web Workers:

```tsx
// Main thread code
import { createParticleSystem } from './particle-system';

// Create particle system in main thread
const particleSystem = createParticleSystem();

// Physics calculations are offloaded to a worker
const physicsWorker = new Worker(new URL('./workers/physics.worker.ts', import.meta.url));

// Send particle data to worker
physicsWorker.postMessage({
  type: 'INITIALIZE',
  particles: particleSystem.getParticles()
});

// Receive updated particle data from worker
physicsWorker.onmessage = (event) => {
  if (event.data.type === 'UPDATE') {
    particleSystem.updateParticles(event.data.particles);
  }
};
```

## Dynamic Import Functions

Use dynamic imports for utility functions and libraries:

```tsx
// Import utilities only when needed
const formatBlockData = async (blockData) => {
  const { formatters } = await import('./utils/formatters');
  return formatters.formatBlockData(blockData);
};

// Import libraries only when needed
const generateReport = async (data) => {
  const { jsPDF } = await import('jspdf');
  const pdf = new jsPDF();
  // Generate PDF report
  return pdf;
};
```

## Preloading and Prefetching

Optimize loading with preloading and prefetching:

```tsx
// Preload critical chunks
const preloadCriticalChunks = () => {
  const links = [
    { rel: 'preload', href: '/chunks/particle-system.js', as: 'script' },
    { rel: 'preload', href: '/chunks/core-services.js', as: 'script' }
  ];
  
  links.forEach(link => {
    const linkElement = document.createElement('link');
    linkElement.rel = link.rel;
    linkElement.href = link.href;
    linkElement.as = link.as;
    document.head.appendChild(linkElement);
  });
};

// Prefetch non-critical chunks when idle
const prefetchNonCriticalChunks = () => {
  if ('requestIdleCallback' in window) {
    window.requestIdleCallback(() => {
      const links = [
        { rel: 'prefetch', href: '/chunks/visual-effects.js', as: 'script' },
        { rel: 'prefetch', href: '/chunks/control-panel.js', as: 'script' }
      ];
      
      links.forEach(link => {
        const linkElement = document.createElement('link');
        linkElement.rel = link.rel;
        linkElement.href = link.href;
        linkElement.as = link.as;
        document.head.appendChild(linkElement);
      });
    });
  }
};
```

## Vite-Specific Optimizations

Leverage Vite's built-in optimizations:

```typescript
// vite.config.ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  build: {
    target: 'esnext',
    minify: 'terser',
    terserOptions: {
      compress: {
        drop_console: true,
        drop_debugger: true
      }
    },
    rollupOptions: {
      output: {
        manualChunks: {
          'react-vendor': ['react', 'react-dom'],
          'three-vendor': ['three'],
          'core': ['./src/domains/core/index.ts', './src/domains/rng/index.ts'],
          'particle': ['./src/domains/particle/index.ts'],
          'physics': ['./src/domains/physics/index.ts'],
          'ui': ['./src/domains/ui/index.ts']
        }
      }
    }
  }
});
```

## Bitcoin Inscription Considerations

### Chunking Strategy for Inscriptions

Since inscriptions have size limitations, optimize chunking for inscription:

```typescript
// Inscription chunking strategy
const inscriptionChunks = [
  {
    name: 'core',
    files: [
      './src/main.tsx',
      './src/App.tsx',
      './src/domains/core/index.ts',
      './src/domains/rng/index.ts'
    ],
    priority: 1 // Highest priority
  },
  {
    name: 'particle',
    files: [
      './src/domains/particle/index.ts'
    ],
    priority: 2
  },
  {
    name: 'physics',
    files: [
      './src/domains/physics/index.ts'
    ],
    priority: 3
  },
  {
    name: 'ui',
    files: [
      './src/domains/ui/index.ts'
    ],
    priority: 4
  },
  {
    name: 'visual-effects',
    files: [
      './src/domains/particle/components/effects/index.ts'
    ],
    priority: 5 // Lowest priority
  }
];
```

### Dependency Loading Order

Ensure dependencies are loaded in the correct order:

```typescript
// Dependency loading order
const dependencies = [
  { id: 'react-inscription-id', name: 'react', priority: 1 },
  { id: 'react-dom-inscription-id', name: 'react-dom', priority: 2 },
  { id: 'three-inscription-id', name: 'three', priority: 3 },
  { id: 'zustand-inscription-id', name: 'zustand', priority: 4 },
  { id: 'core-inscription-id', name: 'core', priority: 5 },
  { id: 'particle-inscription-id', name: 'particle', priority: 6 },
  { id: 'physics-inscription-id', name: 'physics', priority: 7 },
  { id: 'ui-inscription-id', name: 'ui', priority: 8 },
  { id: 'visual-effects-inscription-id', name: 'visual-effects', priority: 9 }
];

// Load dependencies in order
const loadDependencies = async () => {
  // Sort dependencies by priority
  const sortedDependencies = [...dependencies].sort((a, b) => a.priority - b.priority);
  
  // Load each dependency in sequence
  for (const dependency of sortedDependencies) {
    await loadDependency(dependency.id);
  }
  
  // Initialize application
  initializeApplication();
};

// Load a single dependency
const loadDependency = (inscriptionId) => {
  return new Promise((resolve, reject) => {
    const script = document.createElement('script');
    script.src = `/content/${inscriptionId}`;
    script.onload = resolve;
    script.onerror = reject;
    document.head.appendChild(script);
  });
};
```

## Implementation Plan

1. **Analyze Bundle Size**:
   - Use tools like `rollup-plugin-visualizer` to analyze bundle size
   - Identify large dependencies and modules
   - Determine optimal splitting points

2. **Implement Component Splitting**:
   - Identify critical and non-critical components
   - Apply React.lazy and Suspense
   - Test loading performance

3. **Implement Domain Splitting**:
   - Organize code into domains
   - Set up dynamic imports for non-critical domains
   - Test domain loading sequence

4. **Set Up Worker Offloading**:
   - Move heavy computations to workers
   - Implement worker communication
   - Test worker performance

5. **Optimize for Inscription**:
   - Define inscription chunks
   - Set up dependency loading order
   - Test with simulated inscription environment

6. **Implement Preloading**:
   - Add preloading for critical resources
   - Add prefetching for non-critical resources
   - Test loading performance improvements

7. **Configure Build System**:
   - Set up Vite build configuration
   - Configure manual chunks
   - Optimize output for size and performance
