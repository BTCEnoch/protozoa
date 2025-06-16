# RNG System

## Overview

The Random Number Generation (RNG) system uses Bitcoin block header data to create deterministic, reproducible random values for creature generation and behavior. This system ensures that creatures can be recreated exactly given the same block height input.

## Core Principles

1. **Determinism**: All RNG must be reproducible - same block height = same creature
2. **Sequence Importance**: Order of operations matters for consistency
3. **Purpose Isolation**: Different aspects need different RNG streams that remain independent
4. **Bitcoin-Sourced Entropy**: All randomness derives from Bitcoin block data

## Key Components

### 1. Block Data Integration

```typescript
interface BlockInfo {
  blockNumber: number;
  nonce: number;
  confirmations: number;
  timestamp: number;
}
```

- **Source**: ordinals.com/r/blockinfo/{blockNumber}
- **Critical Fields**:
  - `nonce`: Primary seed for RNG
  - `confirmations`: Used for evolution mechanics
- **Caching**: Implemented to reduce API calls

### 2. Rehash Chain System

```typescript
private rehashChain: number[] = []
private readonly maxChainLength = 100
```

- **Purpose**: Generate multiple unique but deterministic values from single nonce
- **Mechanism**:
  - Initial seed from block nonce
  - Each rehash creates new deterministic value
  - Values stored in chain for consistency
- **Usage**:
  - Trait generation
  - Group characteristics
  - Future: abilities, mutations, etc.

### 3. Purpose-Specific RNG

```typescript
private purposeRngs: Map<string, () => number>
getPurposeRng(purpose: string): () => number
```

- **Current Purposes**:
  - 'traits': Creature trait generation
  - 'physics': Movement and behavior
- **Future Expansion**:
  - abilities
  - attributes
  - stats
  - mutations

## RNG Flow

### 1. Initialization

```typescript
class RandomStateManager {
  constructor() {
    this.state = {
      nonce: 0,
      generator: mulberry32(0),
      sequence: 0
    }
    this.rehashChain = [0]
    this.initializeFromBlock(0)
  }
}
```

1. Start with default state
2. Fetch block data
3. Initialize with block nonce
4. Pre-generate initial rehash chain values

### 2. Rehash Chain Generation

```typescript
next(): number {
  const value = this.state.generator()
  this.state.sequence++
  
  if (this.state.sequence % 10 === 0) {
    this.addToRehashChain(value)
  }
  
  return value
}
```

- Every 10th value adds to rehash chain
- Creates deterministic sequence
- Maintains reproducibility

### 3. Purpose-Specific Generation

```typescript
getPurposeRng(purpose: string): () => number {
  if (!this.purposeRngs.has(purpose)) {
    const purposeHash = this.hashString(purpose)
    const seed = this.state.nonce ^ purposeHash
    this.purposeRngs.set(purpose, mulberry32(seed))
  }
  return this.purposeRngs.get(purpose)!
}
```

- Unique generator per purpose
- XOR with purpose hash for uniqueness
- Maintains determinism per purpose

## Trait Generation Process

### 1. Initial Seeding

```typescript
export function generateTraits(): GroupTraits {
  const random = getTraitRng()
  // ...
}
```

- Uses purpose-specific 'traits' RNG
- Ensures consistent trait generation

### 2. Group Assignment

```typescript
for (let i = 0; i < 4; i++) {
  const nextSeed = getNextRehash(i)
  const groupRandom = getTraitRng()
  // ...
}
```

- Each group gets unique rehash value
- Maintains deterministic relationship
- Allows recreation from original nonce

## Role Determination

The RNG system is used to deterministically assign roles to particles:

```typescript
function determineRoleFromBlockData(particleId: string, blockData: BlockData): ParticleRole {
  // Use particle ID and block data to deterministically assign role
  const hash = deterministicHash(particleId + blockData.merkleRoot);
  const value = normalizeHash(hash, 0, 100);
  
  if (value < 10) return ParticleRole.CORE;      // 10% chance
  if (value < 25) return ParticleRole.CONTROL;   // 15% chance
  if (value < 45) return ParticleRole.ATTACK;    // 20% chance
  if (value < 70) return ParticleRole.DEFENSE;   // 25% chance
  return ParticleRole.MOVEMENT;                  // 30% chance
}
```

## Current Limitations/Considerations

### 1. Chain Length

```typescript
private readonly maxChainLength = 100
```

- Could be dynamic based on needs
- No clear reason for limitation
- May need expansion for future features

### 2. Purpose Hashing

```typescript
private hashString(str: string): number
```

- Simple string hash function
- Sufficient for current purposes
- May need enhancement for more purposes

### 3. Block Data

- Single endpoint dependency
- Confirmations tracking
- Cache management needed

## Implementation Guidelines

### 1. Critical Dependencies

- mulberry32 RNG
- Block data API
- Caching system

### 2. State Management

- Single RandomStateManager instance
- Purpose-specific generators
- Rehash chain maintenance

### 3. Error Handling

- Block fetch failures
- Chain exhaustion
- Purpose conflicts

## Usage Guidelines

### 1. Trait Generation

```typescript
const traitRng = getTraitRng()
const traits = generateTraits()
```

- Use purpose-specific RNG
- Maintain operation order
- Respect rehash chain

### 2. Physics Integration

```typescript
const physicsRng = getPhysicsRng()
```

- Separate from trait generation
- Consistent usage patterns
- Deterministic behavior

### 3. Future Extensions

- Follow purpose-specific pattern
- Maintain determinism
- Document relationships
