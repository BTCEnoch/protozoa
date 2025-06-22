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
