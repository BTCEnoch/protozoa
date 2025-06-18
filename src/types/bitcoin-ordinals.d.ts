/**
 * @fileoverview Bitcoin Ordinals API Type Definitions
 * @description Custom TypeScript definitions for Bitcoin Ordinals Protocol
 * @author Protozoa Development Team
 * @version 1.0.0
 */

declare namespace BitcoinOrdinals {
  interface BlockInfo {
    hash: string;
    height: number;
    timestamp: number;
    difficulty: number;
    nonce: number;
    merkleroot: string;
    previousblockhash?: string;
    nextblockhash?: string;
    size: number;
    weight: number;
    version: number;
    versionHex: string;
    bits: string;
    chainwork: string;
    nTx: number;
    mediantime: number;
  }

  interface InscriptionContent {
    content_type: string;
    content_length: number;
    content: string | ArrayBuffer;
    inscription_id: string;
    inscription_number: number;
    genesis_height: number;
    genesis_fee: number;
    output_value: number;
    address?: string;
    sat?: number;
    timestamp: number;
  }

  interface APIResponse<T> {
    success: boolean;
    data?: T;
    error?: string;
    timestamp: number;
  }
}

// Extend Window interface for browser environment
declare global {
  interface Window {
    BitcoinOrdinals?: any;
  }
}

export {};
