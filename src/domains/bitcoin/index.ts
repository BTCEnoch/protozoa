/**
 * @fileoverview Bitcoin Domain Exports
 * @description Main export file for Bitcoin domain
 * @author Protozoa Development Team
 * @version 1.0.0
 */

// Service exports
export { BitcoinService, bitcoinService } from "./services/BitcoinService";

// Interface exports
export type {
  IBitcoinService,
  BitcoinConfig,
  BlockInfo,
  InscriptionContent,
  ApiResponse,
  CacheStats,
  BitcoinMetrics
} from "./interfaces/IBitcoinService";

// Type exports
export type {
  ApiEnvironment,
  HttpMethod,
  CacheEntry,
  LRUCache,
  RetryConfig,
  RequestOptions,
  ApiErrorType,
  ApiError
} from "./types/bitcoin.types";
