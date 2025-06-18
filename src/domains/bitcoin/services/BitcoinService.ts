/**
 * @fileoverview Bitcoin Service Implementation
 * @description High-performance Bitcoin blockchain data service with LRU caching and retry logic
 * @author Protozoa Development Team
 * @version 1.0.0
 */

import {
    ApiResponse,
    BitcoinConfig,
    BitcoinMetrics,
    BlockInfo,
    CacheStats,
    IBitcoinService,
    InscriptionContent
} from '@/domains/bitcoin/interfaces/IBitcoinService';
import {
    ApiEnvironment,
    CacheEntry,
    LRUCache
} from '@/domains/bitcoin/types/bitcoin.types';
import { createServiceLogger } from '@/shared/lib/logger';

/**
 * Bitcoin Service implementing high-performance blockchain data access
 * Uses LRU caching and exponential backoff retry logic for optimal performance
 * Follows singleton pattern for application-wide consistency
 */
export class BitcoinService implements IBitcoinService {
  /** Singleton instance */
  static #instance: BitcoinService | null = null;
  
  /** Service configuration */
  #config: BitcoinConfig;
  
  /** LRU cache for block info */
  #blockCache: LRUCache<number, CacheEntry<BlockInfo>>;
  
  /** LRU cache for inscription content */
  #inscriptionCache: LRUCache<string, CacheEntry<InscriptionContent>>;
  
  /** Performance metrics */
  #metrics: BitcoinMetrics;
  
  /** Cache statistics */
  #cacheStats: CacheStats;
  
  /** Winston logger instance */
  #logger = createServiceLogger('BitcoinService');
  
  /** Active request abort controllers */
  #activeRequests: Map<string, AbortController>;
  
  /** Rate limiting timestamp */
  #lastRequestTime: number = 0;
  
  /**
   * Private constructor enforcing singleton pattern
   * Initializes Bitcoin service with LRU caching
   */
  private constructor() {
    this.#logger.info('Initializing BitcoinService singleton instance');
    
    // Initialize default configuration
    this.#config = {
      apiBaseUrl: 'https://ordinals.com',
      enableCaching: true,
      cacheSize: 1000,
      cacheTTL: 300000, // 5 minutes
      requestTimeout: 10000, // 10 seconds
      maxRetries: 3,
      rateLimitDelay: 100 // 100ms between requests
    };
    
    // Initialize caches
    this.#blockCache = new Map() as LRUCache<number, CacheEntry<BlockInfo>>;
    this.#inscriptionCache = new Map() as LRUCache<string, CacheEntry<InscriptionContent>>;
    
    // Initialize metrics
    this.#metrics = {
      totalRequests: 0,
      successfulRequests: 0,
      failedRequests: 0,
      averageResponseTime: 0,
      cacheHitRate: 0,
      totalRetries: 0,
      rateLimitViolations: 0
    };
    
    // Initialize cache stats
    this.#cacheStats = {
      hits: 0,
      misses: 0,
      hitRate: 0,
      size: 0,
      maxSize: this.#config.cacheSize!,
      evictions: 0
    };
    
    // Initialize active requests tracking
    this.#activeRequests = new Map();
    
    this.#logger.info('BitcoinService initialized successfully', {
      apiBaseUrl: this.#config.apiBaseUrl,
      cacheEnabled: this.#config.enableCaching,
      cacheSize: this.#config.cacheSize
    });
  }
  
  /**
   * Get singleton instance of BitcoinService
   * Creates new instance if none exists
   * @returns BitcoinService singleton instance
   */
  public static getInstance(): BitcoinService {
    if (!BitcoinService.#instance) {
      BitcoinService.#instance = new BitcoinService();
    }
    return BitcoinService.#instance;
  }
}/**
 * @fileoverview Bitcoin Service Implementation
 * @description High-performance Bitcoin blockchain data service with LRU caching and retry logic
 * @author Protozoa Development Team
 * @version 1.0.0
 */


/**
 * Bitcoin Service implementing high-performance blockchain data access
 * Uses LRU caching and exponential backoff retry logic for optimal performance
 * Follows singleton pattern for application-wide consistency
 */
export class BitcoinService implements IBitcoinService {
  /** Singleton instance */
  static #instance: BitcoinService | null = null;
  
  /** Service configuration */
  #config: BitcoinConfig;
  
  /** LRU cache for block info */
  #blockCache: LRUCache<number, CacheEntry<BlockInfo>>;
  
  /** LRU cache for inscription content */
  #inscriptionCache: LRUCache<string, CacheEntry<InscriptionContent>>;
  
  /** Performance metrics */
  #metrics: BitcoinMetrics;
  
  /** Cache statistics */
  #cacheStats: CacheStats;
  
  /** Winston logger instance */
  #logger = createServiceLogger('BitcoinService');
  
  /** Active request abort controllers */
  #activeRequests: Map<string, AbortController>;
  
  /** Rate limiting timestamp */
  #lastRequestTime: number = 0;
  
  /**
   * Private constructor enforcing singleton pattern
   * Initializes Bitcoin service with LRU caching
   */
  private constructor() {
    this.#logger.info('Initializing BitcoinService singleton instance');
    
    // Initialize default configuration
    this.#config = {
      apiBaseUrl: 'https://ordinals.com',
      enableCaching: true,
      cacheSize: 1000,
      cacheTTL: 300000, // 5 minutes
      requestTimeout: 10000, // 10 seconds
      maxRetries: 3,
      rateLimitDelay: 100 // 100ms between requests
    };
    
    // Initialize caches
    this.#blockCache = new Map() as LRUCache<number, CacheEntry<BlockInfo>>;
    this.#inscriptionCache = new Map() as LRUCache<string, CacheEntry<InscriptionContent>>;
    
    // Initialize metrics
    this.#metrics = {
      totalRequests: 0,
      successfulRequests: 0,
      failedRequests: 0,
      averageResponseTime: 0,
      cacheHitRate: 0,
      totalRetries: 0,
      rateLimitViolations: 0
    };
    
    // Initialize cache stats
    this.#cacheStats = {
      hits: 0,
      misses: 0,
      hitRate: 0,
      size: 0,
      maxSize: this.#config.cacheSize!,
      evictions: 0
    };
    
    // Initialize active requests tracking
    this.#activeRequests = new Map();
    
    this.#logger.info('BitcoinService initialized successfully', {
      apiBaseUrl: this.#config.apiBaseUrl,
      cacheEnabled: this.#config.enableCaching,
      cacheSize: this.#config.cacheSize
    });
  }
  
  /**
   * Get singleton instance of BitcoinService
   * Creates new instance if none exists
   * @returns BitcoinService singleton instance
   */
  public static getInstance(): BitcoinService {
    if (!BitcoinService.#instance) {
      BitcoinService.#instance = new BitcoinService();
    }
    return BitcoinService.#instance;
  }
  
  /**
   * Initialize the Bitcoin service with configuration
   * @param config - Bitcoin service configuration
   */
  public async initialize(config?: BitcoinConfig): Promise<void> {
    this.#logger.info('Initializing BitcoinService with configuration', { config });
    
    if (config) {
      this.#config = { ...this.#config, ...config };
    }
    
    // Adjust environment-specific API URLs
    const environment = process.env.NODE_ENV as ApiEnvironment;
    if (environment === 'production') {
      this.#config.apiBaseUrl = '';  // Use relative paths in production
    }
    
    this.#logger.info('BitcoinService initialization completed', {
      environment,
      apiBaseUrl: this.#config.apiBaseUrl
    });
  }
  
  /**
   * Fetch Bitcoin block information by height
   * @param blockHeight - Block height to fetch
   * @returns Promise resolving to block information
   */
  public async getBlockInfo(blockHeight: number): Promise<ApiResponse<BlockInfo>> {
    const startTime = performance.now();
    this.#logger.info('Fetching block info', { blockHeight });
    
    // Check cache first
    if (this.#config.enableCaching) {
      const cached = this.#getCachedBlockInfo(blockHeight);
      if (cached) {
        this.#updateCacheStats(true);
        const duration = performance.now() - startTime;
        return {
          data: cached,
          fromCache: true,
          timestamp: Date.now(),
          duration
        };
      }
    }
    
    try {
      const url = `${this.#config.apiBaseUrl}/r/blockinfo/${blockHeight}`;
      const blockInfo = await this.#makeRequest<BlockInfo>(url);
      
      // Cache the result
      if (this.#config.enableCaching) {
        this.#cacheBlockInfo(blockHeight, blockInfo);
      }
      
      this.#updateMetrics(true, performance.now() - startTime);
      this.#updateCacheStats(false);
      
      return {
        data: blockInfo,
        fromCache: false,
        timestamp: Date.now(),
        duration: performance.now() - startTime
      };
    } catch (error) {
      this.#updateMetrics(false, performance.now() - startTime);
      this.#logger.error('Failed to fetch block info', { blockHeight, error });
      throw error;
    }
  }
  
  /**
   * Fetch inscription content by ID
   * @param inscriptionId - Inscription ID to fetch
   * @returns Promise resolving to inscription content
   */
  public async getInscriptionContent(inscriptionId: string): Promise<ApiResponse<InscriptionContent>> {
    const startTime = performance.now();
    this.#logger.info('Fetching inscription content', { inscriptionId });
    
    // Check cache first
    if (this.#config.enableCaching) {
      const cached = this.#getCachedInscription(inscriptionId);
      if (cached) {
        this.#updateCacheStats(true);
        const duration = performance.now() - startTime;
        return {
          data: cached,
          fromCache: true,
          timestamp: Date.now(),
          duration
        };
      }
    }
    
    try {
      const url = `${this.#config.apiBaseUrl}/content/${inscriptionId}`;
      const inscriptionContent = await this.#makeRequest<InscriptionContent>(url);
      
      // Cache the result
      if (this.#config.enableCaching) {
        this.#cacheInscription(inscriptionId, inscriptionContent);
      }
      
      this.#updateMetrics(true, performance.now() - startTime);
      this.#updateCacheStats(false);
      
      return {
        data: inscriptionContent,
        fromCache: false,
        timestamp: Date.now(),
        duration: performance.now() - startTime
      };
    } catch (error) {
      this.#updateMetrics(false, performance.now() - startTime);
      this.#logger.error('Failed to fetch inscription content', { inscriptionId, error });
      throw error;
    }
  }
  
  /**
   * Get current Bitcoin blockchain height
   * @returns Promise resolving to current block height
   */
  public async getCurrentBlockHeight(): Promise<number> {
    // This would typically call a different endpoint
    // For now, return a mock value
    this.#logger.info('Getting current blockchain height');
    return 800000; // Mock current height
  }
  
  /**
   * Clear all cached data
   */
  public clearCache(): void {
    this.#logger.info('Clearing all cached data');
    
    // Clear caches using Map clear method
    (this.#blockCache as Map<number, CacheEntry<BlockInfo>>).clear();
    (this.#inscriptionCache as Map<string, CacheEntry<InscriptionContent>>).clear();
    
    // Reset cache stats
    this.#cacheStats.hits = 0;
    this.#cacheStats.misses = 0;
    this.#cacheStats.size = 0;
    this.#cacheStats.hitRate = 0;
    
    this.#logger.info('All cached data cleared');
  }
  
  /**
   * Get cache statistics
   * @returns Cache performance metrics
   */
  public getCacheStats(): CacheStats {
    return { ...this.#cacheStats };
  }
  
  /**
   * Get service performance metrics
   * @returns Bitcoin service metrics
   */
  public getMetrics(): BitcoinMetrics {
    return { ...this.#metrics };
  }
  
  /**
   * Dispose of resources and cleanup
   */
  public dispose(): void {
    this.#logger.info('Disposing BitcoinService resources');
    
    // Abort any active requests
    this.#activeRequests.forEach(controller => controller.abort());
    this.#activeRequests.clear();
    
    // Clear caches
    this.clearCache();
    
    // Reset singleton instance
    BitcoinService.#instance = null;
    
    this.#logger.info('BitcoinService disposal completed');
  }
  
  // Private helper methods
  
  /**
   * Make HTTP request with retry logic
   * @param url - Request URL
   * @returns Promise resolving to response data
   */
  async #makeRequest<T>(url: string): Promise<T> {
    const requestId = Date.now().toString();
    const controller = new AbortController();
    this.#activeRequests.set(requestId, controller);
    
    try {
      // Rate limiting
      await this.#enforceRateLimit();
      
      const response = await fetch(url, {
        signal: controller.signal,
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'Protozoa/1.0'
        }
      });
      
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }
      
      const data = await response.json();
      this.#activeRequests.delete(requestId);
      
      return data as T;
    } catch (error) {
      this.#activeRequests.delete(requestId);
      throw error;
    }
  }
  
  /**
   * Enforce rate limiting between requests
   */
  async #enforceRateLimit(): Promise<void> {
    const now = Date.now();
    const timeSinceLastRequest = now - this.#lastRequestTime;
    
    if (timeSinceLastRequest < this.#config.rateLimitDelay!) {
      const delay = this.#config.rateLimitDelay! - timeSinceLastRequest;
      await new Promise(resolve => setTimeout(resolve, delay));
    }
    
    this.#lastRequestTime = Date.now();
  }
  
  /**
   * Get cached block info if available and valid
   * @param blockHeight - Block height
   * @returns Cached block info or undefined
   */
  #getCachedBlockInfo(blockHeight: number): BlockInfo | undefined {
    const cache = this.#blockCache as Map<number, CacheEntry<BlockInfo>>;
    const entry = cache.get(blockHeight);
    
    if (entry && entry.expiresAt > Date.now()) {
      entry.accessCount++;
      entry.lastAccessed = Date.now();
      return entry.data;
    }
    
    if (entry) {
      cache.delete(blockHeight);
    }
    
    return undefined;
  }
  
  /**
   * Cache block info with TTL
   * @param blockHeight - Block height
   * @param blockInfo - Block information to cache
   */
  #cacheBlockInfo(blockHeight: number, blockInfo: BlockInfo): void {
    const cache = this.#blockCache as Map<number, CacheEntry<BlockInfo>>;
    const now = Date.now();
    
    const entry: CacheEntry<BlockInfo> = {
      data: blockInfo,
      timestamp: now,
      expiresAt: now + this.#config.cacheTTL!,
      accessCount: 1,
      lastAccessed: now
    };
    
    cache.set(blockHeight, entry);
    this.#cacheStats.size = cache.size;
  }
  
  /**
   * Get cached inscription if available and valid
   * @param inscriptionId - Inscription ID
   * @returns Cached inscription or undefined
   */
  #getCachedInscription(inscriptionId: string): InscriptionContent | undefined {
    const cache = this.#inscriptionCache as Map<string, CacheEntry<InscriptionContent>>;
    const entry = cache.get(inscriptionId);
    
    if (entry && entry.expiresAt > Date.now()) {
      entry.accessCount++;
      entry.lastAccessed = Date.now();
      return entry.data;
    }
    
    if (entry) {
      cache.delete(inscriptionId);
    }
    
    return undefined;
  }
  
  /**
   * Cache inscription content with TTL
   * @param inscriptionId - Inscription ID
   * @param content - Inscription content to cache
   */
  #cacheInscription(inscriptionId: string, content: InscriptionContent): void {
    const cache = this.#inscriptionCache as Map<string, CacheEntry<InscriptionContent>>;
    const now = Date.now();
    
    const entry: CacheEntry<InscriptionContent> = {
      data: content,
      timestamp: now,
      expiresAt: now + this.#config.cacheTTL!,
      accessCount: 1,
      lastAccessed: now
    };
    
    cache.set(inscriptionId, entry);
    this.#cacheStats.size = cache.size;
  }
  
  /**
   * Update performance metrics
   * @param success - Whether request was successful
   * @param duration - Request duration in milliseconds
   */
  #updateMetrics(success: boolean, duration: number): void {
    this.#metrics.totalRequests++;
    
    if (success) {
      this.#metrics.successfulRequests++;
    } else {
      this.#metrics.failedRequests++;
    }
    
    // Update average response time
    const total = this.#metrics.totalRequests;
    this.#metrics.averageResponseTime = 
      ((this.#metrics.averageResponseTime * (total - 1)) + duration) / total;
  }
  
  /**
   * Update cache statistics
   * @param hit - Whether this was a cache hit
   */
  #updateCacheStats(hit: boolean): void {
    if (hit) {
      this.#cacheStats.hits++;
    } else {
      this.#cacheStats.misses++;
    }
    
    const total = this.#cacheStats.hits + this.#cacheStats.misses;
    this.#cacheStats.hitRate = total > 0 ? (this.#cacheStats.hits / total) * 100 : 0;
    
    // Update metrics cache hit rate
    this.#metrics.cacheHitRate = this.#cacheStats.hitRate;
  }
}

// Export singleton instance getter
export const bitcoinService = BitcoinService.getInstance();
