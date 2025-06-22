/**
 * @fileoverview Trait Domain Test Configuration
 * @description Helper functions for configuring trait tests
 */

import { TraitDependencyInjection } from '@/domains/trait/services/traitDependencyInjection'

/**
 * Configure trait service for testing
 */
export function setupTraitTestEnvironment() {
  const dependencyInjection = TraitDependencyInjection.getInstance()
  const testConfig = dependencyInjection.createTestConfiguration()
  dependencyInjection.configureDependencies(testConfig)
  
  return {
    dependencyInjection,
    testConfig
  }
}

/**
 * Clean up trait test environment
 */
export function teardownTraitTestEnvironment() {
  const dependencyInjection = TraitDependencyInjection.getInstance()
  dependencyInjection.resetConfiguration()
}
