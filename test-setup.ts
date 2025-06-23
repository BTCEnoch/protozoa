/**
 * @fileoverview Vitest Test Setup Configuration
 * @description Global test setup with proper mocks for logger and other shared services
 * @module test-setup
 * @version 1.0.0
 * @author Protozoa Development Team
 */

import { vi, beforeEach, afterEach } from 'vitest'

// Mock logger for all tests - CRITICAL FIX for "No logger export" error
vi.mock('@/shared/lib/logger', () => {
  const mockLogger = {
    debug: vi.fn(),
    info: vi.fn(),
    warn: vi.fn(),
    error: vi.fn(),
    success: vi.fn(),
  }

  const mockPerformanceLogger = {
    ...mockLogger,
    startTimer: vi.fn(),
    endTimer: vi.fn(() => 0),
    logMemoryUsage: vi.fn(),
  }

  return {
    // Named export for createServiceLogger function - CRITICAL FIX
    createServiceLogger: vi.fn(() => mockLogger),

    // Direct named exports for logger and perfLogger - CRITICAL FIX for RNGService
    logger: mockLogger,
    perfLogger: mockPerformanceLogger,

    // Error logger export - CRITICAL FIX
    errorLogger: mockLogger,

    // Other logger functions that might be imported
    createPerformanceLogger: vi.fn(() => mockPerformanceLogger),

    createErrorLogger: vi.fn(() => mockLogger),
    enableDebugLogging: vi.fn(),
    disableDebugLogging: vi.fn(),
    initializeLogging: vi.fn(),
  }
})

// Mock Performance API for environments that don't have it
Object.defineProperty(global, 'performance', {
  writable: true,
  value: {
    now: vi.fn(() => Date.now()),
    mark: vi.fn(),
    measure: vi.fn(),
    getEntriesByName: vi.fn(() => []),
    getEntriesByType: vi.fn(() => []),
  },
})

// Mock window.performance.memory for memory monitoring tests
Object.defineProperty(performance, 'memory', {
  writable: true,
  value: {
    usedJSHeapSize: 1000000,
    totalJSHeapSize: 2000000,
    jsHeapSizeLimit: 4000000,
  },
})

// Setup global DOM environment for React testing
import '@testing-library/jest-dom'

// Mock IntersectionObserver for components that might use it
global.IntersectionObserver = class IntersectionObserver {
  constructor() {}
  disconnect = vi.fn()
  observe = vi.fn()
  unobserve = vi.fn()
  takeRecords = vi.fn(() => [])
  root = null
  rootMargin = ''
  thresholds = []
}

// Mock ResizeObserver for components that might use it
global.ResizeObserver = class ResizeObserver {
  constructor() {}
  disconnect = vi.fn()
  observe = vi.fn()
  unobserve = vi.fn()
}

// PHASE 3 TASK 3.1: Proper Test Isolation Implementation
beforeEach(() => {
  // Clear all mocks before each test
  vi.clearAllMocks()

  // Reset console methods to avoid test noise
  console.warn = vi.fn()
  console.error = vi.fn()

  // Clear any timers/intervals that might affect tests
  vi.clearAllTimers()
})

afterEach(() => {
  // Comprehensive cleanup after each test
  vi.clearAllMocks()
  vi.restoreAllMocks()
  vi.clearAllTimers()

  // Force garbage collection hint (if available)
  if (global.gc) {
    global.gc()
  }
})
