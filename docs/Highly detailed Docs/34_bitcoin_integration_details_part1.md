# Bitcoin Integration Details - Part 1: Data Schema

## Bitcoin Block Data Schema

```typescript
// Block data schema
interface BitcoinBlockData {
  // Basic block information
  hash: string;           // Block hash
  height: number;         // Block height/number
  version: number;        // Block version
  previousblockhash: string; // Hash of previous block
  merkleroot: string;     // Merkle root of transactions
  time: number;           // Block timestamp
  nonce: number;          // Block nonce (used for RNG seeding)
  bits: string;           // Compact form of target
  difficulty: number;     // Block difficulty
  
  // Confirmation data
  confirmations: number;  // Number of confirmations
  
  // Transaction data (simplified)
  tx: string[];           // Array of transaction IDs
  
  // Additional data
  size: number;           // Block size in bytes
  weight: number;         // Block weight
  chainwork: string;      // Total chainwork in this block
}

// Simplified block data for storage efficiency
interface SimplifiedBlockData {
  hash: string;
  height: number;
  time: number;
  nonce: number;
  confirmations: number;
  difficulty: number;
}
```

## API Integration

```typescript
// Bitcoin API service
class BitcoinAPIService {
  private baseUrl: string = 'https://blockstream.info/api';
  private fallbackUrls: string[] = [
    'https://mempool.space/api',
    'https://api.blockcypher.com/v1/btc/main'
  ];
  private currentUrlIndex: number = 0;
  private cache: Map<string, { data: any, timestamp: number }> = new Map();
  private cacheExpiry: number = 60000; // 1 minute cache for most data
  private confirmationCacheExpiry: number = 5000; // 5 seconds for confirmation data
  
  // Fetch block data by height
  async getBlockByHeight(height: number): Promise<BitcoinBlockData> {
    const cacheKey = `block-${height}`;
    
    // Check cache first
    const cached = this.cache.get(cacheKey);
    if (cached && Date.now() - cached.timestamp < this.cacheExpiry) {
      return cached.data;
    }
    
    try {
      // Fetch block hash first
      const blockHash = await this.fetchWithRetry(`/block-height/${height}`);
      
      // Then fetch full block data
      const blockData = await this.fetchWithRetry(`/block/${blockHash}`);
      
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
      const height = await this.fetchWithRetry('/blocks/tip/height');
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
  
  // Fetch with retry and fallback
  private async fetchWithRetry(endpoint: string, retries: number = 3): Promise<any> {
    let lastError;
    
    for (let attempt = 0; attempt < retries; attempt++) {
      try {
        const url = `${this.getCurrentBaseUrl()}${endpoint}`;
        const response = await fetch(url);
        
        if (!response.ok) {
          throw new Error(`HTTP error ${response.status}`);
        }
        
        // Check if response is text or JSON
        const contentType = response.headers.get('content-type');
        if (contentType && contentType.includes('application/json')) {
          return await response.json();
        } else {
          return await response.text();
        }
      } catch (error) {
        lastError = error;
        
        // Try next API endpoint
        this.rotateBaseUrl();
        
        // Wait before retry (exponential backoff)
        await new Promise(resolve => setTimeout(resolve, Math.pow(2, attempt) * 100));
      }
    }
    
    throw lastError;
  }
  
  // Get current base URL
  private getCurrentBaseUrl(): string {
    return this.baseUrl;
  }
  
  // Rotate to next fallback URL
  private rotateBaseUrl(): void {
    this.currentUrlIndex = (this.currentUrlIndex + 1) % (this.fallbackUrls.length + 1);
    
    if (this.currentUrlIndex === 0) {
      this.baseUrl = 'https://blockstream.info/api';
    } else {
      this.baseUrl = this.fallbackUrls[this.currentUrlIndex - 1];
    }
    
    console.log(`Switched to API endpoint: ${this.baseUrl}`);
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

```typescript
// Mock Bitcoin data generator
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
  
  // Set mock confirmation speed (blocks per second)
  setMockConfirmationSpeed(blocksPerSecond: number): void {
    this.mockConfirmationSpeed = blocksPerSecond;
    
    // Restart interval if running
    if (this.intervalId !== null) {
      this.stopMockBlockchain();
      this.startMockBlockchain();
    }
  }
  
  // Generate a mock block
  private generateMockBlock(height: number): BitcoinBlockData {
    // Use height as seed for deterministic randomness
    const seed = height;
    const random = this.seededRandom(seed);
    
    // Generate mock hash (not cryptographically accurate)
    const hash = Array.from({ length: 64 }, () => {
      const chars = '0123456789abcdef';
      return chars.charAt(Math.floor(random() * chars.length));
    }).join('');
    
    // Generate mock previous hash
    const prevHash = height > 0 ? Array.from({ length: 64 }, () => {
      const chars = '0123456789abcdef';
      return chars.charAt(Math.floor(this.seededRandom(seed - 1)() * chars.length));
    }).join('') : '0'.repeat(64);
    
    // Generate mock nonce (important for our RNG)
    const nonce = Math.floor(random() * 4294967296); // 32-bit integer
    
    return {
      hash,
      height,
      version: 1,
      previousblockhash: prevHash,
      merkleroot: '0'.repeat(64),
      time: Math.floor(Date.now() / 1000) - (this.currentHeight - height) * 600, // ~10 min per block
      nonce,
      bits: '1d00ffff',
      difficulty: 1 + (height % 2016) / 2016 * 0.1, // Small difficulty variations
      confirmations: this.currentHeight - height + 1,
      tx: Array.from({ length: 10 + Math.floor(random() * 100) }, (_, i) => `tx-${height}-${i}`),
      size: 1000 + Math.floor(random() * 1000),
      weight: 4000 + Math.floor(random() * 4000),
      chainwork: '0'.repeat(64)
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

```typescript
// Bitcoin data validator
class BitcoinDataValidator {
  // Validate block data
  validateBlockData(data: any): { valid: boolean; errors: string[] } {
    const errors: string[] = [];
    
    // Check required fields
    const requiredFields = ['hash', 'height', 'time', 'nonce'];
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
    if (data.confirmations !== undefined && 
        (!Number.isInteger(data.confirmations) || data.confirmations < 1)) {
      errors.push('Invalid confirmations: must be a positive integer');
    }
    
    return {
      valid: errors.length === 0,
      errors
    };
  }
  
  // Validate block hash
  validateBlockHash(hash: string): boolean {
    // Check format (64 hex characters)
    return /^[0-9a-f]{64}$/.test(hash);
  }
  
  // Validate block height
  validateBlockHeight(height: number): boolean {
    // Check if positive integer
    return Number.isInteger(height) && height >= 0;
  }
  
  // Validate nonce
  validateNonce(nonce: number): boolean {
    // Check if 32-bit unsigned integer
    return Number.isInteger(nonce) && nonce >= 0 && nonce <= 4294967295;
  }
}
```
