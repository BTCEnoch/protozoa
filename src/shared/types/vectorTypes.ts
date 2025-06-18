/**
 * Vector and Mathematical Types
 * Shared vector and mathematical interfaces used across domains
 * Provides compatibility layer with THREE.js while maintaining domain independence
 */

/**
 * 3D Vector interface compatible with THREE.js Vector3
 * Used throughout particle, physics, formation, and rendering domains
 */
export interface IVector3 {
  x: number;
  y: number;
  z: number;
}

/**
 * 2D Vector interface for UI coordinates and planar calculations
 */
export interface IVector2 {
  x: number;
  y: number;
}

/**
 * Quaternion interface for 3D rotations
 * Compatible with THREE.js Quaternion
 */
export interface IQuaternion {
  x: number;
  y: number;
  z: number;
  w: number;
}

/**
 * Color interface with RGB and optional alpha
 */
export interface IColor {
  r: number;
  g: number;
  b: number;
  a?: number;
}

/**
 * Bounding box interface for collision detection and spatial queries
 */
export interface IBoundingBox {
  min: IVector3;
  max: IVector3;
}

/**
 * Transform interface combining position, rotation, and scale
 */
export interface ITransform {
  position: IVector3;
  rotation: IQuaternion;
  scale: IVector3;
}

/**
 * Range interface for numeric ranges with min/max bounds
 */
export interface IRange {
  min: number;
  max: number;
}

/**
 * Utility type for any vector-like object
 */
export type VectorLike = IVector3 | IVector2;

/**
 * Utility type for transformation matrices
 */
export type Matrix4Like = number[];
