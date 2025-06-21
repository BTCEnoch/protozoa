/**
 * @fileoverview Bitcoin Service Interface Definition
 * @description Defines the contract for Bitcoin blockchain data services
 * @author Protozoa Development Team
 * @version 1.0.0
 */

/**
 * Configuration options for Bitcoin service initialization
 */
export interface BitcoinConfig {
  /** API base URL (dev vs production) */
  apiBaseUrl?: string;
  /** Enable LRU caching */
  enableCaching?: boolean;
  /** Cache size limit */
  cacheSize?: number;
  /** Cache TTL in milliseconds */
  cacheTTL?: number;
  /** Request timeout in milliseconds */
  requestTimeout?: number;
  /** Maximum retry attempts */
  maxRetries?: number;
  /** Rate limiting delay between requests (ms) */
  rateLimitDelay?: number;
}

/**
 * Bitcoin block information
 */
export interface BlockInfo {
  /** Block height/number */
  height: number;
  /** Block hash */
  hash: string;
  /** Previous block hash */
  previousblockhash: string;
  /** Merkle root */
  merkleroot: string;
  /** Block timestamp */
  time: number;
  /** Block difficulty */
  difficulty: number;
  /** Number of transactions */
  nTx: number;
  /** Block size in bytes */
  size: number;
  /** Block weight */
  weight: number;
}

/**
 * Inscription content data
 */
export interface InscriptionContent {
  /** Inscription ID */
  id: string;
  /** Content type (mime type) */
  contentType: string;
  /** Content data (base64 or string) */
  content: string;
  /** Content length in bytes */
  contentLength: number;
  /** Genesis transaction ID */
  genesis: string;
  /** Block height where inscribed */
  genesis_height: number;
}

/**
 * API response wrapper
 */
export interface ApiResponse<T> {
  /** Response data */
  data: T;
  /** Whether response came from cache */
  fromCache: boolean;
  /** Response timestamp */
  timestamp: number;
  /** Request duration in milliseconds */
  duration: number;
}

/**
 * Bitcoin service interface defining blockchain data operations
 * Provides caching and retry logic for Ordinals API interactions
 */
export interface IBitcoinService {
  /**
   * Initialize the Bitcoin service with configuration
   * @param config - Bitcoin service configuration
   */
  initialize(config?: BitcoinConfig): Promise<void>;

  /**
   * Fetch Bitcoin block information by height
   * @param blockHeight - Block height to fetch
   * @returns Promise resolving to block information
   */
  getBlockInfo(blockHeight: number): Promise<ApiResponse<BlockInfo>>;

  /**
   * Fetch inscription content by ID
   * @param inscriptionId - Inscription ID to fetch
   * @returns Promise resolving to inscription content
   */
  getInscriptionContent(inscriptionId: string): Promise<ApiResponse<InscriptionContent>>;

  /**
   * Get current Bitcoin blockchain height
   * @returns Promise resolving to current block height
   */
  getCurrentBlockHeight(): Promise<number>;

  /**
   * Clear all cached data
   */
  clearCache(): void;

  /**
   * Get cache statistics
   * @returns Cache performance metrics
   */
  getCacheStats(): CacheStats;

  /**
   * Get service performance metrics
   * @returns Bitcoin service metrics
   */
  getMetrics(): BitcoinMetrics;

  /**
   * Dispose of resources and cleanup
   */
  dispose(): void;
}

/**
 * Cache performance statistics
 */
export interface CacheStats {
  /** Total cache hits */
  hits: number;
  /** Total cache misses */
  misses: number;
  /** Cache hit rate percentage */
  hitRate: number;
  /** Current cache size */
  size: number;
  /** Maximum cache size */
  maxSize: number;
  /** Total cached items evicted */
  evictions: number;
}

/**
 * Bitcoin service performance metrics
 */
export interface BitcoinMetrics {
  /** Total API requests made */
  totalRequests: number;
  /** Total successful requests */
  successfulRequests: number;
  /** Total failed requests */
  failedRequests: number;
  /** Average response time in milliseconds */
  averageResponseTime: number;
  /** Current cache hit rate */
  cacheHitRate: number;
  /** Total retries performed */
  totalRetries: number;
  /** Rate limit violations */
  rateLimitViolations: number;
} 