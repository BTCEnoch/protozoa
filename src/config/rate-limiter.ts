/**
 * @fileoverview Rate Limiting Utility
 * @description Rate limiting implementation for Bitcoin API calls
 * @author Protozoa Development Team
 * @version 1.0.0
 */

import { createServiceLogger } from "@/shared/lib/logger";

const logger = createServiceLogger("RateLimiter");

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
    logger.info("Rate limiter initialized", {
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

    // Check if we"re within the limit
    if (this.requestTimes.length < this.config.maxRequests) {
      this.requestTimes.push(now);
      logger.debug("Request allowed", {
        identifier: this.config.identifier,
        currentRequests: this.requestTimes.length,
        maxRequests: this.config.maxRequests,
      });
      return true;
    }

    logger.warn("Request rate limited", {
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
      logger.info("Waiting for rate limit to reset", {
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
    logger.info("Rate limiter reset", {
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
    identifier: "bitcoin-api'',
  });
}
