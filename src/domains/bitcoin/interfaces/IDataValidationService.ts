/**
* IDataValidationService – validates block info, inscriptions and merkle proofs.
*/
export interface IDataValidationService {
  validateBlockInfo(data: unknown): boolean
  validateInscription(content: string): boolean
  verifyMerkleProof(txId: string, proof: string[]): boolean
  dispose(): void
}
