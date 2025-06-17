# Bitcoin Domain

**Blockchain data fetching, caching strategies, and Ordinals protocol integration**

The Bitcoin domain handles all interactions with the Bitcoin blockchain and Ordinals protocol, providing cached access to block information and inscription content. This domain is central to the project's unique value proposition of creating Bitcoin-seeded digital organisms.

## Architectural Overview

### Critical Issues Resolved *(Reference: build_design.md Section 8)*
The Bitcoin domain was mostly well-structured but had minor naming convention issues:
- **Old singleton pattern**: Used `private static instance` instead of `static #instance`
- **Export function**: Used `getBitcoinService()` instead of exported constant
- **Missing disposal**: Lacked comprehensive cache cleanup in `dispose()`

### Solution: Standardized BitcoinService
The service was updated to match architectural standards:
- **Proper singleton**: Uses `static #instance` and `getInstance()`
- **Standard export**: Exports `bitcoinService` constant
- **Complete cleanup**: Full cache clearing and resource disposal
- **Environment configuration**: Dev/prod API endpoint handling

## Service Interface

```typescript
/**
 * Interface for BitcoinService (for completeness).
 */
export interface IBitcoinService {
  fetchBlockInfo(blockNumber: number): Promise<BlockInfo>;
  getCachedBlockInfo(blockNumber: number): BlockInfo | undefined;
  dispose(): void;
}

/**
 * Block information structure from Bitcoin API
 */
interface BlockInfo {
  height: number;
  hash: string;
  nonce: number;
  timestamp: number;
  difficulty: number;
  merkleRoot: string;
  previousBlockHash: string;
}
```

## Complete Service Implementation

*(Reference: build_design.md lines 940-1010)*

```typescript
// src/domains/bitcoin/services/bitcoinService.ts
import { IBitcoinService, BlockInfo } from '@/domains/bitcoin/types';
import { createServiceLogger, createErrorLogger } from '@/shared/lib/logger';
import fetch from 'cross-fetch';  // Cross-platform fetch support

/**
 * BitcoinService – handles retrieval and caching of Bitcoin blockchain data (e.g., block info for ordinals).
 * Implements singleton pattern and caching for performance.
 */
class BitcoinService implements IBitcoinService {
  static #instance: BitcoinService | null = null;
  
  #cache = new Map<number, BlockInfo>();  // simple cache mapping blockNumber to data
  #log = createServiceLogger('BITCOIN_SERVICE');
  #errorLog = createErrorLogger('BITCOIN_SERVICE');
  
  private constructor() {
    this.#log.info('BitcoinService initialized');
  }
  
  /** Singleton accessor */
  public static getInstance(): BitcoinService {
    if (!BitcoinService.#instance) {
      BitcoinService.#instance = new BitcoinService();
    }
    return BitcoinService.#instance;
  }
  
  /**
   * Fetches block information from an external API (or returns cached if available).
   * @param blockNumber - The Bitcoin block height/number to retrieve info for.
   * @returns A promise resolving to the BlockInfo data.
   */
  public async fetchBlockInfo(blockNumber: number): Promise<BlockInfo> {
    // Return cached data if present
    if (this.#cache.has(blockNumber)) {
      this.#log.debug('Cache hit for block', { blockNumber });
      return Promise.resolve(this.#cache.get(blockNumber)!);
    }
    
    const url = `https://ordinals.com/r/blockinfo/${blockNumber}`;  // Dev API endpoint
    try {
      this.#log.info(`Fetching block info from API for block ${blockNumber}`);
      const response = await fetch(url);
      if (!response.ok) throw new Error(`HTTP ${response.status}`);
      const data = await response.json() as BlockInfo;
      this.#cache.set(blockNumber, data);
      return data;
    } catch (err: any) {
      this.#errorLog.logError(err, { blockNumber });
      throw err;
    }
  }
  
  /**
   * Retrieves block info from cache if available (without making API calls).
   */
  public getCachedBlockInfo(blockNumber: number): BlockInfo | undefined {
    return this.#cache.get(blockNumber);
  }
  
  /**
   * Clears all cached data and resets the service.
   */
  public dispose(): void {
    this.#cache.clear();
    this.#log.info('BitcoinService disposed: cache cleared');
    BitcoinService.#instance = null;
  }
}

// Singleton export
export const bitcoinService = BitcoinService.getInstance();
```

## API Integration Patterns

### Development vs Production Configuration *(Reference: .cursorrules lines 25-35)*

**Development Environment**
```typescript
// Full URLs for development testing
const DEV_API_BASE = 'https://ordinals.com';

const fetchBlockInfo = async (blockNumber: number): Promise<BlockInfo> => {
  const url = `${DEV_API_BASE}/r/blockinfo/${blockNumber}`;
  const response = await fetch(url);
  return response.json();
};

const fetchInscriptionContent = async (inscriptionId: string): Promise<any> => {
  const url = `${DEV_API_BASE}/content/${inscriptionId}`;
  const response = await fetch(url);
  return response.json();
};
```

**Production Environment**
```typescript
// Relative paths for production deployment
const PROD_API_BASE = '';  // Empty for same-origin requests

const fetchBlockInfo = async (blockNumber: number): Promise<BlockInfo> => {
  const url = `/r/blockinfo/${blockNumber}`;  // Relative path
  const response = await fetch(url);
  return response.json();
};

const fetchInscriptionContent = async (inscriptionId: string): Promise<any> => {
  const url = `/content/${inscriptionId}`;  // Relative path
  const response = await fetch(url);
  return response.json();
};
```

### Environment Detection and Configuration
```typescript
// Environment-aware API configuration
class BitcoinApiConfig {
  private static getApiBase(): string {
    if (typeof window !== 'undefined' && window.location.hostname === 'localhost') {
      return 'https://ordinals.com';  // Development
    }
    return '';  // Production (relative paths)
  }
  
  public static getBlockInfoUrl(blockNumber: number): string {
    return `${this.getApiBase()}/r/blockinfo/${blockNumber}`;
  }
  
  public static getInscriptionUrl(inscriptionId: string): string {
    return `${this.getApiBase()}/content/${inscriptionId}`;
  }
}
```

## Caching Strategy

### Simple LRU Cache Implementation
```typescript
class LRUCache<T> {
  private capacity: number;
  private cache = new Map<string | number, T>();
  
  constructor(capacity: number = 100) {
    this.capacity = capacity;
  }
  
  get(key: string | number): T | undefined {
    if (this.cache.has(key)) {
      // Move to end (most recently used)
      const value = this.cache.get(key)!;
      this.cache.delete(key);
      this.cache.set(key, value);
      return value;
    }
    return undefined;
  }
  
  set(key: string | number, value: T): void {
    if (this.cache.has(key)) {
      this.cache.delete(key);
    } else if (this.cache.size >= this.capacity) {
      // Remove least recently used (first item)
      const firstKey = this.cache.keys().next().value;
      this.cache.delete(firstKey);
    }
    this.cache.set(key, value);
  }
  
  clear(): void {
    this.cache.clear();
  }
}
```

### Enhanced BitcoinService with LRU Cache
```typescript
class BitcoinService implements IBitcoinService {
  static #instance: BitcoinService | null = null;
  
  #cache = new LRUCache<BlockInfo>(50);  // Cache up to 50 blocks
  #inscriptionCache = new LRUCache<any>(25);  // Cache up to 25 inscriptions
  
  // ... rest of implementation
}
```

## Error Handling and Retry Logic

### Network Retry Strategy *(Reference: .cursorrules lines 35-40)*
```typescript
async function fetchWithRetry(url: string, maxRetries: number = 3): Promise<Response> {
  let lastError: Error;
  
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      const response = await fetch(url);
      if (response.ok) {
        return response;
      }
      throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    } catch (error) {
      lastError = error as Error;
      
      if (attempt < maxRetries) {
        // Exponential backoff: 1s, 2s, 4s
        const delayMs = Math.pow(2, attempt - 1) * 1000;
        await new Promise(resolve => setTimeout(resolve, delayMs));
        
        this.#log.warn(`Retry attempt ${attempt} for ${url}`, { error: lastError.message });
      }
    }
  }
  
  throw lastError!;
}
```

### Enhanced Error Handling
```typescript
public async fetchBlockInfo(blockNumber: number): Promise<BlockInfo> {
  // Check cache first
  const cached = this.#cache.get(blockNumber);
  if (cached) {
    this.#log.debug('Cache hit for block', { blockNumber });
    return cached;
  }
  
  const url = BitcoinApiConfig.getBlockInfoUrl(blockNumber);
  
  try {
    this.#log.info(`Fetching block info for block ${blockNumber}`, { url });
    
    const response = await this.fetchWithRetry(url, 3);
    const data = await response.json() as BlockInfo;
    
    // Validate data structure
    if (!this.isValidBlockInfo(data)) {
      throw new Error('Invalid block info structure received');
    }
    
    this.#cache.set(blockNumber, data);
    this.#log.info(`Successfully cached block ${blockNumber}`);
    
    return data;
  } catch (error) {
    this.#errorLog.logError(error as Error, { blockNumber, url });
    throw error;
  }
}

private isValidBlockInfo(data: any): data is BlockInfo {
  return data && 
         typeof data.height === 'number' &&
         typeof data.hash === 'string' &&
         typeof data.nonce === 'number' &&
         typeof data.timestamp === 'number';
}
```

## Usage Examples

### Basic Block Data Retrieval
```typescript
import { bitcoinService } from '@/domains/bitcoin/services/bitcoinService';

// Fetch specific block information
const blockInfo = await bitcoinService.fetchBlockInfo(818000);
console.log(`Block ${blockInfo.height} nonce: ${blockInfo.nonce}`);

// Check cache for previously fetched blocks
const cachedBlock = bitcoinService.getCachedBlockInfo(818000);
if (cachedBlock) {
  console.log('Block found in cache:', cachedBlock.hash);
}
```

### Integration with Trait Generation *(Reference: build_design.md Section 5)*
```typescript
// Using Bitcoin block data to seed organism traits
const generateOrganismFromBlock = async (blockNumber: number) => {
  try {
    // Fetch block data
    const blockData = await bitcoinService.fetchBlockInfo(blockNumber);
    
    // Use block nonce as deterministic seed
    const seed = blockData.nonce;
    const additionalEntropy = blockData.hash.slice(-8); // Last 8 chars of hash
    
    // Generate organism traits using blockchain data
    const traits = traitService.generateTraitsForOrganism(
      `organism-${blockNumber}`, 
      seed
    );
    
    return {
      id: `organism-${blockNumber}`,
      birthBlock: blockNumber,
      birthHash: blockData.hash,
      traits,
      timestamp: blockData.timestamp
    };
  } catch (error) {
    console.error(`Failed to generate organism from block ${blockNumber}:`, error);
    throw error;
  }
};
```

### Rate Limiting and Batch Operations
```typescript
// Fetch multiple blocks with rate limiting
class BitcoinBatchService {
  private static async delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
  
  public static async fetchBlockRange(startBlock: number, endBlock: number, delayMs: number = 1000): Promise<BlockInfo[]> {
    const blocks: BlockInfo[] = [];
    
    for (let blockNum = startBlock; blockNum <= endBlock; blockNum++) {
      try {
        const blockInfo = await bitcoinService.fetchBlockInfo(blockNum);
        blocks.push(blockInfo);
        
        // Rate limiting delay
        if (blockNum < endBlock) {
          await this.delay(delayMs);
        }
      } catch (error) {
        console.error(`Failed to fetch block ${blockNum}:`, error);
        // Continue with next block instead of failing entirely
      }
    }
    
    return blocks;
  }
}
```

## Ordinals Protocol Integration

### Inscription Content Fetching
```typescript
// Extended BitcoinService for inscription content
class ExtendedBitcoinService extends BitcoinService {
  #inscriptionCache = new Map<string, any>();
  
  /**
   * Fetches inscription content by ID
   */
  public async fetchInscriptionContent(inscriptionId: string): Promise<any> {
    if (this.#inscriptionCache.has(inscriptionId)) {
      this.#log.debug('Inscription cache hit', { inscriptionId });
      return this.#inscriptionCache.get(inscriptionId);
    }
    
    const url = BitcoinApiConfig.getInscriptionUrl(inscriptionId);
    
    try {
      this.#log.info(`Fetching inscription content`, { inscriptionId });
      const response = await this.fetchWithRetry(url, 3);
      const content = await response.text(); // Could be JSON, text, or binary
      
      this.#inscriptionCache.set(inscriptionId, content);
      return content;
    } catch (error) {
      this.#errorLog.logError(error as Error, { inscriptionId });
      throw error;
    }
  }
  
  /**
   * Parse inscription content as JSON if possible
   */
  public async fetchInscriptionJson(inscriptionId: string): Promise<any> {
    const content = await this.fetchInscriptionContent(inscriptionId);
    try {
      return JSON.parse(content);
    } catch {
      throw new Error(`Inscription ${inscriptionId} does not contain valid JSON`);
    }
  }
}
```

### Organism State Inscription
```typescript
// Example organism state for inscription
interface OrganismInscription {
  organism_id: string;
  birth_block: number;
  generation: number;
  traits_hash: string;
  lineage: string[];
  evolution_events: Array<{
    block: number;
    mutation: string;
    trigger: string;
  }>;
}

// Create inscription content for organism
const createOrganismInscription = (organism: any): OrganismInscription => {
  return {
    organism_id: organism.id,
    birth_block: organism.birthBlock,
    generation: organism.generation || 1,
    traits_hash: generateTraitHash(organism.traits),
    lineage: organism.parentInscriptions || [],
    evolution_events: organism.evolutionHistory || []
  };
};
```

## Performance and Monitoring

### Cache Performance Metrics
```typescript
class BitcoinServiceMetrics {
  private cacheHits = 0;
  private cacheMisses = 0;
  private apiCalls = 0;
  private errors = 0;
  
  public recordCacheHit(): void {
    this.cacheHits++;
  }
  
  public recordCacheMiss(): void {
    this.cacheMisses++;
  }
  
  public recordApiCall(): void {
    this.apiCalls++;
  }
  
  public recordError(): void {
    this.errors++;
  }
  
  public getMetrics() {
    const total = this.cacheHits + this.cacheMisses;
    return {
      cacheHitRate: total > 0 ? (this.cacheHits / total) * 100 : 0,
      totalRequests: total,
      apiCalls: this.apiCalls,
      errors: this.errors,
      errorRate: this.apiCalls > 0 ? (this.errors / this.apiCalls) * 100 : 0
    };
  }
}
```

## Compliance Notes

### Architectural Standards Met *(Reference: build_design.md Section 8)*
- ✅ **Singleton Pattern**: Uses `static #instance` and `getInstance()`
- ✅ **Interface Implementation**: Implements `IBitcoinService`
- ✅ **Standard Export**: Exports `bitcoinService` constant
- ✅ **Resource Cleanup**: Complete cache clearing in `dispose()`
- ✅ **Environment Configuration**: Dev/prod API endpoint handling
- ✅ **Error Handling**: Comprehensive try-catch with retry logic
- ✅ **Caching Strategy**: LRU cache with size limits and cleanup
- ✅ **Performance Monitoring**: Winston logging for API calls and cache performance
- ✅ **Type Safety**: 100% TypeScript with proper interface definitions

The Bitcoin domain provides the critical blockchain integration that makes this project unique - enabling deterministic organism generation from real Bitcoin block data while maintaining high performance through intelligent caching and error handling.
