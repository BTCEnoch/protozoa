/**
 * @fileoverview Predefined formation patterns for immediate use
 * @module @/domains/formation/data
 * @version 1.0.0
 *
 * Contains a collection of ready-to-use formation patterns including
 * basic geometric shapes and more complex organic arrangements.
 *
 * Reference: build_design.md Section 2 - Formation pattern definitions
 * Reference: .cursorrules Domain Data Standards
 */

import { IFormationPattern } from "../types/IFormationService";
import { FormationGeometry } from "./formationGeometry";

/**
 * Collection of predefined formation patterns
 * These patterns can be used immediately without additional configuration
 */
export class FormationPatterns {
  /**
   * Creates a sphere formation pattern
   * @param maxParticles - Maximum particles this pattern supports
   * @param radius - Radius of the sphere
   * @returns Sphere formation pattern
   */
  static createSpherePattern(maxParticles: number = 100, radius: number = 50): IFormationPattern {
    return {
      id: "sphere",
      name: "Sphere Formation",
      positions: FormationGeometry.generateSpherePositions(maxParticles, radius),
      maxParticles,
      type: "geometric",
      metadata: {
        scale: 1.0,
        rotation: { x: 0, y: 0, z: 0 },
        animation: {
          rotationSpeed: 0.01,
          pulseAmplitude: 0.1,
          pulseFrequency: 0.5
        }
      }
    };
  }

  /**
   * Creates a cube formation pattern
   * @param maxParticles - Maximum particles this pattern supports
   * @param size - Size of the cube
   * @returns Cube formation pattern
   */
  static createCubePattern(maxParticles: number = 125, size: number = 100): IFormationPattern {
    return {
      id: "cube",
      name: "Cube Formation",
      positions: FormationGeometry.generateCubePositions(maxParticles, size),
      maxParticles,
      type: "geometric",
      metadata: {
        scale: 1.0,
        rotation: { x: 0, y: 0, z: 0 },
        animation: {
          rotationSpeed: 0.005,
          pulseAmplitude: 0.05,
          pulseFrequency: 0.3
        }
      }
    };
  }

  /**
   * Creates a helix formation pattern
   * @param maxParticles - Maximum particles this pattern supports
   * @param radius - Radius of the helix
   * @param height - Height of the helix
   * @param turns - Number of complete turns
   * @returns Helix formation pattern
   */
  static createHelixPattern(maxParticles: number = 80, radius: number = 30, height: number = 100, turns: number = 3): IFormationPattern {
    return {
      id: "helix",
      name: "Helix Formation",
      positions: FormationGeometry.generateHelixPositions(maxParticles, radius, height, turns),
      maxParticles,
      type: "organic",
      metadata: {
        scale: 1.0,
        rotation: { x: 0, y: 0, z: 0 },
        animation: {
          rotationSpeed: 0.02,
          pulseAmplitude: 0.15,
          pulseFrequency: 0.8
        }
      }
    };
  }

  /**
   * Creates a torus formation pattern
   * @param maxParticles - Maximum particles this pattern supports
   * @param majorRadius - Major radius of the torus
   * @param minorRadius - Minor radius of the torus
   * @returns Torus formation pattern
   */
  static createTorusPattern(maxParticles: number = 120, majorRadius: number = 50, minorRadius: number = 20): IFormationPattern {
    return {
      id: "torus",
      name: "Torus Formation",
      positions: FormationGeometry.generateTorusPositions(maxParticles, majorRadius, minorRadius),
      maxParticles,
      type: "geometric",
      metadata: {
        scale: 1.0,
        rotation: { x: 0, y: 0, z: 0 },
        animation: {
          rotationSpeed: 0.015,
          pulseAmplitude: 0.08,
          pulseFrequency: 0.6
        }
      }
    };
  }

  /**
   * Creates a line formation pattern
   * @param maxParticles - Maximum particles this pattern supports
   * @param length - Length of the line
   * @returns Line formation pattern
   */
  static createLinePattern(maxParticles: number = 50, length: number = 100): IFormationPattern {
    const positions = [];
    const spacing = length / (maxParticles - 1);
    const offset = length / 2;

    for (let i = 0; i < maxParticles; i++) {
      positions.push({
        x: i * spacing - offset,
        y: 0,
        z: 0
      });
    }

    return {
      id: "line",
      name: "Line Formation",
      positions,
      maxParticles,
      type: "geometric",
      metadata: {
        scale: 1.0,
        rotation: { x: 0, y: 0, z: 0 }
      }
    };
  }

  /**
   * Creates a circle formation pattern
   * @param maxParticles - Maximum particles this pattern supports
   * @param radius - Radius of the circle
   * @returns Circle formation pattern
   */
  static createCirclePattern(maxParticles: number = 60, radius: number = 40): IFormationPattern {
    const positions = [];
    const angleStep = (2 * Math.PI) / maxParticles;

    for (let i = 0; i < maxParticles; i++) {
      const angle = i * angleStep;
      positions.push({
        x: Math.cos(angle) * radius,
        y: 0,
        z: Math.sin(angle) * radius
      });
    }

    return {
      id: "circle",
      name: "Circle Formation",
      positions,
      maxParticles,
      type: "geometric",
      metadata: {
        scale: 1.0,
        rotation: { x: 0, y: 0, z: 0 },
        animation: {
          rotationSpeed: 0.01,
          pulseAmplitude: 0.1,
          pulseFrequency: 0.4
        }
      }
    };
  }

  /**
   * Gets all default formation patterns
   * @returns Array of all predefined formation patterns
   */
  static getAllDefaultPatterns(): IFormationPattern[] {
    return [
      this.createSpherePattern(),
      this.createCubePattern(),
      this.createHelixPattern(),
      this.createTorusPattern(),
      this.createLinePattern(),
      this.createCirclePattern()
    ];
  }

  /**
   * Gets a specific pattern by ID
   * @param patternId - ID of the pattern to retrieve
   * @returns Formation pattern if found, undefined otherwise
   */
  static getPatternById(patternId: string): IFormationPattern | undefined {
    const patterns = this.getAllDefaultPatterns();
    return patterns.find(pattern => pattern.id === patternId);
  }
}

// Export individual pattern creators for convenience
export const {
  createSpherePattern,
  createCubePattern,
  createHelixPattern,
  createTorusPattern,
  createLinePattern,
  createCirclePattern,
  getAllDefaultPatterns,
  getPatternById
} = FormationPatterns; 