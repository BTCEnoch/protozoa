/**
 * Core entity type definitions
 */

import { Vector3 } from "three";

// Base entity interface
export interface BaseEntity {
  id: string;
  position: Vector3;
  createdAt: number;
  updatedAt: number;
}

// Particle entity
export interface ParticleEntity extends BaseEntity {
  velocity: Vector3;
  scale: Vector3;
  rotation: number;
  age: number;
  lifetime: number;
  active: boolean;
}

// Group entity
export interface GroupEntity extends BaseEntity {
  memberIds: string[];
  bounds: Vector3;
  centerOfMass: Vector3;
}
