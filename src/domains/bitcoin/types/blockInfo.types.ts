/**
 * @fileoverview Bitcoin BlockInfo Type Definition
 * @description Standalone BlockInfo interface for external domain consumption
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