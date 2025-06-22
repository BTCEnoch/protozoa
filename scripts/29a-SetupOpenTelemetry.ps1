# 29a-SetupOpenTelemetry.ps1
# Installs OpenTelemetry libraries and patches Winston transport for OT span meta propagation
# Integrates observability infrastructure for comprehensive application monitoring  
# Usage: Executed by automation suite to enable telemetry and tracing capabilities

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $false)]
    [string]$ProjectRoot = (Split-Path $PSScriptRoot -Parent),

    [Parameter(Mandatory = $false)]
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

try {
    Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop
} catch {
    Write-Error "Failed to import utils module: $($_.Exception.Message)"
    exit 1
}

try {
    Write-StepHeader "Setup OpenTelemetry Integration (29)"
    Write-InfoLog "Installing OpenTelemetry packages and configuring tracing"

    # npm-only package manager approach
    $packageManager = "npm"
    Write-InfoLog "Using npm for package installation (pure npm approach)"

    # Install OpenTelemetry packages
    $otPackages = @(
        "@opentelemetry/api@^1.7.0",
        "@opentelemetry/sdk-node@^0.45.0", 
        "@opentelemetry/resources@^1.17.0",
        "@opentelemetry/semantic-conventions@^1.17.0",
        "@opentelemetry/exporter-jaeger@^1.17.0",
        "@opentelemetry/exporter-zipkin@^1.17.0",
        "@opentelemetry/instrumentation-http@^0.45.0",
        "@opentelemetry/instrumentation-fs@^0.8.0"
    )

    Write-InfoLog "Installing OpenTelemetry packages..."
    if (-not $DryRun) {
        $installCmd = "$packageManager add " + ($otPackages -join " ")
        Write-DebugLog "Executing: $installCmd"
        
        Invoke-Expression $installCmd
        if ($LASTEXITCODE -ne 0) {
            throw "Package installation failed with exit code $LASTEXITCODE"
        }
    }
    Write-SuccessLog "OpenTelemetry packages installed successfully"

    # Create observability directory
    $observabilityPath = Join-Path $ProjectRoot "src/shared/observability"
    if (-not (Test-Path $observabilityPath)) {
        Write-InfoLog "Creating observability directory"
        if (-not $DryRun) {
            New-Item -ItemType Directory -Path $observabilityPath -Force | Out-Null
        }
    }

    # Generate tracing configuration
    $tracingPath = Join-Path $observabilityPath "tracing.ts"
    $tracingContent = @'
/**
 * OpenTelemetry tracing configuration for Protozoa application
 * Provides comprehensive observability and performance monitoring
 * 
 * @author Protozoa Automation Suite
 * @generated 29-SetupOpenTelemetry.ps1
 */

import { NodeSDK } from '@opentelemetry/sdk-node'
import { Resource } from '@opentelemetry/resources'
import { SemanticResourceAttributes } from '@opentelemetry/semantic-conventions'
import { JaegerExporter } from '@opentelemetry/exporter-jaeger'
import { ZipkinExporter } from '@opentelemetry/exporter-zipkin'
import { HttpInstrumentation } from '@opentelemetry/instrumentation-http'
import { FsInstrumentation } from '@opentelemetry/instrumentation-fs'
import { getNodeAutoInstrumentations } from '@opentelemetry/auto-instrumentations-node'
import { logger } from '../lib/logger'

/**
 * Tracing configuration interface
 */
export interface TracingConfig {
  serviceName?: string
  serviceVersion?: string
  environment?: string
  jaegerEndpoint?: string
  zipkinEndpoint?: string
  enableConsoleExporter?: boolean
  enableFileSystem?: boolean
  sampleRate?: number
}

/**
 * Default tracing configuration
 */
const defaultConfig: TracingConfig = {
  serviceName: 'protozoa-organisms',
  serviceVersion: '1.0.0',
  environment: process.env.NODE_ENV || 'development',
  jaegerEndpoint: process.env.JAEGER_ENDPOINT || 'http://localhost:14268/api/traces',
  zipkinEndpoint: process.env.ZIPKIN_ENDPOINT || 'http://localhost:9411/api/v2/spans',
  enableConsoleExporter: process.env.NODE_ENV === 'development',
  enableFileSystem: false,
  sampleRate: parseFloat(process.env.OTEL_TRACE_SAMPLE_RATE || '1.0')
}

let sdk: NodeSDK | null = null

/**
 * Initialize OpenTelemetry tracing
 * @param config Optional tracing configuration
 */
export function initializeTracing(config: Partial<TracingConfig> = {}): void {
  const finalConfig = { ...defaultConfig, ...config }
  
  try {
    // Create resource with service information
    const resource = new Resource({
      [SemanticResourceAttributes.SERVICE_NAME]: finalConfig.serviceName!,
      [SemanticResourceAttributes.SERVICE_VERSION]: finalConfig.serviceVersion!,
      [SemanticResourceAttributes.DEPLOYMENT_ENVIRONMENT]: finalConfig.environment!,
    })

    // Configure exporters
    const exporters: any[] = []
    
    if (finalConfig.jaegerEndpoint) {
      exporters.push(new JaegerExporter({
        endpoint: finalConfig.jaegerEndpoint,
      }))
    }
    
    if (finalConfig.zipkinEndpoint) {
      exporters.push(new ZipkinExporter({
        url: finalConfig.zipkinEndpoint,
      }))
    }

    // Configure instrumentations
    const instrumentations = [
      new HttpInstrumentation({
        requestHook: (span, request) => {
          span.setAttributes({
            'protozoa.request.url': request.url || 'unknown',
            'protozoa.request.method': request.method || 'unknown'
          })
        }
      }),
      ...getNodeAutoInstrumentations({
        '@opentelemetry/instrumentation-fs': {
          enabled: finalConfig.enableFileSystem
        }
      })
    ]

    if (finalConfig.enableFileSystem) {
      instrumentations.push(new FsInstrumentation())
    }

    // Initialize SDK
    sdk = new NodeSDK({
      resource,
      traceExporter: exporters.length > 0 ? exporters[0] : undefined,
      instrumentations,
      sampler: {
        shouldSample: () => ({
          decision: Math.random() < finalConfig.sampleRate! ? 1 : 0,
          attributes: {}
        })
      } as any
    })

    sdk.start()
    
    logger.info('OpenTelemetry tracing initialized', {
      serviceName: finalConfig.serviceName,
      environment: finalConfig.environment,
      exporters: exporters.length,
      sampleRate: finalConfig.sampleRate
    })

  } catch (error) {
    logger.error('Failed to initialize OpenTelemetry tracing', { error })
    throw error
  }
}

/**
 * Shutdown tracing gracefully
 */
export async function shutdownTracing(): Promise<void> {
  if (sdk) {
    try {
      await sdk.shutdown()
      logger.info('OpenTelemetry tracing shut down successfully')
    } catch (error) {
      logger.error('Error shutting down OpenTelemetry tracing', { error })
    }
  }
}

/**
 * Get current tracer instance
 */
export function getTracer(name: string = 'protozoa-default') {
  const opentelemetry = require('@opentelemetry/api')
  return opentelemetry.trace.getTracer(name)
}

/**
 * Create a span for a function execution
 */
export function withSpan<T>(
  name: string,
  fn: () => T | Promise<T>,
  attributes?: Record<string, string | number | boolean>
): T | Promise<T> {
  const tracer = getTracer()
  
  return tracer.startActiveSpan(name, { attributes }, (span) => {
    try {
      const result = fn()
      
      if (result instanceof Promise) {
        return result
          .then((value) => {
            span.setStatus({ code: 1 }) // OK
            span.end()
            return value
          })
          .catch((error) => {
            span.recordException(error)
            span.setStatus({ code: 2, message: error.message }) // ERROR
            span.end()
            throw error
          })
      } else {
        span.setStatus({ code: 1 }) // OK
        span.end()
        return result
      }
    } catch (error) {
      span.recordException(error)
      span.setStatus({ code: 2, message: (error as Error).message }) // ERROR
      span.end()
      throw error
    }
  })
}

// Auto-initialize in Node.js environment
if (typeof window === 'undefined' && process.env.NODE_ENV !== 'test') {
  initializeTracing()
}
'@

    Write-InfoLog "Generating OpenTelemetry tracing configuration"
    if (-not $DryRun) {
        Set-Content -Path $tracingPath -Value $tracingContent -Encoding UTF8
    }
    Write-SuccessLog "Tracing configuration generated successfully"

    # Update logger to support OpenTelemetry spans
    $loggerPath = Join-Path $ProjectRoot "src/shared/lib/logger.ts"
    if (Test-Path $loggerPath) {
        Write-InfoLog "Patching logger for OpenTelemetry integration"
        
        $loggerContent = Get-Content $loggerPath -Raw
        
        # Check if already patched
        if ($loggerContent -notmatch 'opentelemetry') {
            $patchedContent = $loggerContent -replace 'export class UniversalLogger', @'
import { trace, context } from '@opentelemetry/api'

export class UniversalLogger'@
            
            $patchedContent = $patchedContent -replace 'log\(level: LogLevel, message: string, meta\?: LogMeta\): void \{', @'
log(level: LogLevel, message: string, meta?: LogMeta): void {
    // Add OpenTelemetry span context if available
    const span = trace.getActiveSpan()
    if (span) {
      const spanContext = span.spanContext()
      meta = { 
        ...meta, 
        traceId: spanContext.traceId,
        spanId: spanContext.spanId 
      }
    }
'@
            
            if (-not $DryRun) {
                Set-Content -Path $loggerPath -Value $patchedContent -Encoding UTF8
            }
            Write-SuccessLog "Logger patched for OpenTelemetry integration"
        } else {
            Write-InfoLog "Logger already supports OpenTelemetry"
        }
    } else {
        Write-WarningLog "Logger not found - skipping OpenTelemetry patch"
    }

    # Add environment variables template
    $envTemplatePath = Join-Path $observabilityPath "env.example"
    $envTemplateContent = @'
# OpenTelemetry Configuration
# Copy to .env and customize for your environment

# Service identification
OTEL_SERVICE_NAME=protozoa-organisms
OTEL_SERVICE_VERSION=1.0.0
OTEL_DEPLOYMENT_ENVIRONMENT=development

# Tracing configuration
OTEL_TRACE_SAMPLE_RATE=1.0

# Jaeger configuration (optional)
JAEGER_ENDPOINT=http://localhost:14268/api/traces
JAEGER_AGENT_HOST=localhost
JAEGER_AGENT_PORT=6832

# Zipkin configuration (optional)
ZIPKIN_ENDPOINT=http://localhost:9411/api/v2/spans

# Performance monitoring
OTEL_ENABLE_PERFORMANCE_MONITORING=true
OTEL_ENABLE_MEMORY_MONITORING=true
'@

    Write-InfoLog "Creating OpenTelemetry environment template"
    if (-not $DryRun) {
        Set-Content -Path $envTemplatePath -Value $envTemplateContent -Encoding UTF8
    }

    # Create monitoring utilities
    $monitoringPath = Join-Path $observabilityPath "monitoring.ts"
    $monitoringContent = @'
/**
 * Performance monitoring utilities for Protozoa application
 * Provides metrics collection and performance tracking
 * 
 * @author Protozoa Automation Suite
 * @generated 29-SetupOpenTelemetry.ps1
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
 * @generated 29-SetupOpenTelemetry.ps1
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