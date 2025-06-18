/**
 * Physics Service implementing kinematic helpers and geometry utilities
 * Simplified service - formations now handle all movement calculations
 * Follows singleton pattern for application-wide geometry consistency
 */
export class PhysicsService implements IPhysicsService {
  /** Singleton instance */
  static #instance: PhysicsService | null = null;
  
  /** Physics simulation state */
  #state: PhysicsState;
  
  /** Service configuration */
  #config: PhysicsConfig;
  
  /** Performance metrics */
  #metrics: PhysicsMetrics;
  
  /** Winston logger instance */
  #logger = createServiceLogger('PhysicsService');
  
  /** Frame timing for performance monitoring */
  #frameStartTime: number = 0;
  #frameHistory: number[] = [];
  
  /**
   * Private constructor enforcing singleton pattern
   * Initializes physics service with kinematic helpers
   */
  private constructor() {
    this.#logger.info('Initializing PhysicsService singleton instance (kinematic mode)');
    
    // Initialize default configuration
    this.#config = {
      targetFPS: 60,
      useWorkerThreads: false, // Simplified - no workers needed
      workerThreadCount: 0,
      gravity: -9.81,
      damping: 0.99,
      useSpatialPartitioning: false, // Formations handle positioning
      spatialGridSize: 0
    };
    
    // Initialize physics state
    this.#state = {
      isRunning: false,
      simulationTime: 0,
      lastDeltaTime: 0,
      algorithm: 'euler', // Simplified
      collisionMethod: 'basic', // No complex collision detection
      activeParticles: 0
    };
    
    // Initialize performance metrics
    this.#metrics = {
      currentFPS: 0,
      averageFrameTime: 0,
      transformCalculations: 0,
      geometryOperations: 0,
      memoryUsage: 0
    };
    
    this.#logger.info('PhysicsService initialized successfully (simplified kinematic mode)');
  }
  
  /**
   * Get singleton instance of PhysicsService
   * Creates new instance if none exists
   * @returns PhysicsService singleton instance
   */
  public static getInstance(): PhysicsService {
    if (!PhysicsService.#instance) {
      PhysicsService.#instance = new PhysicsService();
    }
    return PhysicsService.#instance;
  }
  
  /**
   * Initialize the physics service with configuration
   * @param config - Optional physics configuration
   */
  public async initialize(config?: PhysicsConfig): Promise<void> {
    this.#logger.info('Initializing PhysicsService with configuration', { config });
    
    if (config) {
      this.#config = { ...this.#config, ...config };
    }
    
    this.#state.isRunning = true;
    this.#logger.info('PhysicsService initialization completed (kinematic mode)');
  }
  
  /**
   * Distribute particles in a geometric pattern
   * @param count - Number of particles to distribute
   * @param pattern - Distribution pattern type
   * @param bounds - Boundary constraints
   * @returns Array of positions
   */
  public distributeParticles(count: number, pattern: string, bounds: Vector3): Vector3[] {
    this.#frameStartTime = performance.now();
    const positions: Vector3[] = [];
    
    this.#logger.debug('Distributing particles', { count, pattern, bounds });
    
    switch (pattern) {
      case 'grid':
        positions.push(...this.#distributeGrid(count, bounds));
        break;
      case 'circle':
        positions.push(...this.#distributeCircle(count, bounds));
        break;
      case 'sphere':
        positions.push(...this.#distributeSphere(count, bounds));
        break;
      case 'fibonacci':
        positions.push(...this.#distributeFibonacci(count, bounds));
        break;
      case 'random':
      default:
        positions.push(...this.#distributeRandom(count, bounds));
        break;
    }
    
    this.#metrics.geometryOperations++;
    this.#updateMetrics();
    
    return positions;
  }
  
  /**
   * Create transform matrix from position, rotation, scale
   * @param position - Position vector
   * @param rotation - Rotation quaternion
   * @param scale - Scale vector
   * @returns Transform object with matrix
   */
  public createTransform(position: Vector3, rotation: any, scale: Vector3): Transform {
    const matrix = new Matrix4();
    matrix.compose(position, new Quaternion(rotation.x, rotation.y, rotation.z, rotation.w), scale);
    
    this.#metrics.transformCalculations++;
    
    return {
      position: position.clone(),
      rotation: { ...rotation },
      scale: scale.clone(),
      matrix: matrix.elements as Float32Array
    };
  }
  
  /**
   * Interpolate between two transforms
   * @param from - Starting transform
   * @param to - Target transform
   * @param alpha - Interpolation factor (0-1)
   * @returns Interpolated transform
   */
  public interpolateTransform(from: Transform, to: Transform, alpha: number): Transform {
    const clampedAlpha = Math.max(0, Math.min(1, alpha));
    
    const position = from.position.clone().lerp(to.position, clampedAlpha);
    const scale = from.scale.clone().lerp(to.scale, clampedAlpha);
    
    const fromQuat = new Quaternion(from.rotation.x, from.rotation.y, from.rotation.z, from.rotation.w);
    const toQuat = new Quaternion(to.rotation.x, to.rotation.y, to.rotation.z, to.rotation.w);
    const rotation = fromQuat.slerp(toQuat, clampedAlpha);
    
    this.#metrics.transformCalculations++;
    
    return this.createTransform(position, rotation, scale);
  }
  
  /**
   * Apply gravity to a particle
   * @param particle - Particle to apply gravity to
   * @param deltaTime - Time delta
   */
  public applyGravity(particle: ParticlePhysics, deltaTime: number): void {
    if (!particle.useGravity) return;
    
    const gravityForce = new Vector3(0, this.#config.gravity! * particle.mass, 0);
    particle.acceleration.add(gravityForce.divideScalar(particle.mass));
  }
  
  // Private geometry distribution methods
  
  /**
   * Distribute particles in a grid pattern
   * @param count - Number of particles
   * @param bounds - Boundary constraints
   * @returns Array of positions in grid formation
   */
  #distributeGrid(count: number, bounds: Vector3): Vector3[] {
    const positions: Vector3[] = [];
    const side = Math.ceil(Math.cbrt(count));
    const spacing = bounds.divideScalar(side);
    
    for (let x = 0; x < side; x++) {
      for (let y = 0; y < side; y++) {
        for (let z = 0; z < side && positions.length < count; z++) {
          positions.push(new Vector3(
            (x - side/2) * spacing.x,
            (y - side/2) * spacing.y,
            (z - side/2) * spacing.z
          ));
        }
      }
    }
    
    return positions;
  }
  
  /**
   * Distribute particles in a circle pattern
   * @param count - Number of particles
   * @param bounds - Boundary constraints (uses x as radius)
   * @returns Array of positions in circular formation
   */
  #distributeCircle(count: number, bounds: Vector3): Vector3[] {
    const positions: Vector3[] = [];
    const radius = bounds.x;
    
    for (let i = 0; i < count; i++) {
      const angle = (i / count) * Math.PI * 2;
      positions.push(new Vector3(
        Math.cos(angle) * radius,
        0,
        Math.sin(angle) * radius
      ));
    }
    
    return positions;
  }
  
  /**
   * Distribute particles in a sphere pattern
   * @param count - Number of particles
   * @param bounds - Boundary constraints (uses x as radius)
   * @returns Array of positions in spherical formation
   */
  #distributeSphere(count: number, bounds: Vector3): Vector3[] {
    const positions: Vector3[] = [];
    const radius = bounds.x;
    
    for (let i = 0; i < count; i++) {
      const u = Math.random();
      const v = Math.random();
      const theta = 2 * Math.PI * u;
      const phi = Math.acos(2 * v - 1);
      
      positions.push(new Vector3(
        radius * Math.sin(phi) * Math.cos(theta),
        radius * Math.sin(phi) * Math.sin(theta),
        radius * Math.cos(phi)
      ));
    }
    
    return positions;
  }
  
  /**
   * Distribute particles using Fibonacci spiral
   * @param count - Number of particles
   * @param bounds - Boundary constraints (uses x as radius)
   * @returns Array of positions in Fibonacci formation
   */
  #distributeFibonacci(count: number, bounds: Vector3): Vector3[] {
    const positions: Vector3[] = [];
    const goldenRatio = (1 + Math.sqrt(5)) / 2;
    const radius = bounds.x;
    
    for (let i = 0; i < count; i++) {
      const theta = 2 * Math.PI * i / goldenRatio;
      const y = 1 - (i / (count - 1)) * 2;
      const radiusAtY = Math.sqrt(1 - y * y);
      
      positions.push(new Vector3(
        Math.cos(theta) * radiusAtY * radius,
        y * radius,
        Math.sin(theta) * radiusAtY * radius
      ));
    }
    
    return positions;
  }
  
  /**
   * Distribute particles randomly within bounds
   * @param count - Number of particles
   * @param bounds - Boundary constraints
   * @returns Array of random positions
   */
  #distributeRandom(count: number, bounds: Vector3): Vector3[] {
    const positions: Vector3[] = [];
    
    for (let i = 0; i < count; i++) {
      positions.push(new Vector3(
        (Math.random() - 0.5) * bounds.x,
        (Math.random() - 0.5) * bounds.y,
        (Math.random() - 0.5) * bounds.z
      ));
    }
    
    return positions;
  }
  
  /**
   * Get current physics performance metrics
   * @returns Physics performance data
   */
  public getMetrics(): PhysicsMetrics {
    return { ...this.#metrics };
  }
  
  /**
   * Reset physics simulation state
   */
  public reset(): void {
    this.#logger.info('Resetting physics simulation state');
    
    this.#state = {
      isRunning: false,
      simulationTime: 0,
      lastDeltaTime: 0,
      algorithm: 'verlet',
      collisionMethod: 'spatial-hash',
      activeParticles: 0
    };
    
    this.#forceFields.clear();
    this.#spatialGrid.clear();
    this.#constraints.clear();
    this.#frameHistory = [];
    
    this.#logger.info('Physics simulation reset completed');
  }
  
  /**
   * Dispose of resources and cleanup worker threads
   */
  public dispose(): void {
    this.#logger.info('Disposing PhysicsService resources');
    
    // Terminate worker threads
    this.#workers.forEach(worker => {
      worker.terminate();
    });
    this.#workers = [];
    this.#workerAvailable = [];
    
    // Clear all data structures
    this.#forceFields.clear();
    this.#spatialGrid.clear();
    this.#constraints.clear();
    this.#workerQueue = [];
    
    // Reset singleton instance
    PhysicsService.#instance = null;
    
    this.#logger.info('PhysicsService disposal completed');
  }
  
  // Private helper methods
  
  /**
   * Initialize worker thread pool
   */
  async #initializeWorkers(): Promise<void> {
    this.#logger.info('Initializing physics worker threads', {
      count: this.#config.workerThreadCount
    });
    
    const workerPromises: Promise<void>[] = [];
    
    for (let i = 0; i < this.#config.workerThreadCount!; i++) {
      const workerPromise = new Promise<void>((resolve, reject) => {
        try {
          // Create physics worker (implementation would reference actual worker file)
          const worker = new Worker('/src/domains/physics/workers/physicsWorker.js');
          
          worker.onmessage = (e) => {
            this.#handleWorkerMessage(i, e.data);
          };
          
          worker.onerror = (error) => {
            this.#logger.error(Physics worker 19 error, { error: error.message });
            reject(error);
          };
          
          this.#workers[i] = worker;
          this.#workerAvailable[i] = true;
          
          // Send initialization message
          worker.postMessage({
            type: 'INIT',
            payload: { config: this.#config },
            messageId: init_19,
            timestamp: Date.now()
          });
          
          resolve();
        } catch (error) {
          reject(error);
        }
      });
      
      workerPromises.push(workerPromise);
    }
    
    await Promise.all(workerPromises);
    this.#logger.info('All physics workers initialized successfully');
  }
  
  /**
   * Handle worker thread messages
   * @param workerId - ID of the worker
   * @param message - Message from worker
   */
  #handleWorkerMessage(workerId: number, message: WorkerMessage): void {
    switch (message.type) {
      case 'WORKER_READY':
        this.#workerAvailable[workerId] = true;
        break;
      
      case 'PHYSICS_UPDATE':
        // Handle physics update completion
        this.#workerAvailable[workerId] = true;
        break;
      
      case 'WORKER_ERROR':
        this.#logger.error(Worker  reported error, {
          error: message.payload
        });
        this.#workerAvailable[workerId] = true;
        break;
      
      default:
        this.#logger.warn('Unknown worker message type', {
          workerId,
          type: message.type
        });
    }
  }
  
  /**
   * Update physics using worker threads
   * @param deltaTime - Time delta
   * @param particles - Particles to simulate
   */
  async #updatePhysicsWorkers(deltaTime: number, particles: ParticlePhysics[]): Promise<void> {
    const availableWorkers = this.#workerAvailable
      .map((available, index) => available ? index : -1)
      .filter(index => index !== -1);
    
    if (availableWorkers.length === 0) {
      // Fallback to main thread if no workers available
      this.#updatePhysicsMainThread(deltaTime, particles);
      this.#logger.warn('No workers available, falling back to main thread');
      return;
    }
    
    // Divide particles among available workers
    const particlesPerWorker = Math.ceil(particles.length / availableWorkers.length);
    const workerPromises: Promise<void>[] = [];
    
    for (let i = 0; i < availableWorkers.length; i++) {
      const workerId = availableWorkers[i];
      const startIndex = i * particlesPerWorker;
      const endIndex = Math.min(startIndex + particlesPerWorker, particles.length);
      const workerParticles = particles.slice(startIndex, endIndex);
      
      if (workerParticles.length > 0) {
        this.#workerAvailable[workerId] = false;
        
        const workerPromise = new Promise<void>((resolve) => {
          const worker = this.#workers[workerId];
          const messageId = physics__;
          
          const onMessage = (e: MessageEvent) => {
            if (e.data.messageId === messageId) {
              worker.removeEventListener('message', onMessage);
              // Update particles with results
              Object.assign(workerParticles, e.data.payload.particles);
              resolve();
            }
          };
          
          worker.addEventListener('message', onMessage);
          
          worker.postMessage({
            type: 'PHYSICS_UPDATE',
            messageId,
            timestamp: Date.now(),
            payload: {
              particles: workerParticles,
              forceFields: Array.from(this.#forceFields.values()),
              config: this.#config,
              deltaTime
            }
          });
        });
        
        workerPromises.push(workerPromise);
      }
    }
    
    await Promise.all(workerPromises);
  }
  
  /**
   * Update physics on main thread
   * @param deltaTime - Time delta
   * @param particles - Particles to simulate
   */
  #updatePhysicsMainThread(deltaTime: number, particles: ParticlePhysics[]): void {
    for (const particle of particles) {
      // Apply gravity
      this.applyGravity(particle, deltaTime);
      
      // Apply force fields
      this.#applyForceFields(particle);
      
      // Update velocity (Verlet integration)
      particle.velocity.add(
        particle.acceleration.clone().multiplyScalar(deltaTime)
      );
      
      // Apply damping
      particle.velocity.multiplyScalar(this.#config.damping!);
      
      // Update position
      particle.position.add(
        particle.velocity.clone().multiplyScalar(deltaTime)
      );
      
      // Reset acceleration
      particle.acceleration.set(0, 0, 0);
    }
    
    // Check collisions
    this.#checkCollisions(particles);
  }
  }
