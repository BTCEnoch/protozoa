/**
 * @fileoverview Bitcoin Types Definition
 * @description Type definitions for Bitcoin blockchain integration domain
 * @author Protozoa Development Team
 * @version 1.0.0
 */

/**
 * API environment types
 */
export type ApiEnvironment = "development" | "production";

/**
 * Request method types
 */
export type HttpMethod = "GET" | "POST" | "PUT" | "DELETE";

/**
 * Cache entry for LRU cache
 */
export interface CacheEntry<T> {
  /** Cached data */
  data: T;
  /** Timestamp when cached */
  timestamp: number;
  /** TTL expiration time */
  expiresAt: number;
  /** Number of times accessed */
  accessCount: number;
  /** Last access timestamp */
  lastAccessed: number;
}

/**
 * LRU Cache implementation interface
 */
export interface LRUCache<K, V> {
  /** Get value by key */
  get(key: K): V | undefined;
  /** Set key-value pair */
  set(key: K, value: V): void;
  /** Check if key exists */
  has(key: K): boolean;
  /** Delete by key */
  delete(key: K): boolean;
  /** Clear all entries */
  clear(): void;
  /** Get current size */
  size(): number;
  /** Get all keys */
  keys(): K[];
}

/**
 * Retry configuration
 */
export interface RetryConfig {
  /** Maximum retry attempts */
  maxAttempts: number;
  /** Initial delay in milliseconds */
  initialDelay: number;
  /** Delay multiplier for exponential backoff */
  backoffMultiplier: number;
  /** Maximum delay cap in milliseconds */
  maxDelay: number;
  /** Jitter factor for randomizing delays */
  jitterFactor: number;
}

/**
 * HTTP request options
 */
export interface RequestOptions {
  /** Request method */
  method: HttpMethod;
  /** Request headers */
  headers?: Record<string, string>;
  /** Request timeout in milliseconds */
  timeout?: number;
  /** Retry configuration */
  retry?: RetryConfig;
  /** Whether to use cache */
  useCache?: boolean;
}

/**
 * API error types
 */
export type ApiErrorType =
  | "NETWORK_ERROR"
  | "TIMEOUT_ERROR"
  | "RATE_LIMIT_ERROR"
  | "NOT_FOUND_ERROR"
  | "VALIDATION_ERROR"
  | "SERVER_ERROR"
  | "UNKNOWN_ERROR";

/**
 * API error details
 */
export interface ApiError {
  /** Error type */
  type: ApiErrorType;
  /** Error message */
  message: string;
  /** HTTP status code if applicable */
  statusCode?: number;
  /** Original error */
  originalError?: Error;
  /** Request URL that failed */
  url?: string;
  /** Retry attempt number */
  attempt?: number;
}
