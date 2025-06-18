import { execSync } from "child_process"
import { createServiceLogger } from "@/shared/lib/logger"

export class BundleAnalyzerService {
  static #instance: BundleAnalyzerService | null = null
  #log = createServiceLogger("BUNDLE_ANALYZER")

  private constructor() {}

  static getInstance() {
    return this.#instance ?? (this.#instance = new BundleAnalyzerService())
  }

  analyze() {
    this.#log.info("Running webpack-bundle-analyzer")
    execSync("npx webpack --profile --json > stats.json", { stdio: "inherit" })
    execSync("npx webpack-bundle-analyzer stats.json --mode static --no-open", { stdio: "inherit" })
  }

  dispose() {
    BundleAnalyzerService.#instance = null
  }
}

export const bundleAnalyzerService = BundleAnalyzerService.getInstance()
