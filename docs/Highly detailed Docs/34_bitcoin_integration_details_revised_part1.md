# Bitcoin Integration Details - Part 1: Data Schema and API Integration

This document provides implementation details for the Bitcoin integration, building upon the architecture defined in [04_blockchain_integration.md](04_blockchain_integration.md) and [08_bitcoin_integration.md](08_bitcoin_integration.md).

## Bitcoin Block Data Schema

As specified in [08_bitcoin_integration.md](08_bitcoin_integration.md) (lines 56-59), our application will retrieve key Bitcoin block data:

```typescript
// Block data schema based on the Ordinals.com API response format
// Referenced from 08_bitcoin_integration.md (lines 56-59)
interface BitcoinBlockData {
  // Basic block information
  hash: string;           // Block hash
  height: number;         // Block number as specified in 08_bitcoin_integration.md
  nonce: number;          // Block nonce (primary seed for RNG) as specified in 08_bitcoin_integration.md
  time: number;           // Timestamp as specified in 08_bitcoin_integration.md
  
  // Confirmation data
  confirmations: number;  // Confirmation count (evolution trigger) as specified in 08_bitcoin_integration.md
}

// Simplified block data for storage efficiency
interface SimplifiedBlockData {
  hash: string;
  height: number;
  time: number;
  nonce: number;
  confirmations: number;
}
```

## API Integration

Following the data retrieval approach specified in [08_bitcoin_integration.md](08_bitcoin_integration.md) (lines 38-53):

```typescript
// Bitcoin API service
// Implementation of the approach defined in 08_bitcoin_integration.md (lines 38-53)
class BitcoinAPIService {
  // Use only the Ordinals.com API as specified in 08_bitcoin_integration.md
  private devEndpoint = 'https://ordinals.com/r/blockinfo';
  private prodEndpoint = '/r/blockinfo';
  private cache: Map<string, { data: any, timestamp: number }> = new Map();
  private cacheExpiry: number = 60000; // 1 minute cache for most data
  private confirmationCacheExpiry: number = 5000; // 5 seconds for confirmation data
  
  // Fetch block data by height
  // Implementation of fetchBlockInfo function from 08_bitcoin_integration.md (lines 41-52)
  async getBlockByHeight(height: number): Promise<BitcoinBlockData> {
    const cacheKey = `block-${height}`;
    
    // Check cache first
    const cached = this.cache.get(cacheKey);
    if (cached && Date.now() - cached.timestamp < this.cacheExpiry) {
      return cached.data;
    }
    
    try {
      // Use appropriate endpoint based on environment as shown in 08_bitcoin_integration.md
      const endpoint = process.env.NODE_ENV === 'development' 
        ? `${this.devEndpoint}/${height}`
        : `${this.prodEndpoint}/${height}`;
      
      const response = await fetch(endpoint);
      
      if (!response.ok) {
        throw new Error(`HTTP error ${response.status}`);
      }
      
      const blockData = await response.json();
      
      // Cache the result
      this.cache.set(cacheKey, {
        data: blockData,
        timestamp: Date.now()
      });
      
      return blockData;
    } catch (error) {
      console.error(`Failed to fetch block ${height}:`, error);
      throw new Error(`Failed to fetch block ${height}: ${error.message}`);
    }
  }
  
  // Get current block height
  async getCurrentBlockHeight(): Promise<number> {
    try {
      // Use the tip endpoint to get current height
      const endpoint = process.env.NODE_ENV === 'development' 
        ? `${this.devEndpoint}/tip/height`
        : `${this.prodEndpoint}/tip/height`;
      
      const response = await fetch(endpoint);
      
      if (!response.ok) {
        throw new Error(`HTTP error ${response.status}`);
      }
      
      const height = await response.text();
      return parseInt(height, 10);
    } catch (error) {
      console.error('Failed to fetch current block height:', error);
      throw new Error(`Failed to fetch current block height: ${error.message}`);
    }
  }
  
  // Get confirmations for a block
  async getConfirmations(blockHeight: number): Promise<number> {
    const cacheKey = `confirmations-${blockHeight}`;
    
    // Check cache first (shorter expiry for confirmations)
    const cached = this.cache.get(cacheKey);
    if (cached && Date.now() - cached.timestamp < this.confirmationCacheExpiry) {
      return cached.data;
    }
    
    try {
      const currentHeight = await this.getCurrentBlockHeight();
      const confirmations = currentHeight - blockHeight + 1;
      
      // Cache the result
      this.cache.set(cacheKey, {
        data: confirmations,
        timestamp: Date.now()
      });
      
      return confirmations;
    } catch (error) {
      console.error(`Failed to calculate confirmations for block ${blockHeight}:`, error);
      throw new Error(`Failed to calculate confirmations: ${error.message}`);
    }
  }
  
  // Clear cache
  clearCache(): void {
    this.cache.clear();
  }
  
  // Clear specific cache entry
  clearCacheEntry(key: string): void {
    this.cache.delete(key);
  }
}
```

## Mock Bitcoin Data for Testing

Following the development approach specified in [08_bitcoin_integration.md](08_bitcoin_integration.md) (lines 128-132):

```typescript
// Mock Bitcoin data generator for development and testing
// Based on the development environment approach in 08_bitcoin_integration.md (lines 128-132)
class MockBitcoinDataGenerator {
  private mockBlocks: Map<number, BitcoinBlockData> = new Map();
  private currentHeight: number = 800000; // Start with a realistic height
  private mockConfirmationSpeed: number = 1; // New block every second in mock mode
  private intervalId: number | null = null;
  
  constructor() {
    // Generate initial mock blocks
    for (let i = 0; i < 100; i++) {
      const height = this.currentHeight - i;
      this.mockBlocks.set(height, this.generateMockBlock(height));
    }
  }
  
  // Start mock blockchain progression
  startMockBlockchain(): void {
    if (this.intervalId !== null) return;
    
    this.intervalId = window.setInterval(() => {
      this.currentHeight++;
      const newBlock = this.generateMockBlock(this.currentHeight);
      this.mockBlocks.set(this.currentHeight, newBlock);
      
      // Dispatch event for new block
      window.dispatchEvent(new CustomEvent('mock-new-block', {
        detail: { height: this.currentHeight, block: newBlock }
      }));
      
    }, 1000 / this.mockConfirmationSpeed);
  }
  
  // Stop mock blockchain progression
  stopMockBlockchain(): void {
    if (this.intervalId !== null) {
      window.clearInterval(this.intervalId);
      this.intervalId = null;
    }
  }
  
  // Get mock block by height
  getBlockByHeight(height: number): BitcoinBlockData {
    if (this.mockBlocks.has(height)) {
      return this.mockBlocks.get(height)!;
    }
    
    // Generate if not exists
    if (height <= this.currentHeight) {
      const block = this.generateMockBlock(height);
      this.mockBlocks.set(height, block);
      return block;
    }
    
    throw new Error(`Block ${height} not found (current height: ${this.currentHeight})`);
  }
  
  // Get current mock block height
  getCurrentBlockHeight(): number {
    return this.currentHeight;
  }
  
  // Get confirmations for a block
  getConfirmations(blockHeight: number): number {
    return this.currentHeight - blockHeight + 1;
  }
  
  // Generate a mock block
  private generateMockBlock(height: number): BitcoinBlockData {
    // Use height as seed for deterministic randomness
    const seed = height;
    const random = this.seededRandom(seed);
    
    // Generate mock hash
    const hash = Array.from({ length: 64 }, () => {
      const chars = '0123456789abcdef';
      return chars.charAt(Math.floor(random() * chars.length));
    }).join('');
    
    // Generate mock nonce (important for our RNG)
    // This is critical as specified in 08_bitcoin_integration.md (line 56)
    const nonce = Math.floor(random() * 4294967296); // 32-bit integer
    
    return {
      hash,
      height,
      nonce,
      time: Math.floor(Date.now() / 1000) - (this.currentHeight - height) * 600, // ~10 min per block
      confirmations: this.currentHeight - height + 1
    };
  }
  
  // Seeded random number generator
  private seededRandom(seed: number): () => number {
    return function() {
      const x = Math.sin(seed++) * 10000;
      return x - Math.floor(x);
    };
  }
}
```

## Bitcoin Data Validation

Implementing validation for the Bitcoin data as part of the error handling approach mentioned in [08_bitcoin_integration.md](08_bitcoin_integration.md) (lines 174-176):

```typescript
// Bitcoin data validator
// Implements validation as part of the fallback strategies in 08_bitcoin_integration.md (lines 174-176)
class BitcoinDataValidator {
  // Validate block data
  validateBlockData(data: any): { valid: boolean; errors: string[] } {
    const errors: string[] = [];
    
    // Check required fields based on 08_bitcoin_integration.md (lines 56-59)
    const requiredFields = ['hash', 'height', 'time', 'nonce', 'confirmations'];
    for (const field of requiredFields) {
      if (data[field] === undefined) {
        errors.push(`Missing required field: ${field}`);
      }
    }
    
    // Validate hash format (64 hex characters)
    if (data.hash && !/^[0-9a-f]{64}$/.test(data.hash)) {
      errors.push('Invalid hash format');
    }
    
    // Validate height (positive integer)
    if (data.height !== undefined && (!Number.isInteger(data.height) || data.height < 0)) {
      errors.push('Invalid height: must be a positive integer');
    }
    
    // Validate nonce (32-bit unsigned integer)
    // Critical for RNG as specified in 08_bitcoin_integration.md (line 56)
    if (data.nonce !== undefined && 
        (!Number.isInteger(data.nonce) || data.nonce < 0 || data.nonce > 4294967295)) {
      errors.push('Invalid nonce: must be a 32-bit unsigned integer');
    }
    
    // Validate time (reasonable timestamp)
    if (data.time !== undefined) {
      const now = Math.floor(Date.now() / 1000);
      if (!Number.isInteger(data.time) || data.time < 1230768000 || data.time > now + 7200) {
        // 1230768000 is the Bitcoin genesis block timestamp
        // Allow up to 2 hours in the future for clock differences
        errors.push('Invalid time: must be a reasonable Unix timestamp');
      }
    }
    
    // Validate confirmations (positive integer)
    // Critical for evolution mechanics as specified in 08_bitcoin_integration.md (line 57)
    if (data.confirmations !== undefined && 
        (!Number.isInteger(data.confirmations) || data.confirmations < 1)) {
      errors.push('Invalid confirmations: must be a positive integer');
    }
    
    return {
      valid: errors.length === 0,
      errors
    };
  }
}
```
