import { defineConfig } from 'vitest/config'
import path from 'path'

export default defineConfig({
  test: {
    globals: true,
    environment: 'jsdom',
    testTimeout: 10000, // 10 second timeout for worker tests
    setupFiles: ['./test-setup.ts'],
    exclude: [
      '**/node_modules/**',
      '**/dist/**',
      '**/build/**',
      '**/e2e/**', // Exclude E2E tests - they should run with Playwright
      '**/*.e2e.test.ts',
      '**/*.e2e.spec.ts',
      '**/tests/e2e/**', // Exclude E2E directory
    ],
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
      '@/domains': path.resolve(__dirname, './src/domains'),
      '@/shared': path.resolve(__dirname, './src/shared'),
      '@/components': path.resolve(__dirname, './src/components'),
      '@/lib': path.resolve(__dirname, './src/shared/lib'),
      '@/types': path.resolve(__dirname, './src/types'),
    },
  },
})
