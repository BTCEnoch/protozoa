/**
 * @fileoverview EnvironmentService (Template) â€“ centralised env / feature flag utility.
 * @module @/shared/config/environmentService
 * @version 1.0.0
 */

import { getMode, isDev, isProd, isTest } from "@/shared/config/envUtils"
import { createServiceLogger } from "@/shared/lib/logger"

export type EnvironmentMode = "development" | "production" | "test"

export interface DebugConfig {
  enabled: boolean
  verbose: boolean
  performanceLogging: boolean
}

export interface ApiUrls {
  bitcoin: string
  ordinals: string
}

export interface IEnvironmentConfig {
  mode: EnvironmentMode
  apiUrls: ApiUrls
  features: Record<string, boolean>
  debug: DebugConfig
}

class EnvironmentService {
  static #instance: EnvironmentService | null = null
  public static getInstance(): EnvironmentService {
    return this.#instance ?? (this.#instance = new EnvironmentService())
  }

  private constructor() {
    this.#logger.info("EnvironmentService initialised", { mode: this.#config.mode })
  }

  #logger = createServiceLogger("ENV_SERVICE")
  #config: IEnvironmentConfig = this.#load()

  /* --------------------------- private helpers --------------------------- */
  #load(): IEnvironmentConfig {
    const mode = getMode()
    const apiBase = mode === "production" ? "" : "https://ordinals.com"
    return {
      mode,
      apiUrls: {
        bitcoin: apiBase,
        ordinals: apiBase
      },
      features: {
        debugLogging: isDev(),
        performanceMonitoring: true,
        caching: true
      },
      debug: {
        enabled: mode !== "production",
        verbose: isDev(),
        performanceLogging: mode !== "test"
      }
    }
  }

  /* ----------------------------- public API ------------------------------ */
  getMode(): EnvironmentMode { return this.#config.mode }
  isDevelopment(): boolean { return isDev() }
  isProduction(): boolean { return isProd() }
  isTest(): boolean { return isTest() }
  getApiUrl(service: keyof ApiUrls): string { return this.#config.apiUrls[service] }
  isFeatureEnabled(feature: string): boolean { return !!this.#config.features[feature] }
  getDebugConfig(): DebugConfig { return { ...this.#config.debug } }
}

export const environmentService = EnvironmentService.getInstance()
export { EnvironmentService }
