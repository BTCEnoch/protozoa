# 22-SetupBitcoinProtocol.ps1 - Phase 1 Infrastructure Enhancement
# Configures Bitcoin network settings and API endpoint management for Ordinals Protocol
# ARCHITECTURE: Bitcoin Ordinals Protocol integration with environment-based configuration
# Reference: script_checklist.md lines 22-SetupBitcoinProtocol.ps1
# Reference: build_design.md lines 950-1000 - Bitcoin service implementation and API configuration
#Requires -Version 5.1

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $false)]
    [string]$ProjectRoot = (Split-Path $PSScriptRoot -Parent)
)

try {
    Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop
}
catch {
    Write-Error "Failed to import utilities module: $($_.Exception.Message)"
    exit 1
}

$ErrorActionPreference = "Stop"

try {
    Write-StepHeader "Bitcoin Protocol Configuration - Phase 1 Infrastructure Enhancement"
    Write-InfoLog "Configuring Bitcoin Ordinals Protocol integration and API endpoints"

    # Define paths
    $srcPath = Join-Path $ProjectRoot "src"
    $configPath = Join-Path $srcPath "config"
    $bitcoinConfigPath = Join-Path $configPath "bitcoin.config.ts"
    $envPath = Join-Path $ProjectRoot ".env"
    $envExamplePath = Join-Path $ProjectRoot ".env.example"

    # Create config directory
    New-Item -Path $configPath -ItemType Directory -Force | Out-Null
    Write-InfoLog "Created config directory"

    # Generate Bitcoin configuration file
    Write-InfoLog "Generating Bitcoin network configuration"
    $bitcoinConfig = @'
/**
 * @fileoverview Bitcoin Protocol Configuration
 * @description Configuration for Bitcoin Ordinals Protocol integration
 * @author Protozoa Development Team
 * @version 1.0.0
 */

import { createServiceLogger } from ''@/shared/lib/logger'';

const logger = createServiceLogger(''BitcoinConfig'');

/**
 * Bitcoin network types
 */
export type BitcoinNetwork = ''mainnet'' | ''testnet'' | ''regtest'';

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
function getCurrentEnvironment(): ''development'' | ''production'' {
  return process.env.NODE_ENV === ''production'' ? ''production'' : ''development'';
}

/**
 * Default Bitcoin protocol configuration
 */
export const bitcoinProtocolConfig: BitcoinProtocolConfig = {
  network: (process.env.BITCOIN_NETWORK as BitcoinNetwork) || ''mainnet'',

  api: {
    development: {
      baseUrl: ''https://ordinals.com'',
      blockInfo: ''/r/blockinfo/{blockNumber}'',
      inscriptionContent: ''/content/{inscriptionId}'',
      rateLimit: 100, // requests per minute
      timeout: 30000, // 30 seconds
    },
    production: {
      baseUrl: '''', // Relative URLs in production
      blockInfo: ''/r/blockinfo/{blockNumber}'',
      inscriptionContent: ''/content/{inscriptionId}'',
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

  logger.info(''Using API endpoints for environment'', {
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
    logger.warn(''Block number below minimum height'', {
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
  // Format: <txid>i<index> (64-character hex + ''i'' + number)
  const inscriptionIdPattern = /^[a-fA-F0-9]{64}i\d+$/;

  if (!inscriptionIdPattern.test(inscriptionId)) {
    logger.warn(''Invalid inscription ID format'', { inscriptionId });
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

logger.info(''Bitcoin protocol configuration loaded'', {
  network: bitcoinProtocolConfig.network,
  environment: getCurrentEnvironment(),
});
'@

    Set-Content -Path $bitcoinConfigPath -Value $bitcoinConfig -Encoding UTF8
    Write-SuccessLog "Bitcoin network configuration created"

    # Generate environment configuration
    Write-InfoLog "Generating environment configuration files"
    $envExample = @'
# Bitcoin Protocol Configuration
BITCOIN_NETWORK=mainnet
NODE_ENV=development

# API Configuration
ORDINALS_API_BASE_URL=https://ordinals.com
ORDINALS_API_RATE_LIMIT=100
ORDINALS_API_TIMEOUT=30000

# Caching Configuration
BLOCK_CACHE_TTL=3600
INSCRIPTION_CACHE_TTL=86400
MAX_CACHE_SIZE_MB=100

# Validation Configuration
MIN_BLOCK_HEIGHT=767430
MAX_BLOCK_OFFSET=10
VALIDATE_BLOCK_HASH=true

# Retry Configuration
MAX_RETRY_ATTEMPTS=3
BASE_RETRY_DELAY=1000
RETRY_BACKOFF_MULTIPLIER=2

# Logging Configuration
LOG_LEVEL=info
LOG_FILE_PATH=./logs/bitcoin-service.log

# Development Configuration
ENABLE_MOCK_DATA=false
MOCK_DELAY_MS=500
'@

    Set-Content -Path $envExamplePath -Value $envExample -Encoding UTF8
    Write-SuccessLog "Environment example file created"

    # Create .env file if it doesn't exist
    if (-not (Test-Path $envPath)) {
        Write-InfoLog "Creating .env file from example"
        Copy-Item -Path $envExamplePath -Destination $envPath
        Write-SuccessLog ".env file created from example"
    } else {
        Write-InfoLog ".env file already exists - skipping creation"
    }

    # Create rate limiting utility
    Write-InfoLog "Creating rate limiting utility"
    $rateLimitUtilPath = Join-Path $configPath "rate-limiter.ts"
    $rateLimitUtil = @'
/**
 * @fileoverview Rate Limiting Utility
 * @description Rate limiting implementation for Bitcoin API calls
 * @author Protozoa Development Team
 * @version 1.0.0
 */

import { createServiceLogger } from ''@/shared/lib/logger'';

const logger = createServiceLogger(''RateLimiter'');

/**
 * Rate limiter configuration
 */
interface RateLimiterConfig {
  /** Maximum requests per window */
  maxRequests: number;
  /** Window duration in milliseconds */
  windowMs: number;
  /** Identifier for the rate limiter */
  identifier: string;
}

/**
 * Rate limiter implementation
 */
export class RateLimiter {
  private requestTimes: number[] = [];
  private config: RateLimiterConfig;

  constructor(config: RateLimiterConfig) {
    this.config = config;
    logger.info(''Rate limiter initialized'', {
      identifier: config.identifier,
      maxRequests: config.maxRequests,
      windowMs: config.windowMs,
    });
  }

  /**
   * Check if request is allowed
   * @returns Promise<boolean> - True if request is allowed
   */
  async isAllowed(): Promise<boolean> {
    const now = Date.now();
    const windowStart = now - this.config.windowMs;

    // Remove old requests outside the window
    this.requestTimes = this.requestTimes.filter(time => time > windowStart);

    // Check if we''re within the limit
    if (this.requestTimes.length < this.config.maxRequests) {
      this.requestTimes.push(now);
      logger.debug(''Request allowed'', {
        identifier: this.config.identifier,
        currentRequests: this.requestTimes.length,
        maxRequests: this.config.maxRequests,
      });
      return true;
    }

    logger.warn(''Request rate limited'', {
      identifier: this.config.identifier,
      currentRequests: this.requestTimes.length,
      maxRequests: this.config.maxRequests,
      windowMs: this.config.windowMs,
    });
    return false;
  }

  /**
   * Get time until next request is allowed
   * @returns number - Milliseconds until next request
   */
  getTimeUntilNextRequest(): number {
    if (this.requestTimes.length < this.config.maxRequests) {
      return 0;
    }

    const oldestRequest = this.requestTimes[0];
    const timeUntilOldestExpires = (oldestRequest + this.config.windowMs) - Date.now();
    return Math.max(0, timeUntilOldestExpires);
  }

  /**
   * Wait until next request is allowed
   */
  async waitForNextRequest(): Promise<void> {
    const waitTime = this.getTimeUntilNextRequest();
    if (waitTime > 0) {
      logger.info(''Waiting for rate limit to reset'', {
        identifier: this.config.identifier,
        waitTimeMs: waitTime,
      });
      await new Promise(resolve => setTimeout(resolve, waitTime));
    }
  }

  /**
   * Reset the rate limiter
   */
  reset(): void {
    this.requestTimes = [];
    logger.info(''Rate limiter reset'', {
      identifier: this.config.identifier,
    });
  }
}

/**
 * Create rate limiter for Bitcoin API
 */
export function createBitcoinAPIRateLimiter(maxRequestsPerMinute: number): RateLimiter {
  return new RateLimiter({
    maxRequests: maxRequestsPerMinute,
    windowMs: 60000, // 1 minute
    identifier: ''bitcoin-api'',
  });
}
'@

    Set-Content -Path $rateLimitUtilPath -Value $rateLimitUtil -Encoding UTF8
    Write-SuccessLog "Rate limiting utility created"

    Write-InfoLog "Bitcoin Protocol configuration completed"

    exit 0
}
catch {
    Write-ErrorLog "Bitcoin Protocol configuration failed: $($_.Exception.Message)"
    exit 1
}
finally {
    try { Pop-Location -ErrorAction SilentlyContinue } catch { }
}