
/**
 * @fileoverview Particle Service Implementation
 * @description High-performance particle system with THREE.js integration and GPU optimization
 * @author Protozoa Development Team
 * @version 1.0.0
 */

import {
    IParticleService,
    ParticleConfig,
    ParticleInstance,
    ParticleMetrics,
    ParticleSystem
} from '@/domains/particle/interfaces/IParticleService';
import {
    ParticleBatch,
    ParticleCulling,
    ParticleGeometry,
    ParticleLOD,
    ParticleMaterial
} from '@/domains/particle/types/particle.types';
import { createServiceLogger } from '@/shared/lib/logger';
import { BufferGeometry, Material, Scene, Vector3 } from 'three';

/**
 * Particle Service implementing high-performance particle system management
 * Uses THREE.js for rendering with GPU instancing and object pooling optimizations
 * Follows singleton pattern for application-wide particle management
 */
export class ParticleService implements IParticleService {
  /** Singleton instance */
  static #instance: ParticleService | null = null;
  
  /** Service configuration */
  #config: ParticleConfig;
  
  /** Performance metrics */
  #metrics: ParticleMetrics;
  
  /** Winston logger instance */
  #logger = createServiceLogger('ParticleService');
  
  /** Active particle systems */
  #systems: Map<string, ParticleSystem>;
  
  /** Particle object pool */
  #particlePool: ParticleInstance[];
  
  /** Available pool indices */
  #poolIndices: number[];
  
  /** Particle geometries cache */
  #geometries: Map<string, ParticleGeometry>;
  
  /** Particle materials cache */
  #materials: Map<string, ParticleMaterial>;
  
  /** Instanced rendering batches */
  #batches: Map<string, ParticleBatch>;
  
  /** LOD configuration */
  #lodConfig: ParticleLOD;
  
  /** Culling configuration */
  #cullingConfig: ParticleCulling;
  
  /** Frame timing for performance monitoring */
  #frameStartTime: number = 0;
  #updateHistory: number[] = [];
  #renderHistory: number[] = [];
  
  /**
   * Private constructor enforcing singleton pattern
   * Initializes particle service with performance optimizations
   */
  private constructor() {
    this.#logger.info('Initializing ParticleService singleton instance');
    
    // Initialize default configuration
    this.#config = {
      maxParticles: 10000,
      useInstancing: true,
      useObjectPooling: true,
      defaultMaterial: 'standard',
      enableLOD: true,
      cullingDistance: 100
    };
    
    // Initialize performance metrics
    this.#metrics = {
      totalParticles: 0,
      activeSystems: 0,
      particlesUpdated: 0,
      particlesRendered: 0,
      averageUpdateTime: 0,
      averageRenderTime: 0,
      memoryUsage: 0,
      gpuMemoryUsage: 0,
      poolUtilization: 0
    };
    
    // Initialize collections
    this.#systems = new Map();
    this.#particlePool = [];
    this.#poolIndices = [];
    this.#geometries = new Map();
    this.#materials = new Map();
    this.#batches = new Map();
    
    // Initialize LOD configuration
    this.#lodConfig = {
      distances: [25, 50, 100],
      particleCounts: [100, 50, 25],
      qualityLevels: [1.0, 0.7, 0.4]
    };
    
    // Initialize culling configuration
    this.#cullingConfig = {
      frustumCulling: true,
      distanceCulling: true,
      maxDistance: this.#config.cullingDistance!,
      occlusionThreshold: 0.1
    };
    
    // Initialize object pool
    this.#initializeObjectPool();
    
    this.#logger.info('ParticleService initialized successfully', {
      maxParticles: this.#config.maxParticles,
      useInstancing: this.#config.useInstancing,
      useObjectPooling: this.#config.useObjectPooling
    });
  }
  
  /**
   * Get singleton instance of ParticleService
   * Creates new instance if none exists
   * @returns ParticleService singleton instance
   */
  public static getInstance(): ParticleService {
    if (!ParticleService.#instance) {
      ParticleService.#instance = new ParticleService();
    }
    return ParticleService.#instance;
  }
}
  
  /**
   * Initialize the Particle service with configuration
   * @param config - Optional particle configuration
   */
  public async initialize(config?: ParticleConfig): Promise<void> {
    this.#logger.info('Initializing ParticleService with configuration', { config });
    
    if (config) {
      this.#config = { ...this.#config, ...config };
    }
    
    // Reinitialize object pool if max particles changed
    if (config?.maxParticles && config.maxParticles !== this.#config.maxParticles) {
      this.#initializeObjectPool();
    }
    
    this.#logger.info('ParticleService initialization completed');
  }
  
  /**
   * Create a new particle system
   * @param systemConfig - System configuration
   * @returns Created particle system
   */
  public createSystem(systemConfig: ParticleSystemConfig): ParticleSystem {
    this.#logger.info('Creating particle system', { systemId: systemConfig.id });
    
    if (this.#systems.has(systemConfig.id)) {
      throw new Error(`Particle system with ID '${systemConfig.id}' already exists`);
    }
    
    const system: ParticleSystem = {
      id: systemConfig.id,
      name: systemConfig.name,
      maxParticles: systemConfig.maxParticles,
      activeParticles: 0,
      particles: [],
      position: systemConfig.position.clone(),
      bounds: systemConfig.bounds.clone(),
      active: true,
      createdAt: Date.now()
    };
    
    this.#systems.set(systemConfig.id, system);
    this.#metrics.activeSystems++;
    
    this.#logger.info('Particle system created successfully', {
      systemId: systemConfig.id,
      maxParticles: systemConfig.maxParticles
    });
    
    return system;
  }
  
  /**
   * Add particles to a system
   * @param systemId - System identifier
   * @param particleData - Particle creation data
   * @returns Array of created particle IDs
   */
  public addParticles(systemId: string, particleData: ParticleCreationData[]): string[] {
    const system = this.#systems.get(systemId);
    if (!system) {
      throw new Error(`Particle system '${systemId}' not found`);
    }
    
    const createdIds: string[] = [];
    
    for (const data of particleData) {
      if (system.activeParticles >= system.maxParticles) {
        this.#logger.warn('System particle limit reached', {
          systemId,
          maxParticles: system.maxParticles
        });
        break;
      }
      
      const particle = this.#createParticle(data);
      if (particle) {
        system.particles.push(particle);
        system.activeParticles++;
        this.#metrics.totalParticles++;
        createdIds.push(particle.id);
      }
    }
    
    this.#logger.info('Particles added to system', {
      systemId,
      particlesAdded: createdIds.length,
      totalActive: system.activeParticles
    });
    
    return createdIds;
  }
  
  /**
   * Remove particles from a system
   * @param systemId - System identifier
   * @param particleIds - Particle IDs to remove
   */
  public removeParticles(systemId: string, particleIds: string[]): void {
    const system = this.#systems.get(systemId);
    if (!system) {
      throw new Error(`Particle system '${systemId}' not found`);
    }
    
    let removedCount = 0;
    
    for (const particleId of particleIds) {
      const index = system.particles.findIndex(p => p.id === particleId);
      if (index !== -1) {
        const particle = system.particles[index];
        this.#returnParticleToPool(particle);
        system.particles.splice(index, 1);
        system.activeParticles--;
        this.#metrics.totalParticles--;
        removedCount++;
      }
    }
    
    this.#logger.info('Particles removed from system', {
      systemId,
      particlesRemoved: removedCount,
      totalActive: system.activeParticles
    });
  }
  
  /**
   * Update all particle systems
   * @param deltaTime - Time delta in seconds
   */
  public update(deltaTime: number): void {
    this.#frameStartTime = performance.now();
    
    // Reset frame metrics
    this.#metrics.particlesUpdated = 0;
    
    // Update all active systems
    for (const system of this.#systems.values()) {
      if (system.active) {
        this.#updateSystem(system, deltaTime);
      }
    }
    
    // Update performance metrics
    this.#updateMetrics('update');
    
    this.#logger.debug('Particle systems updated', {
      activeSystems: this.#metrics.activeSystems,
      totalParticles: this.#metrics.totalParticles,
      particlesUpdated: this.#metrics.particlesUpdated,
      updateTime: this.#metrics.averageUpdateTime
    });
  }
    this.#frameStartTime = performance.now();
    this.#metrics.particlesUpdated = 0;
    
    for (const system of this.#systems.values()) {
      if (!system.active) continue;
      
      this.#updateSystem(system, deltaTime);
    }
    
    this.#updateMetrics('update');
  }
  
  /**
   * Render particles to THREE.js scene
   * @param scene - THREE.js scene
   */
  public render(scene: Scene): void {
    const renderStartTime = performance.now();
    
    // Reset render metrics
    this.#metrics.particlesRendered = 0;
    this.#metrics.batchesRendered = 0;
    
    // Render all active systems
    for (const system of this.#systems.values()) {
      if (system.active && system.activeParticles > 0) {
        this.#renderSystem(system, scene);
        this.#metrics.batchesRendered++;
      }
    }
    
    // Update render performance metrics
    this.#updateMetrics('render', renderStartTime);
    
    this.#logger.debug('Particle systems rendered', {
      activeSystems: this.#metrics.activeSystems,
      particlesRendered: this.#metrics.particlesRendered,
      batchesRendered: this.#metrics.batchesRendered,
      renderTime: this.#metrics.averageRenderTime
    });
  }
    const renderStartTime = performance.now();
    this.#metrics.particlesRendered = 0;
    
    for (const system of this.#systems.values()) {
      if (!system.active || system.activeParticles === 0) continue;
      
      this.#renderSystem(system, scene);
    }
    
    this.#updateMetrics('render', renderStartTime);
  }
  
  /**
   * Get particle system by ID
   * @param systemId - System identifier
   * @returns Particle system or undefined
   */
  public getSystem(systemId: string): ParticleSystem | undefined {
    return this.#systems.get(systemId);
  }
    return this.#systems.get(systemId);
  }
  
  /**
   * Get particle performance metrics
   * @returns Particle service metrics
   */
  public getMetrics(): ParticleMetrics {
    // Update pool utilization
    this.#metrics.poolUtilization = this.#config.maxParticles! > 0 
      ? ((this.#config.maxParticles! - this.#poolIndices.length) / this.#config.maxParticles!) * 100
      : 0;
    
    // Estimate memory usage
    this.#metrics.memoryUsage = (
      this.#metrics.totalParticles * 0.001 + // Rough estimate per particle
      this.#systems.size * 0.0001 + // System overhead
      this.#geometries.size * 0.01 + // Geometry memory
      this.#materials.size * 0.005 // Material memory
    );
    
    return { ...this.#metrics };
  }
    // Update pool utilization
    const poolUsed = this.#config.maxParticles! - this.#poolIndices.length;
    this.#metrics.poolUtilization = (poolUsed / this.#config.maxParticles!) * 100;
    
    return { ...this.#metrics };
  }
  
  /**
   * Dispose of resources and cleanup
   */
  public dispose(): void {
    this.#logger.info('Disposing ParticleService resources');
    
    // Clear all particle systems
    for (const system of this.#systems.values()) {
      for (const particle of system.particles) {
        this.#returnParticleToPool(particle);
      }
    }
    this.#systems.clear();
    
    // Dispose of THREE.js resources
    for (const geometry of this.#geometries.values()) {
      geometry.dispose();
    }
    this.#geometries.clear();
    
    for (const material of this.#materials.values()) {
      material.dispose();
    }
    this.#materials.clear();
    
    // Clear batches and pools
    this.#batches.clear();
    this.#particlePool = [];
    this.#poolIndices = [];
    
    // Reset metrics
    this.#metrics = {
      totalParticles: 0,
      activeSystems: 0,
      particlesUpdated: 0,
      particlesRendered: 0,
      batchesRendered: 0,
      averageUpdateTime: 0,
      averageRenderTime: 0,
      memoryUsage: 0,
      gpuMemoryUsage: 0,
      poolUtilization: 0
    };
    
    // Reset singleton instance
    ParticleService.#instance = null;
    
    this.#logger.info('ParticleService disposal completed');
  }
    this.#logger.info('Disposing ParticleService resources');
    
    // Clear all systems
    for (const system of this.#systems.values()) {
      for (const particle of system.particles) {
        this.#returnParticleToPool(particle);
      }
    }
    this.#systems.clear();
    
    // Clear caches
    this.#geometries.clear();
    this.#materials.clear();
    this.#batches.clear();
    
    // Clear object pool
    this.#particlePool = [];
    this.#poolIndices = [];
    
    // Reset singleton instance
    ParticleService.#instance = null;
    
    this.#logger.info('ParticleService disposal completed');
  }
  
  // Private helper methods
  
  /**
   * Initialize object pool for particle instances
   */
  #initializeObjectPool(): void {
    this.#logger.info('Initializing particle object pool', {
      maxParticles: this.#config.maxParticles
    });
    
    this.#particlePool = [];
    this.#poolIndices = [];
    
    for (let i = 0; i < this.#config.maxParticles!; i++) {
      const particle: ParticleInstance = {
        id: '',
        position: new Vector3(),
        velocity: new Vector3(),
        scale: new Vector3(1, 1, 1),
        rotation: 0,
        color: { r: 1, g: 1, b: 1 },
        opacity: 1,
        age: 0,
        lifetime: 10,
        active: false,
        type: 'core',
        userData: {}
      };
      
      this.#particlePool.push(particle);
      this.#poolIndices.push(i);
    }
    
    this.#logger.info('Particle object pool initialized successfully');
  }
  
  /**
   * Create particle from creation data
   * @param data - Particle creation data
   * @returns Created particle instance or null if pool exhausted
   */
  #createParticle(data: ParticleCreationData): ParticleInstance | null {
    if (this.#poolIndices.length === 0) {
      this.#logger.warn('Particle pool exhausted');
      return null;
    }
    
    const poolIndex = this.#poolIndices.pop()!;
    const particle = this.#particlePool[poolIndex];
    
    // Initialize particle
    particle.id = `particle_${Date.now()}_${poolIndex}`;
    particle.position.copy(data.position);
    particle.velocity.copy(data.velocity || new Vector3());
    particle.scale.copy(data.scale || new Vector3(1, 1, 1));
    particle.rotation = data.rotation || 0;
    particle.color = data.color || { r: 1, g: 1, b: 1 };
    particle.opacity = data.opacity || 1;
    particle.age = 0;
    particle.lifetime = data.lifetime || 10;
    particle.active = true;
    particle.type = data.type;
    particle.userData = data.userData || {};
    
    return particle;
  }
  
  /**
   * Return particle to object pool
   * @param particle - Particle to return
   */
  #returnParticleToPool(particle: ParticleInstance): void {
    particle.active = false;
    particle.id = '';
    particle.userData = {};
    
    // Find pool index and return it
    const poolIndex = this.#particlePool.indexOf(particle);
    if (poolIndex !== -1) {
      this.#poolIndices.push(poolIndex);
    }
  }
  
  /**
   * Update particle system
   * @param system - System to update
   * @param deltaTime - Time delta
   */
  #updateSystem(system: ParticleSystem, deltaTime: number): void {
    const particlesToRemove: number[] = [];
    
    for (let i = 0; i < system.particles.length; i++) {
      const particle = system.particles[i];
      
      // Update particle age
      particle.age += deltaTime;
      
      // Check if particle should be removed
      if (particle.age >= particle.lifetime) {
        particlesToRemove.push(i);
        continue;
      }
      
      // Update particle position
      particle.position.add(
        particle.velocity.clone().multiplyScalar(deltaTime)
      );
      
      // Update particle rotation
      particle.rotation += deltaTime;
      
      this.#metrics.particlesUpdated++;
    }
    
    // Remove expired particles (reverse order to maintain indices)
    for (let i = particlesToRemove.length - 1; i >= 0; i--) {
      const index = particlesToRemove[i];
      const particle = system.particles[index];
      this.#returnParticleToPool(particle);
      system.particles.splice(index, 1);
      system.activeParticles--;
      this.#metrics.totalParticles--;
    }
  }
  
  /**
   * Render particle system with THREE.js integration
   * @param system - System to render
   * @param scene - THREE.js scene
   */
  #renderSystem(system: ParticleSystem, scene: Scene): void {
    if (system.activeParticles === 0) return;
    
    // Apply LOD optimization
    const distance = this.#calculateSystemDistance(system);
    const lodLevel = this.#calculateLODLevel(distance);
    
    // Apply culling
    if (this.#shouldCullSystem(system, distance)) {
      return;
    }
    
    // Get or create geometry and material for this system
    const geometry = this.#getOrCreateGeometry(system.id);
    const material = this.#getOrCreateMaterial(system.id);
    
    // Update instanced attributes if using instancing
    if (this.#config.useInstancing) {
      this.#updateInstancedAttributes(system, geometry, lodLevel);
    }
    
    // Batch rendering for performance
    const batch = this.#getOrCreateBatch(system.id, geometry, material);
    
    // Update batch with current particle data
    this.#updateBatch(batch, system, lodLevel);
    
    this.#metrics.particlesRendered += Math.min(
      system.activeParticles, 
      this.#lodConfig.particleCounts[lodLevel]
    );
  }
  
  /**
   * Update performance metrics
   * @param operation - Operation type
   * @param startTime - Optional start time for render operations
   */
  #updateMetrics(operation: 'update' | 'render', startTime?: number): void {
    const endTime = performance.now();
    const duration = endTime - (startTime || this.#frameStartTime);
    
    if (operation === 'update') {
      this.#updateHistory.push(duration);
      if (this.#updateHistory.length > 60) {
        this.#updateHistory.shift();
      }
      this.#metrics.averageUpdateTime = 
        this.#updateHistory.reduce((sum, time) => sum + time, 0) / this.#updateHistory.length;
    } else {
      this.#renderHistory.push(duration);
      if (this.#renderHistory.length > 60) {
        this.#renderHistory.shift();
      }
      this.#metrics.averageRenderTime = 
        this.#renderHistory.reduce((sum, time) => sum + time, 0) / this.#renderHistory.length;
    }
  }
  
  /**
   * Calculate distance from camera to system (simplified)
   * @param system - Particle system
   * @returns Distance value
   */
  #calculateSystemDistance(system: ParticleSystem): number {
    // In a real implementation, this would use camera position
    // For now, using system position magnitude as distance proxy
    return system.position.length();
  }
  
  /**
   * Calculate LOD level based on distance
   * @param distance - Distance to system
   * @returns LOD level (0 = highest quality)
   */
  #calculateLODLevel(distance: number): number {
    for (let i = 0; i < this.#lodConfig.distances.length; i++) {
      if (distance <= this.#lodConfig.distances[i]) {
        return i;
      }
    }
    return this.#lodConfig.distances.length - 1;
  }
  
  /**
   * Determine if system should be culled
   * @param system - Particle system
   * @param distance - Distance to system
   * @returns True if system should be culled
   */
  #shouldCullSystem(system: ParticleSystem, distance: number): boolean {
    if (!this.#cullingConfig.distanceCulling) return false;
    return distance > this.#cullingConfig.maxDistance;
  }
  
  /**
   * Get or create geometry for system
   * @param systemId - System identifier
   * @returns BufferGeometry instance
   */
  #getOrCreateGeometry(systemId: string): BufferGeometry {
    if (!this.#geometries.has(systemId)) {
      // Create basic particle geometry (point or quad)
      const geometry = new BufferGeometry();
      // In full implementation: set up vertices, UVs, etc.
      this.#geometries.set(systemId, geometry);
    }
    return this.#geometries.get(systemId)!;
  }
  
  /**
   * Get or create material for system
   * @param systemId - System identifier
   * @returns Material instance
   */
  #getOrCreateMaterial(systemId: string): Material {
    if (!this.#materials.has(systemId)) {
      // Create basic particle material
      // In full implementation: PointsMaterial or ShaderMaterial
      const material = {} as Material; // Placeholder
      this.#materials.set(systemId, material);
    }
    return this.#materials.get(systemId)!;
  }
  
  /**
   * Get or create render batch for system
   * @param systemId - System identifier
   * @param geometry - Geometry to use
   * @param material - Material to use
   * @returns Particle batch
   */
  #getOrCreateBatch(systemId: string, geometry: BufferGeometry, material: Material): ParticleBatch {
    if (!this.#batches.has(systemId)) {
      const batch: ParticleBatch = {
        id: systemId,
        geometry,
        material,
        instanceCount: 0,
        visible: true,
        needsUpdate: true
      };
      this.#batches.set(systemId, batch);
    }
    return this.#batches.get(systemId)!;
  }
  
  /**
   * Update instanced attributes for GPU rendering
   * @param system - Particle system
   * @param geometry - Geometry to update
   * @param lodLevel - Current LOD level
   */
  #updateInstancedAttributes(system: ParticleSystem, geometry: BufferGeometry, lodLevel: number): void {
    // In full implementation: update position, scale, color, rotation attributes
    // for instanced rendering performance
    const maxParticles = Math.min(
      system.activeParticles,
      this.#lodConfig.particleCounts[lodLevel]
    );
    
    // Placeholder for instanced attribute updates
    this.#logger.debug('Updating instanced attributes', {
      systemId: system.id,
      particles: maxParticles,
      lodLevel
    });
  }
  
  /**
   * Update render batch with current particle data
   * @param batch - Particle batch to update
   * @param system - Particle system
   * @param lodLevel - Current LOD level
   */
  #updateBatch(batch: ParticleBatch, system: ParticleSystem, lodLevel: number): void {
    batch.instanceCount = Math.min(
      system.activeParticles,
      this.#lodConfig.particleCounts[lodLevel]
    );
    batch.needsUpdate = true;
    
    this.#logger.debug('Batch updated', {
      batchId: batch.id,
      instanceCount: batch.instanceCount,
      lodLevel
    });
  }
}

// Export singleton instance getter
export const particleService = ParticleService.getInstance();
