import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'

export default defineConfig({
  plugins: [react({ jsxRuntime: 'automatic' })],
  server: { 
    port: 3000,
    host: true
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
      '@/components': path.resolve(__dirname, './src/components'),
      '@/shared': path.resolve(__dirname, './src/shared'),
      '@/domains': path.resolve(__dirname, './src/domains'),
      '@/lib': path.resolve(__dirname, './src/lib'),
      '@/types': path.resolve(__dirname, './src/types')
    }
  },
  build: {
    outDir: 'dist',
    sourcemap: true,
    target: 'esnext',
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom'],
          three: ['three', '@react-three/fiber', '@react-three/drei']
        }
      }
    }
  },
  optimizeDeps: {
    include: ['react', 'react-dom', 'three', '@react-three/fiber']
  },
  define: {
    USE_WORKERS: 'true',
    // Ensure Node.js globals are properly handled in browser
    global: 'globalThis',
    'process.env': {}
  },
  esbuild: {
    jsxFactory: 'React.createElement',
    jsxFragment: 'React.Fragment'
  }
})
