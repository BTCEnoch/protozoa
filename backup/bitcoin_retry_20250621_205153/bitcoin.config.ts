/** Bitcoin protocol configuration (Template) */
import { EnvironmentMode } from '@/shared/config/environmentService'

export interface BitcoinEndpoints { baseUrl: string; blockInfo: string; inscriptionContent: string }

export const getBitcoinEndpoints = (mode: EnvironmentMode): BitcoinEndpoints => ({
  baseUrl: mode === 'production' ? '' : 'https://ordinals.com',
  blockInfo: '/r/blockinfo/{blockNumber}',
  inscriptionContent: '/content/{inscriptionId}'
})