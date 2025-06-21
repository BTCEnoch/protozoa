/**
 * Bitcoin Ordinals API Type Definitions
 * Auto-generated from template by 19-ConfigureAdvancedTypeScript.ps1
 * @see https://docs.ordinals.com/
 */

declare module 'bitcoin-ordinals' {
  export interface BlockInfo {
    hash: string
    height: number
    timestamp: number
    bits: number
    nonce: number
    difficulty: number
    merkle_root: string
    tx_count: number
    size: number
    weight: number
    previousblockhash?: string
    nextblockhash?: string
  }

  export interface InscriptionContent {
    content_type: string
    content_length: number
    content: string | ArrayBuffer
    inscription_id: string
    inscription_number: number
    address: string
    output_value: number
    preview: string
    timestamp: number
  }

  export interface OrdinalsApiResponse<T> {
    data: T
    status: 'success' | 'error'
    message?: string
  }
}

declare global {
  interface Window {
    // Bitcoin Ordinals global extensions
    bitcoin?: {
      ordinals: {
        getBlockInfo: (blockNumber: number) => Promise<any>
        getInscription: (inscriptionId: string) => Promise<any>
      }
    }
  }
}

export {}
