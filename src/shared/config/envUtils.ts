/** Utility helpers for environment detection (Template) */

export type Mode = "development" | "production" | "test"

export function getMode(): Mode {
  if (typeof process !== "undefined" && process.env.NODE_ENV) {
    const env = process.env.NODE_ENV.toLowerCase()
    if (env === "production") return "production"
    if (env === "test") return "test"
  }
  if (typeof import.meta !== "undefined" && (import.meta as any).env) {
    const vite = (import.meta as any).env.MODE?.toLowerCase()
    if (vite === "production") return "production"
    if (vite === "test") return "test"
  }
  return "development"
}

export const isDev = () => getMode() === "development"
export const isProd = () => getMode() === "production"
export const isTest = () => getMode() === "test"
