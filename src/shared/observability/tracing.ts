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
