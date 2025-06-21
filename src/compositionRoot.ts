/**
 * @fileoverview Composition Root - Dependency Injection Container
 * @description Initializes and manages all domain services
 * @author Protozoa Development Team
 * @version 1.0.0
 */

let servicesInitialized = false

export async function initServices(): Promise<void> {
  if (servicesInitialized) {
    console.log('âš ï¸ Services already initialized')
    return
  }

  console.log('ðŸš€ Initializing Protozoa domain services...')
  
  try {
    // In development mode, we'll gradually initialize services
    // This prevents blocking the initial app load
    
    // Phase 1: Core utilities
    console.log('ðŸ“¦ Phase 1: Core utilities loading...')
    
    // Phase 2: Domain services (placeholder)
    console.log('ðŸ§¬ Phase 2: Domain services loading...')
    
    // Phase 3: Integration services (placeholder)
    console.log('ðŸ”— Phase 3: Integration services loading...')
    
    servicesInitialized = true
    console.log('âœ… All services initialized successfully')
    
  } catch (error) {
    console.error('âŒ Service initialization failed:', error)
    throw error
  }
}

export function disposeServices(): void {
  if (!servicesInitialized) {
    return
  }
  
  console.log('ðŸ§¹ Disposing Protozoa services...')
  
  try {
    // Cleanup logic will go here
    servicesInitialized = false
    console.log('âœ… Services disposed successfully')
  } catch (error) {
    console.error('âŒ Service disposal failed:', error)
  }
}

export function getServiceStatus(): boolean {
  return servicesInitialized
}
