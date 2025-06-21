// shaderLibrary.ts â€“ collection of GLSL snippets
export const Shaders = {
  dnaVis: `
    varying vec2 vUv;
    void main() {
      vec2 uv = vUv;
      float stripe = smoothstep(0.45, 0.55, abs(sin(uv.y * 20.0)));
      gl_FragColor = vec4(vec3(stripe), 1.0);
    }
  `,
  particleInstancing: `
    attribute vec3 offset;
    void main() {
      vec3 pos = position + offset;
      gl_Position = projectionMatrix * modelViewMatrix * vec4(pos, 1.0);
    }
  `
}
