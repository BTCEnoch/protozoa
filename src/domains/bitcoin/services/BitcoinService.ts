// src/domains/bitcoin/services/BitcoinService.ts
// BitcoinService implementation - Auto-generated stub
// Referenced from build_design.md Section 3

import { IBitcoinService } from '../types';
import { createServiceLogger } from '@/shared/lib/logger';

/**
 * BitcoinService – manages bitcoin domain operations.
 * Auto-generated stub following .cursorrules singleton pattern.
 * TODO: Implement actual logic in Phase 3.
 */
class BitcoinService implements IBitcoinService {
  static #instance: BitcoinService | null = null;
  #log = createServiceLogger('BITCOIN_SERVICE');

  /**
   * Private constructor enforces singleton pattern.
   */
  private constructor() {
    this.#log.info('BitcoinService initialized');
  }

  /**
   * Singleton accessor - returns existing instance or creates new one.
   */
  public static getInstance(): BitcoinService {
    if (!BitcoinService.#instance) {
      BitcoinService.#instance = new BitcoinService();
    }
    return BitcoinService.#instance;
  }

  // TODO: Implement interface methods here

  /**
   * Disposes of service resources and resets singleton instance.
   */
  public dispose(): void {
    this.#log.info('BitcoinService disposed');
    BitcoinService.#instance = null;
  }
}

// Singleton export as required by .cursorrules
export const bitcoinService = BitcoinService.getInstance();
