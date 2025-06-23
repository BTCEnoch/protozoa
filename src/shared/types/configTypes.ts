/** Service configuration interfaces (Template) */

export interface IServiceConfig { name: string; debug: boolean; monitoring: boolean }

export interface IEnvironmentConfig {
  mode: "development" | "production" | "test"
  apiUrls: Record<string, string>
  features: Record<string, boolean>
  debug: {
    enabled: boolean
    verbose: boolean
    performanceLogging: boolean
  }
}
