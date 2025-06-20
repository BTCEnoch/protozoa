/// <reference types="vitest" />
import react from '@vitejs/plugin-react'
import { resolve } from 'path'
import { defineConfig } from 'vite'

export default defineConfig({
  plugins: [react()],
  
  // Development server configuration
  server: {
    port: 3000,
    open: true,
    host: true
  },

  // Build configuration
  build: {
    outDir: 'dist',
    sourcemap: true,
    target: 'esnext',
    minify: 'esbuild',
    rollupOptions: {
      output: {
        manualChunks: {
          'vendor-react': ['react', 'react-dom'],
          'vendor-three': ['three', '@react-three/fiber', '@react-three/drei'],
          'vendor-utils': ['winston', 'zustand', 'cross-fetch']
        }
      }
    }
  },

  // Path resolution for TypeScript aliases
  resolve: {
    alias: {
      '@': resolve(__dirname, './src'),
      '@/domains': resolve(__dirname, './src/domains'),
      '@/shared': resolve(__dirname, './src/shared'),
      '@/components': resolve(__dirname, './src/components'),
      '@/config': resolve(__dirname, './src/config')
    }
  },

  // Define global constants
  define: {
    __DEV__: JSON.stringify(process.env.NODE_ENV === 'development'),
    __PROD__: JSON.stringify(process.env.NODE_ENV === 'production')
  },

  // Testing configuration with Vitest
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: ['./src/test/setup.ts'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      exclude: [
        'node_modules/',
        'src/test/',
        '**/*.d.ts',
        '**/*.test.{ts,tsx}',
        '**/*.spec.{ts,tsx}'
      ]
    }
  },

  // ESBuild configuration for TypeScript
  esbuild: {
    target: 'esnext',
    format: 'esm'
  },

  // Optimization configuration
  optimizeDeps: {
    include: [
      'react',
      'react-dom',
      'three',
      '@react-three/fiber',
      '@react-three/drei',
      'winston',
      'zustand',
      'cross-fetch'
    ]
  }
}) 