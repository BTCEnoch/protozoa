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
