// src/shared/config/environment.ts
// Environment-specific configuration service
// Referenced from build_checklist.md Phase 1 requirements

interface EnvironmentConfig {
  apiBaseUrl: string;
  isProduction: boolean;
  isDebug: boolean;
  logLevel: string;
}

function detectEnvironment(): EnvironmentConfig {
  const isDev = process.env.NODE_ENV === 'development';
  const isProd = process.env.NODE_ENV === 'production';

  return {
    apiBaseUrl: isDev ? 'https://ordinals.com' : '',
    isProduction: isProd,
    isDebug: process.env.VITE_DEBUG === 'true' || isDev,
    logLevel: process.env.LOG_LEVEL || (isDev ? 'debug' : 'info')
  };
}

export const config = detectEnvironment();

export function getApiBaseUrl(): string {
  return config.apiBaseUrl;
}

export function isProduction(): boolean {
  return config.isProduction;
}

export function isDebugMode(): boolean {
  return config.isDebug;
}
