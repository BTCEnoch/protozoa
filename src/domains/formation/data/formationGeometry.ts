/**
 * @fileoverview Formation pattern data definitions and geometric calculations
 * @module @/domains/formation/data
 * @version 1.0.0
 *
 * Contains predefined formation patterns for particle arrangements including
 * geometric shapes, organic patterns, and custom formations.
 *
 * Reference: build_design.md Section 2 - Formation pattern definitions
 * Reference: .cursorrules Domain Data Standards
 */

import { IVector3, IFormationPattern } from "@/shared/types";

/**
 * Utility functions for generating geometric formation patterns
 * These functions create position arrays for common 3D shapes
 */
export class FormationGeometry {
  /**
   * Generates positions for particles arranged in a sphere
   * @param particleCount - Number of particles to position
   * @param radius - Radius of the sphere
   * @returns Array of 3D positions on sphere surface
   */
  static generateSpherePositions(particleCount: number, radius: number = 50): IVector3[] {
    const positions: IVector3[] = [];
    const goldenAngle = Math.PI * (3 - Math.sqrt(5)); // Golden angle in radians

    for (let i = 0; i < particleCount; i++) {
      // Use golden spiral distribution for even spacing
      const y = 1 - (i / (particleCount - 1)) * 2; // y goes from 1 to -1
      const radiusAtY = Math.sqrt(1 - y * y);
      const theta = goldenAngle * i;

      const x = Math.cos(theta) * radiusAtY * radius;
      const z = Math.sin(theta) * radiusAtY * radius;

      positions.push({ x, y: y * radius, z });
    }

    return positions;
  }

  /**
   * Generates positions for particles arranged in a cube
   * @param particleCount - Number of particles to position
   * @param size - Size of the cube
   * @returns Array of 3D positions within cube volume
   */
  static generateCubePositions(particleCount: number, size: number = 100): IVector3[] {
    const positions: IVector3[] = [];
    const particlesPerSide = Math.ceil(Math.cbrt(particleCount));
    const spacing = size / (particlesPerSide - 1);
    const offset = size / 2;

    for (let i = 0; i < particleCount; i++) {
      const x = (i % particlesPerSide) * spacing - offset;
      const y = (Math.floor(i / particlesPerSide) % particlesPerSide) * spacing - offset;
      const z = Math.floor(i / (particlesPerSide * particlesPerSide)) * spacing - offset;

      positions.push({ x, y, z });
    }

    return positions.slice(0, particleCount);
  }

  /**
   * Generates positions for particles arranged in a cylinder
   * @param particleCount - Number of particles to position
   * @param radius - Radius of the cylinder
   * @param height - Height of the cylinder
   * @returns Array of 3D positions within cylinder
   */
  static generateCylinderPositions(particleCount: number, radius: number = 50, height: number = 100): IVector3[] {
    const positions: IVector3[] = [];
    const layers = Math.ceil(Math.sqrt(particleCount));
    const particlesPerLayer = Math.ceil(particleCount / layers);

    for (let i = 0; i < particleCount; i++) {
      const layer = Math.floor(i / particlesPerLayer);
      const indexInLayer = i % particlesPerLayer;

      const y = (layer / (layers - 1)) * height - height / 2;
      const angle = (indexInLayer / particlesPerLayer) * 2 * Math.PI;
      const r = radius * Math.sqrt(Math.random()); // Random radius for volume distribution

      const x = Math.cos(angle) * r;
      const z = Math.sin(angle) * r;

      positions.push({ x, y, z });
    }

    return positions;
  }

  /**
   * Generates positions for particles arranged in a helix/spiral
   * @param particleCount - Number of particles to position
   * @param radius - Radius of the helix
   * @param height - Total height of the helix
   * @param turns - Number of complete turns
   * @returns Array of 3D positions along helix path
   */
  static generateHelixPositions(particleCount: number, radius: number = 30, height: number = 100, turns: number = 3): IVector3[] {
    const positions: IVector3[] = [];
    const angleStep = (turns * 2 * Math.PI) / particleCount;
    const heightStep = height / particleCount;

    for (let i = 0; i < particleCount; i++) {
      const angle = i * angleStep;
      const y = i * heightStep - height / 2;

      const x = Math.cos(angle) * radius;
      const z = Math.sin(angle) * radius;

      positions.push({ x, y, z });
    }

    return positions;
  }

  /**
   * Generates positions for particles arranged in a torus (donut shape)
   * @param particleCount - Number of particles to position
   * @param majorRadius - Major radius of the torus
   * @param minorRadius - Minor radius of the torus
   * @returns Array of 3D positions on torus surface
   */
  static generateTorusPositions(particleCount: number, majorRadius: number = 50, minorRadius: number = 20): IVector3[] {
    const positions: IVector3[] = [];
    const goldenAngle = Math.PI * (3 - Math.sqrt(5));

    for (let i = 0; i < particleCount; i++) {
      const u = (i / particleCount) * 2 * Math.PI;
      const v = (i * goldenAngle) % (2 * Math.PI);

      const x = (majorRadius + minorRadius * Math.cos(v)) * Math.cos(u);
      const y = minorRadius * Math.sin(v);
      const z = (majorRadius + minorRadius * Math.cos(v)) * Math.sin(u);

      positions.push({ x, y, z });
    }

    return positions;
  }
}
