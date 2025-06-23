/** Shared vector math interfaces (Template) */
export interface IVector3 { 
  x: number
  y: number
  z: number
  clone?(): IVector3
}

export interface IVector2 { 
  x: number
  y: number
  clone?(): IVector2
}

export interface IQuaternion { 
  x: number
  y: number
  z: number
  w: number
  clone?(): IQuaternion
}

export interface IColor { 
  r: number
  g: number
  b: number
  a?: number
  clone?(): IColor
}
