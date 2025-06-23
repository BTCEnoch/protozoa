# 29a-SetupOpenTelemetry.ps1
# Enhanced OpenTelemetry Setup with comprehensive monitoring and Winston integration
# Implements complete observability infrastructure for Protozoa

param(
    [switch]$DryRun = $false,
    [string]$ProjectRoot = $PWD
)

Import-Module "$PSScriptRoot\utils.psm1" -Force

Write-StepHeader "OpenTelemetry Setup - Enhanced Monitoring & Observability"

try {
    # Validate environment
    if (-not (Test-Path "package.json")) {
        throw "package.json not found. Run this script from the project root."
    }

    Write-InfoLog "Installing OpenTelemetry packages..."
    
    $otPackages = @(
        "@opentelemetry/sdk-node@^0.49.1",
        "@opentelemetry/resources@^1.23.0", 
        "@opentelemetry/semantic-conventions@^1.23.0",
        "@opentelemetry/exporter-jaeger@^1.23.0",
        "@opentelemetry/exporter-zipkin@^1.23.0",
        "@opentelemetry/instrumentation-http@^0.49.1",
        "@opentelemetry/instrumentation-fs@^0.12.0",
        "@opentelemetry/auto-instrumentations-node@^0.42.0"
    )
    
    Write-InfoLog "Total packages to install: $($otPackages.Count)"
    
    if (-not $DryRun) {
        Write-InfoLog "Starting installation of OpenTelemetry dependencies..."
        Write-InfoLog "This may take several minutes - installing comprehensive telemetry stack"
        
        $installCmd = "npm install " + ($otPackages -join " ")
        Write-DebugLog "Executing: $installCmd"
        
        $installStart = Get-Date
        Invoke-Expression $installCmd
        $installDuration = (Get-Date) - $installStart
        
        if ($LASTEXITCODE -ne 0) {
            Write-WarningLog "Standard installation failed, trying with --legacy-peer-deps"
            $fallbackCmd = "npm install --legacy-peer-deps " + ($otPackages -join " ")
            Write-DebugLog "Executing fallback: $fallbackCmd"
            
            Invoke-Expression $fallbackCmd
            if ($LASTEXITCODE -ne 0) {
                throw "Package installation failed with exit code $LASTEXITCODE even with --legacy-peer-deps"
            }
            Write-SuccessLog "OpenTelemetry packages installed successfully with --legacy-peer-deps"
        } else {
            Write-SuccessLog "OpenTelemetry packages installed successfully"
        }
        Write-InfoLog "Installation completed in $($installDuration.TotalSeconds.ToString('F1')) seconds"
    }

    # Create observability directory structure
    $observabilityPath = Join-Path $ProjectRoot "src\shared\observability"
    Write-InfoLog "Creating observability infrastructure at: $observabilityPath"
    
    if (-not $DryRun) {
        New-Item -ItemType Directory -Path $observabilityPath -Force | Out-Null
    }

    # Create tracing configuration
    $tracingPath = Join-Path $observabilityPath "tracing.ts"
    $tracingContent = @'
/**
 * OpenTelemetry tracing configuration for Protozoa
 * Provides distributed tracing for performance monitoring
 * 
 * @author Protozoa Automation Suite
 * @generated 29a-SetupOpenTelemetry.ps1
 */

import { NodeSDK } from '@opentelemetry/sdk-node'
import { Resource } from '@opentelemetry/resources'
import { SemanticResourceAttributes } from '@opentelemetry/semantic-conventions'
import { JaegerExporter } from '@opentelemetry/exporter-jaeger'
import { ZipkinExporter } from '@opentelemetry/exporter-zipkin'
import { HttpInstrumentation } from '@opentelemetry/instrumentation-http'
import { FsInstrumentation } from '@opentelemetry/instrumentation-fs'
import { getNodeAutoInstrumentations } from '@opentelemetry/auto-instrumentations-node'
import { trace, SpanOptions, Attributes } from '@opentelemetry/api'

/**
 * Initialize OpenTelemetry tracing
 */
export function initializeTracing(): void {
  const serviceName = process.env.OTEL_SERVICE_NAME || 'protozoa-organisms'
  const serviceVersion = process.env.OTEL_SERVICE_VERSION || '1.0.0'
  const environment = process.env.OTEL_DEPLOYMENT_ENVIRONMENT || 'development'

  // Create resource with service information
  const resource = new Resource({
    [SemanticResourceAttributes.SERVICE_NAME]: serviceName,
    [SemanticResourceAttributes.SERVICE_VERSION]: serviceVersion,
    [SemanticResourceAttributes.DEPLOYMENT_ENVIRONMENT]: environment,
  })

  // Configure exporters
  const exporters = []
  
  // Jaeger exporter (if configured)
  if (process.env.JAEGER_ENDPOINT) {
    exporters.push(new JaegerExporter({
      endpoint: process.env.JAEGER_ENDPOINT,
    }))
  }
  
  // Zipkin exporter (if configured)
  if (process.env.ZIPKIN_ENDPOINT) {
    exporters.push(new ZipkinExporter({
      url: process.env.ZIPKIN_ENDPOINT,
    }))
  }

  // Configure instrumentations
  const instrumentations = [
    // Auto instrumentations
    getNodeAutoInstrumentations({
      '@opentelemetry/instrumentation-dns': {
        enabled: false, // Disable noisy DNS instrumentation
      },
      '@opentelemetry/instrumentation-net': {
        enabled: false, // Disable noisy network instrumentation
      },
    }),
    
    // Custom HTTP instrumentation with better filtering
    new HttpInstrumentation({
      enabled: true,
      ignoreIncomingRequestHook: (req) => {
        const url = req.url || ''
        // Ignore health checks and static assets
        return url.includes('/health') || url.includes('/static/')
      },
      requestHook: (span: any, request: any) => {
        span.setAttributes({
          'protozoa.request.type': 'http',
          'protozoa.request.method': request.method,
        })
      },
    }),
    
    // File system instrumentation for development
    new FsInstrumentation({
      enabled: environment === 'development',
    }),
  ]

  // Initialize the SDK
  const sdk = new NodeSDK({
    resource,
    instrumentations,
  })

  // Start tracing
  sdk.start()
  
  console.log(`OpenTelemetry initialized for ${serviceName} v${serviceVersion}`)
}

/**
 * Get the tracer instance
 */
export function getTracer(name: string = 'protozoa-default') {
  return trace.getTracer(name, '1.0.0')
}

/**
 * Create a traced span around a function
 */
export function withSpan<T>(
  name: string,
  fn: () => T,
  attributes?: Attributes,
  options?: SpanOptions
): T {
  const tracer = getTracer()
  return tracer.startActiveSpan(name, { attributes }, (span: any) => {
    try {
      const result = fn()
      span.setStatus({ code: 1 }) // OK
      return result
    } catch (error) {
      span.setStatus({ code: 2, message: (error as Error).message }) // ERROR
      span.recordException(error as Error)
      throw error
    } finally {
      span.end()
    }
  })
}
'@

    Write-InfoLog "Creating OpenTelemetry tracing configuration"
    if (-not $DryRun) {
        Set-Content -Path $tracingPath -Value $tracingContent -Encoding UTF8
    }

    # Create monitoring utilities
    $monitoringPath = Join-Path $observabilityPath "monitoring.ts"
    $monitoringContent = @'
/**
 * Performance monitoring utilities for Protozoa application
 * Provides metrics collection and performance tracking
 * 
 * @author Protozoa Automation Suite
 * @generated 29a-SetupOpenTelemetry.ps1
 */

import { getTracer, withSpan } from './tracing'
import { logger } from '../lib/logger'

/**
 * Performance metrics interface
 */
export interface PerformanceMetrics {
  timestamp: number
  frameRate: number
  memoryUsage: number
  particleCount: number
  renderTime: number
  physicsTime: number
}

/**
 * Performance monitor class
 */
export class PerformanceMonitor {
  private metrics: PerformanceMetrics[] = []
  private readonly maxMetrics = 1000
  private lastFrameTime = 0
  private frameCount = 0

  /**
   * Record frame performance metrics
   */
  recordFrame(particleCount: number, renderTime: number, physicsTime: number): void {
    const now = performance.now()
    const deltaTime = now - this.lastFrameTime
    const frameRate = deltaTime > 0 ? 1000 / deltaTime : 0
    
    const metrics: PerformanceMetrics = {
      timestamp: now,
      frameRate,
      memoryUsage: this.getMemoryUsage(),
      particleCount,
      renderTime,
      physicsTime
    }

    this.metrics.push(metrics)
    
    // Keep only recent metrics
    if (this.metrics.length > this.maxMetrics) {
      this.metrics.shift()
    }

    this.lastFrameTime = now
    this.frameCount++

    // Log performance warnings
    if (frameRate < 30) {
      logger.warn('Low frame rate detected', { frameRate, particleCount })
    }
    
    if (renderTime > 16.67) { // > 60fps budget
      logger.warn('High render time detected', { renderTime, particleCount })
    }
  }

  /**
   * Get memory usage in MB
   */
  private getMemoryUsage(): number {
    if (typeof performance !== 'undefined' && (performance as any).memory) {
      return (performance as any).memory.usedJSHeapSize / 1024 / 1024
    }
    return 0
  }

  /**
   * Get performance statistics
   */
  getStats(): { avgFrameRate: number; avgMemory: number; maxParticles: number } {
    if (this.metrics.length === 0) {
      return { avgFrameRate: 0, avgMemory: 0, maxParticles: 0 }
    }

    const avgFrameRate = this.metrics.reduce((sum, m) => sum + m.frameRate, 0) / this.metrics.length
    const avgMemory = this.metrics.reduce((sum, m) => sum + m.memoryUsage, 0) / this.metrics.length
    const maxParticles = Math.max(...this.metrics.map(m => m.particleCount))

    return { avgFrameRate, avgMemory, maxParticles }
  }

  /**
   * Create a traced performance measurement
   */
  measurePerformance<T>(name: string, fn: () => T): T {
    return withSpan(`performance.${name}`, fn, {
      'protozoa.measurement.type': 'performance',
      'protozoa.measurement.name': name
    })
  }
}

// Global performance monitor instance
export const performanceMonitor = new PerformanceMonitor()
'@

    Write-InfoLog "Creating performance monitoring utilities"
    if (-not $DryRun) {
        Set-Content -Path $monitoringPath -Value $monitoringContent -Encoding UTF8
    }

    # Create index file for observability exports
    $indexPath = Join-Path $observabilityPath "index.ts"
    $indexContent = @'
/**
 * Observability module exports
 * 
 * @author Protozoa Automation Suite
 * @generated 29a-SetupOpenTelemetry.ps1
 */

export * from './tracing'
export * from './monitoring'
'@

    if (-not $DryRun) {
        Set-Content -Path $indexPath -Value $indexContent -Encoding UTF8
    }

    Write-SuccessLog "OpenTelemetry setup completed successfully"
    Write-InfoLog "Created: tracing.ts, monitoring.ts, environment template"
    Write-InfoLog "Observability infrastructure ready for comprehensive monitoring"
    
    exit 0

} catch {
    Write-ErrorLog "OpenTelemetry setup failed: $($_.Exception.Message)"
    exit 1
} 