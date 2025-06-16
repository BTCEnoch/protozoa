# Ordinals Deployment Pipeline

## Overview

This document outlines the deployment pipeline for inscribing the Beast Import project on Bitcoin using the Ordinals protocol. The pipeline covers the process from build preparation to final inscription and verification.

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

## Deployment Tools

### Ordinals Wallet

An Ordinals-compatible wallet is required for creating inscriptions. Options include:

- Sparrow Wallet with Ord extension
- Xverse Wallet
- Ordinals Wallet

### Inscription Tools

Tools for creating and managing inscriptions:

- `ord` command-line tool
- Inscription service providers
- Custom inscription scripts

## Deployment Process

### 1. Environment Setup

```bash
# Install ord tool
curl -sSL https://ordinals.com/install.sh | bash

# Initialize wallet (if needed)
ord wallet init

# Generate receiving address
ord wallet receive
```

### 2. Prepare Inscription Files

```bash
# Create inscription directory
mkdir -p inscriptions

# Copy optimized chunks to inscription directory
cp -r dist/chunks/* inscriptions/

# Create manifest file
cat > inscriptions/manifest.json << EOF
{
  "dependencies": [
    { "id": "react-inscription-id", "name": "react", "priority": 1 },
    { "id": "react-dom-inscription-id", "name": "react-dom", "priority": 2 },
    { "id": "three-inscription-id", "name": "three", "priority": 3 },
    { "id": "zustand-inscription-id", "name": "zustand", "priority": 4 }
  ],
  "chunks": [
    { "id": "core-inscription-id", "name": "core", "priority": 5 },
    { "id": "particle-inscription-id", "name": "particle", "priority": 6 },
    { "id": "physics-inscription-id", "name": "physics", "priority": 7 },
    { "id": "ui-inscription-id", "name": "ui", "priority": 8 }
  ]
}
EOF
```

### 3. Inscribe Dependencies

Inscribe each dependency in order:

```bash
# Inscribe React
ord wallet inscribe --fee-rate 10 inscriptions/react.js

# Record inscription ID
REACT_INSCRIPTION_ID="<output-inscription-id>"

# Inscribe React DOM
ord wallet inscribe --fee-rate 10 inscriptions/react-dom.js

# Record inscription ID
REACT_DOM_INSCRIPTION_ID="<output-inscription-id>"

# Continue for all dependencies...
```

### 4. Update References

Update references in application chunks to point to inscribed dependencies:

```bash
# Create script to update references
cat > update-refs.js << EOF
const fs = require('fs');
const path = require('path');

const inscriptionIds = {
  'react': 'REACT_INSCRIPTION_ID',
  'react-dom': 'REACT_DOM_INSCRIPTION_ID',
  'three': 'THREE_INSCRIPTION_ID',
  'zustand': 'ZUSTAND_INSCRIPTION_ID'
};

// Update references in each chunk
const updateReferences = (filePath) => {
  let content = fs.readFileSync(filePath, 'utf8');
  
  for (const [dep, id] of Object.entries(inscriptionIds)) {
    const importRegex = new RegExp(`from ["']${dep}["']`, 'g');
    content = content.replace(importRegex, `from "/content/${id}"`);
  }
  
  fs.writeFileSync(filePath, content);
};

// Process all chunks
const chunksDir = path.join(__dirname, 'inscriptions');
fs.readdirSync(chunksDir)
  .filter(file => file.endsWith('.js') && !Object.keys(inscriptionIds).includes(file.replace('.js', '')))
  .forEach(file => updateReferences(path.join(chunksDir, file)));
EOF

# Run the script
node update-refs.js
```

### 5. Inscribe Application Chunks

Inscribe each application chunk in order:

```bash
# Inscribe core chunk
ord wallet inscribe --fee-rate 10 inscriptions/core.js

# Record inscription ID
CORE_INSCRIPTION_ID="<output-inscription-id>"

# Continue for all chunks...
```

### 6. Create Main HTML Inscription

Create the main HTML file that loads all chunks:

```bash
cat > inscriptions/index.html << EOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Beast Import</title>
  <style>
    body { margin: 0; overflow: hidden; background: #1a1a1a; }
    #loading { position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); color: #ff8c00; font-family: sans-serif; }
  </style>
</head>
<body>
  <div id="root"></div>
  <div id="loading">Loading Beast Import...</div>
  
  <script>
    // Load dependencies in order
    const dependencies = [
      { id: "REACT_INSCRIPTION_ID", name: "react" },
      { id: "REACT_DOM_INSCRIPTION_ID", name: "react-dom" },
      { id: "THREE_INSCRIPTION_ID", name: "three" },
      { id: "ZUSTAND_INSCRIPTION_ID", name: "zustand" },
      { id: "CORE_INSCRIPTION_ID", name: "core" },
      { id: "PARTICLE_INSCRIPTION_ID", name: "particle" },
      { id: "PHYSICS_INSCRIPTION_ID", name: "physics" },
      { id: "UI_INSCRIPTION_ID", name: "ui" }
    ];
    
    // Load each dependency in sequence
    async function loadDependencies() {
      for (const dep of dependencies) {
        await loadScript(\`/content/\${dep.id}\`);
        console.log(\`Loaded \${dep.name}\`);
      }
      
      // Initialize application
      document.getElementById('loading').style.display = 'none';
      window.initializeApplication();
    }
    
    // Helper to load a script
    function loadScript(src) {
      return new Promise((resolve, reject) => {
        const script = document.createElement('script');
        script.src = src;
        script.onload = resolve;
        script.onerror = reject;
        document.head.appendChild(script);
      });
    }
    
    // Start loading
    loadDependencies().catch(err => {
      console.error('Failed to load dependencies:', err);
      document.getElementById('loading').textContent = 'Failed to load. Please try again.';
    });
  </script>
</body>
</html>
EOF

# Inscribe main HTML
ord wallet inscribe --fee-rate 10 inscriptions/index.html

# Record main inscription ID
MAIN_INSCRIPTION_ID="<output-inscription-id>"
```

### 7. Verify Inscriptions

Verify that all inscriptions are accessible and working:

```bash
# Check main inscription
ord explore inscription MAIN_INSCRIPTION_ID

# Test in browser
echo "Open https://ordinals.com/content/MAIN_INSCRIPTION_ID in your browser"
```

## Fallback Mechanisms

### Content Delivery Network (CDN) Fallbacks

Implement fallbacks for dependencies that fail to load from inscriptions:

```javascript
// Example fallback mechanism
async function loadDependencyWithFallback(inscriptionId, cdnUrl) {
  try {
    await loadScript(`/content/${inscriptionId}`);
    console.log(`Loaded from inscription: ${inscriptionId}`);
  } catch (err) {
    console.warn(`Failed to load from inscription, using CDN fallback: ${cdnUrl}`);
    await loadScript(cdnUrl);
  }
}

// Usage
await loadDependencyWithFallback(
  'REACT_INSCRIPTION_ID',
  'https://cdn.jsdelivr.net/npm/react@18.2.0/umd/react.production.min.js'
);
```

### Local Storage Caching

Implement caching to improve loading performance:

```javascript
async function loadWithCache(inscriptionId, expiry = 86400000) { // Default: 1 day
  const cacheKey = `beast-import-${inscriptionId}`;
  const cached = localStorage.getItem(cacheKey);
  
  if (cached) {
    const { timestamp, content } = JSON.parse(cached);
    if (Date.now() - timestamp < expiry) {
      // Use cached content
      const blob = new Blob([content], { type: 'application/javascript' });
      const url = URL.createObjectURL(blob);
      await loadScript(url);
      return;
    }
  }
  
  // Fetch and cache
  const response = await fetch(`/content/${inscriptionId}`);
  const content = await response.text();
  
  localStorage.setItem(cacheKey, JSON.stringify({
    timestamp: Date.now(),
    content
  }));
  
  const blob = new Blob([content], { type: 'application/javascript' });
  const url = URL.createObjectURL(blob);
  await loadScript(url);
}
```

## Monitoring and Maintenance

### Inscription Health Checks

Implement health checks to verify inscriptions are accessible:

```javascript
async function checkInscriptionHealth(inscriptionIds) {
  const results = {};
  
  for (const id of inscriptionIds) {
    try {
      const response = await fetch(`/content/${id}`);
      results[id] = response.ok;
    } catch (err) {
      results[id] = false;
    }
  }
  
  return results;
}
```

### Update Strategy

For future updates, new inscriptions will be created and the main HTML inscription updated:

1. Inscribe new versions of changed chunks
2. Create a new main HTML inscription with updated references
3. Maintain backward compatibility where possible

## Security Considerations

### Content Security

- Use subresource integrity checks where possible
- Implement content verification before execution
- Validate loaded scripts match expected signatures

### Error Handling

- Implement robust error handling for failed loads
- Provide clear user feedback for loading issues
- Log errors for debugging and monitoring

## Conclusion

This deployment pipeline provides a structured approach to inscribing the Beast Import project on Bitcoin using the Ordinals protocol. By carefully planning the inscription process, implementing fallback mechanisms, and monitoring inscription health, we can ensure a reliable and performant user experience.
