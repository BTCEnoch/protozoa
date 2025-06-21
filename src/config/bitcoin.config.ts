/**
 * @fileoverview Bitcoin Protocol Configuration
 * @description Configuration for Bitcoin Ordinals Protocol integration
 * @author Protozoa Development Team
 * @version 1.0.0
 */

import { createServiceLogger } from "@/shared/lib/logger";

const logger = createServiceLogger("BitcoinConfig");

/**
 * Bitcoin network types
 */
export type BitcoinNetwork = "mainnet" | "testnet" | "regtest";

/**
 * API endpoint configuration
 */
export interface APIEndpoints {
  /** Base URL for the API */
  baseUrl: string;
  /** Block info endpoint pattern */
  blockInfo: string;
  /** Inscription content endpoint pattern */
  inscriptionContent: string;
  /** Rate limit per minute */
  rateLimit: number;
  /** Request timeout in milliseconds */
  timeout: number;
}

/**
 * Bitcoin protocol configuration
 */
export interface BitcoinProtocolConfig {
  /** Current network */
  network: BitcoinNetwork;
  /** API endpoints for different environments */
  api: {
    development: APIEndpoints;
    production: APIEndpoints;
  };
  /** Block validation settings */
  validation: {
    /** Minimum block height to consider */
    minBlockHeight: number;
    /** Maximum block height offset from current */
    maxBlockOffset: number;
    /** Enable block hash validation */
    validateBlockHash: boolean;
  };
  /** Caching configuration */
  cache: {
    /** Block data TTL in seconds */
    blockDataTTL: number;
    /** Inscription data TTL in seconds */
    inscriptionDataTTL: number;
    /** Maximum cache size in MB */
    maxCacheSize: number;
  };
  /** Retry configuration */
  retry: {
    /** Maximum retry attempts */
    maxAttempts: number;
    /** Base delay in milliseconds */
    baseDelay: number;
    /** Exponential backoff multiplier */
    backoffMultiplier: number;
  };
}

/**
 * Get current environment
 */
function getCurrentEnvironment(): "development" | "production" {
  return process.env.NODE_ENV === "production" ? "production" : "development";
}

/**
 * Default Bitcoin protocol configuration
 */
export const bitcoinProtocolConfig: BitcoinProtocolConfig = {
  network: (process.env.BITCOIN_NETWORK as BitcoinNetwork) || "mainnet",

  api: {
    development: {
      baseUrl: "https://ordinals.com",
      blockInfo: "/r/blockinfo/{blockNumber}",
      inscriptionContent: "/content/{inscriptionId}",
      rateLimit: 100, // requests per minute
      timeout: 30000, // 30 seconds
    },
    production: {
      baseUrl: '', // Relative URLs in production
      blockInfo: "/r/blockinfo/{blockNumber}",
      inscriptionContent: "/content/{inscriptionId}",
      rateLimit: 60, // requests per minute (more conservative)
      timeout: 10000, // 10 seconds
    },
  },

  validation: {
    minBlockHeight: 767430, // First Ordinals inscription block
    maxBlockOffset: 10, // Maximum blocks ahead of current tip
    validateBlockHash: true,
  },

  cache: {
    blockDataTTL: 3600, // 1 hour
    inscriptionDataTTL: 86400, // 24 hours
    maxCacheSize: 100, // 100 MB
  },

  retry: {
    maxAttempts: 3,
    baseDelay: 1000, // 1 second
    backoffMultiplier: 2,
  },
};

/**
 * Get API endpoints for current environment
 */
export function getAPIEndpoints(): APIEndpoints {
  const env = getCurrentEnvironment();
  const endpoints = bitcoinProtocolConfig.api[env];

  logger.info("Using API endpoints for environment", {
    environment: env,
    baseUrl: endpoints.baseUrl,
    rateLimit: endpoints.rateLimit,
  });

  return endpoints;
}

/**
 * Validate block number
 */
export function validateBlockNumber(blockNumber: number): boolean {
  const config = bitcoinProtocolConfig.validation;

  if (blockNumber < config.minBlockHeight) {
    logger.warn("Block number below minimum height", {
      blockNumber,
      minHeight: config.minBlockHeight,
    });
    return false;
  }

  // Note: Maximum validation would require current tip,
  // which should be checked by the service implementation
  return true;
}

/**
 * Validate inscription ID format
 */
export function validateInscriptionId(inscriptionId: string): boolean {
  // Basic inscription ID format validation
  // Format: <txid>i<index> (64-character hex + "i" + number)
  const inscriptionIdPattern = /^[a-fA-F0-9]{64}i\d+$/;

  if (!inscriptionIdPattern.test(inscriptionId)) {
    logger.warn("Invalid inscription ID format", { inscriptionId });
    return false;
  }

  return true;
}

/**
 * Get retry configuration
 */
export function getRetryConfig() {
  return bitcoinProtocolConfig.retry;
}

/**
 * Get cache configuration
 */
export function getCacheConfig() {
  return bitcoinProtocolConfig.cache;
}

/**
 * Format API URL with parameters
 */
export function formatAPIUrl(endpoint: string, params: Record<string, string>): string {
  let url = endpoint;

  Object.entries(params).forEach(([key, value]) => {
    url = url.replace(`{${key}}`, encodeURIComponent(value));
  });

  return url;
}

logger.info("Bitcoin protocol configuration loaded", {
  network: bitcoinProtocolConfig.network,
  environment: getCurrentEnvironment(),
});
