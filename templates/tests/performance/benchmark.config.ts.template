/**
 * Performance benchmark configuration
 * Centralized configuration for all performance tests
 * 
 * @author Protozoa Automation Suite
 * @generated from template
 */

export interface BenchmarkConfig {
  /** Benchmark execution time in milliseconds */
  time: number
  /** Number of iterations to run */
  iterations?: number
  /** Warmup iterations before measurement */
  warmup?: number
  /** Performance thresholds for assertions */
  thresholds: {
    particle: {
      allocation100: number
      allocation500: number
      allocation1000: number
      update100: number
      update500: number
      update1000: number
      memoryPool: number
      batchOperations: number
    }
    physics: {
      update100: number
      update500: number
      update1000: number
      collision100: number
      collision500: number
      forces50: number
      forces100: number
      spatialPartitioning: number
    }
    rendering: {
      draw100: number
      draw500: number
      draw1000: number
      shaderCompilation: number
      textureLoading: number
    }
    rng: {
      generation1000: number
      generation10000: number
      seeding: number
    }
  }
  /** Test data generation settings */
  testData: {
    particleCount: {
      small: number
      medium: number
      large: number
    }
    worldSize: {
      width: number
      height: number
      depth: number
    }
    velocityRange: {
      min: number
      max: number
    }
    massRange: {
      min: number
      max: number
    }
  }
}

/**
 * Default benchmark configuration
 * Optimized for 60fps performance targets
 */
export const defaultBenchmarkConfig: BenchmarkConfig = {
  time: 1000,
  iterations: 100,
  warmup: 10,
  thresholds: {
    particle: {
      allocation100: 10,    // 10ms for 100 particles
      allocation500: 50,    // 50ms for 500 particles
      allocation1000: 100,  // 100ms for 1000 particles
      update100: 2,         // 2ms for 100 particle updates
      update500: 8,         // 8ms for 500 particle updates
      update1000: 16,       // 16ms for 1000 particle updates (60fps budget)
      memoryPool: 50,       // 50ms for pool operations
      batchOperations: 10   // 10ms for batch operations
    },
    physics: {
      update100: 3,         // 3ms for 100 physics updates
      update500: 10,        // 10ms for 500 physics updates
      update1000: 16,       // 16ms for 1000 physics updates
      collision100: 5,      // 5ms for 100 collision checks
      collision500: 15,     // 15ms for 500 collision checks
      forces50: 8,          // 8ms for 50 force calculations
      forces100: 20,        // 20ms for 100 force calculations
      spatialPartitioning: 20 // 20ms for spatial operations
    },
    rendering: {
      draw100: 4,           // 4ms for 100 draw calls
      draw500: 12,          // 12ms for 500 draw calls
      draw1000: 16,         // 16ms for 1000 draw calls
      shaderCompilation: 100, // 100ms for shader compilation
      textureLoading: 200   // 200ms for texture loading
    },
    rng: {
      generation1000: 1,    // 1ms for 1000 random numbers
      generation10000: 5,   // 5ms for 10000 random numbers
      seeding: 10           // 10ms for RNG seeding
    }
  },
  testData: {
    particleCount: {
      small: 100,
      medium: 500,
      large: 1000
    },
    worldSize: {
      width: 100,
      height: 100,
      depth: 100
    },
    velocityRange: {
      min: -10,
      max: 10
    },
    massRange: {
      min: 0.5,
      max: 5.0
    }
  }
}

/**
 * Stress test configuration
 * Higher particle counts and tighter thresholds
 */
export const stressBenchmarkConfig: BenchmarkConfig = {
  ...defaultBenchmarkConfig,
  time: 2000,
  iterations: 50,
  testData: {
    ...defaultBenchmarkConfig.testData,
    particleCount: {
      small: 500,
      medium: 2000,
      large: 5000
    }
  },
  thresholds: {
    ...defaultBenchmarkConfig.thresholds,
    particle: {
      ...defaultBenchmarkConfig.thresholds.particle,
      allocation1000: 80,   // Tighter threshold
      update1000: 12       // Tighter 60fps requirement
    }
  }
}

/**
 * Development configuration
 * Faster execution for development testing
 */
export const devBenchmarkConfig: BenchmarkConfig = {
  ...defaultBenchmarkConfig,
  time: 500,
  iterations: 20,
  warmup: 5,
  testData: {
    ...defaultBenchmarkConfig.testData,
    particleCount: {
      small: 50,
      medium: 200,
      large: 500
    }
  }
} 