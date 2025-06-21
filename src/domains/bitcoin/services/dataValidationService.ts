import { createServiceLogger } from '@/shared/lib/logger'
import type { IDataValidationService } from '@/domains/bitcoin/interfaces/IDataValidationService'

export class DataValidationService implements IDataValidationService {
  static #instance: DataValidationService|null = null
  #log = createServiceLogger('DATA_VALIDATION')
  private constructor() {}
  static getInstance(){return this.#instance??(this.#instance=new DataValidationService())}
  validateBlockInfo(data: any): boolean {
    if(!data||!data.hash||!data.merkle_root){
      this.#log.error('Invalid block data', { error: 'Missing required fields', data });
      return false;
    }
    return true
  }
  validateInscription(content: string): boolean {
    const isValid = content.length>0 && content.startsWith('{')
    if(!isValid) this.#log.warn('Inscription content failed validation')
    return isValid
  }
  verifyMerkleProof(txId: string, proof: string[]): boolean {
    // Placeholder: actual merkle proof verification later
    return proof.length>0 && txId.length>0
  }
  dispose(){DataValidationService.#instance=null}
}
export const dataValidationService = DataValidationService.getInstance()
