# 60-SetupBrowserServerRequirements.ps1 - Phase 8 Critical
# Sets up all browser/server requirements for React development including Vite config, index.html, path aliases

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $false)]
    [string]$ProjectRoot = $PWD,
    
    [Parameter(Mandatory = $false)]
    [switch]$DryRun
)

try { 
    Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop 
} catch { 
    Write-Error "utils.psm1 import failed: $($_.Exception.Message)"
    exit 1 
}

$ErrorActionPreference = "Stop"

try {
    Write-StepHeader "Browser/Server Requirements Setup"
    Write-InfoLog "Setting up Vite configuration, index.html, and path aliases"

    # 1. Fix Vite Configuration with Path Aliases
    Write-InfoLog "Generating Vite configuration with proper path aliases"
    $viteConfigPath = Join-Path $ProjectRoot "vite.config.ts"
    $viteConfigContent = @'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'

export default defineConfig({
  plugins: [react()],
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
    // Ensure Node.js globals are properly handled in browser
    global: 'globalThis'
  }
})
'@

    if (-not $DryRun) {
        Set-Content -Path $viteConfigPath -Value $viteConfigContent -Encoding UTF8
        Write-SuccessLog "Vite configuration generated with path aliases"
    }

    # 2. Create index.html with proper structure
    Write-InfoLog "Creating index.html entry point"
    $indexHtmlPath = Join-Path $ProjectRoot "index.html"
    $indexHtmlContent = @'
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/protozoa-icon.svg" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Protozoa - Bitcoin Ordinals Digital Organisms</title>
    <meta name="description" content="Bitcoin Ordinals digital unicellular organisms with on-chain physics" />
    <style>
      body {
        margin: 0;
        padding: 0;
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;
        background: #0a0a0a;
        color: #ffffff;
        overflow: hidden;
      }
      
      #root {
        width: 100vw;
        height: 100vh;
        position: relative;
      }
      
      .loading {
        position: absolute;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        text-align: center;
        z-index: 1000;
      }
      
      .loading-spinner {
        width: 40px;
        height: 40px;
        border: 3px solid rgba(255, 255, 255, 0.1);
        border-top: 3px solid #ff6b35;
        border-radius: 50%;
        animation: spin 1s linear infinite;
        margin: 0 auto 20px;
      }
      
      @keyframes spin {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
      }
      
      .loading-text {
        font-size: 14px;
        opacity: 0.7;
        letter-spacing: 1px;
      }
    </style>
  </head>
  <body>
    <div id="root">
      <div class="loading">
        <div class="loading-spinner"></div>
        <div class="loading-text">LOADING PROTOZOA...</div>
      </div>
    </div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
'@

    if (-not $DryRun) {
        Set-Content -Path $indexHtmlPath -Value $indexHtmlContent -Encoding UTF8
        Write-SuccessLog "index.html created with loading animation"
    }

    # 3. Create a simple favicon placeholder
    Write-InfoLog "Creating favicon placeholder"
    $faviconPath = Join-Path $ProjectRoot "public"
    if (-not (Test-Path $faviconPath)) {
        New-Item -ItemType Directory -Path $faviconPath -Force | Out-Null
    }

    # 4. Fix App component to handle missing dependencies gracefully
    Write-InfoLog "Updating App component for development mode"
    $appComponentPath = Join-Path $ProjectRoot "src/components/App.tsx"
    $appComponentContent = @'
import React, { useEffect, useState } from 'react'
import { SimulationCanvas } from '@/components/SimulationCanvas'

export default function App() {
  const [servicesInitialized, setServicesInitialized] = useState(false)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    async function initializeServices() {
      try {
        // Lazy load composition root to avoid blocking initial render
        const { initServices } = await import('@/compositionRoot')
        await initServices()
        setServicesInitialized(true)
        console.log('✅ Protozoa services initialized')
      } catch (err) {
        const errorMsg = err instanceof Error ? err.message : 'Unknown error'
        setError(errorMsg)
        console.error('❌ Failed to initialize services:', errorMsg)
      }
    }

    initializeServices()
  }, [])

  if (error) {
    return (
      <div style={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        height: '100vh',
        background: '#0a0a0a',
        color: '#ff4444',
        fontFamily: 'monospace',
        textAlign: 'center',
        padding: '20px'
      }}>
        <h2>🚫 Initialization Error</h2>
        <p>Failed to start Protozoa application</p>
        <details style={{ marginTop: '20px', fontSize: '12px', opacity: 0.7 }}>
          <summary>Error Details</summary>
          <pre style={{ marginTop: '10px', background: '#1a1a1a', padding: '10px', borderRadius: '4px' }}>
            {error}
          </pre>
        </details>
      </div>
    )
  }

  if (!servicesInitialized) {
    return (
      <div style={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        height: '100vh',
        background: '#0a0a0a',
        color: '#ffffff',
        fontFamily: 'monospace'
      }}>
        <div style={{
          width: '40px',
          height: '40px',
          border: '3px solid rgba(255, 255, 255, 0.1)',
          borderTop: '3px solid #ff6b35',
          borderRadius: '50%',
          animation: 'spin 1s linear infinite',
          marginBottom: '20px'
        }} />
        <div style={{ fontSize: '14px', opacity: 0.7, letterSpacing: '1px' }}>
          INITIALIZING SERVICES...
        </div>
      </div>
    )
  }

  return (
    <div style={{ width: '100vw', height: '100vh', position: 'relative' }}>
      <SimulationCanvas />
    </div>
  )
}
'@

    if (-not $DryRun) {
        Set-Content -Path $appComponentPath -Value $appComponentContent -Encoding UTF8
        Write-SuccessLog "App component updated with error handling"
    }

    # 5. Update SimulationCanvas to handle development mode
    Write-InfoLog "Updating SimulationCanvas for development mode"
    $canvasComponentPath = Join-Path $ProjectRoot "src/components/SimulationCanvas.tsx"
    $canvasComponentContent = @'
import React, { useRef, useEffect, useState } from 'react'

export function SimulationCanvas() {
  const mountRef = useRef<HTMLDivElement>(null)
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    async function initializeThreeJS() {
      try {
        console.log('🎮 Initializing THREE.js simulation...')
        
        // Placeholder for THREE.js initialization
        // This will be replaced with actual simulation code
        setTimeout(() => {
          setIsLoading(false)
          console.log('✅ Simulation ready (development mode)')
        }, 1000)
        
      } catch (err) {
        const errorMsg = err instanceof Error ? err.message : 'Unknown error'
        setError(errorMsg)
        setIsLoading(false)
        console.error('❌ Failed to initialize THREE.js:', errorMsg)
      }
    }

    initializeThreeJS()
  }, [])

  if (error) {
    return (
      <div style={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        height: '100%',
        color: '#ff4444',
        fontFamily: 'monospace',
        textAlign: 'center'
      }}>
        <h3>🎮 Simulation Error</h3>
        <p>Failed to initialize THREE.js simulation</p>
        <pre style={{ fontSize: '10px', opacity: 0.7, marginTop: '10px' }}>
          {error}
        </pre>
      </div>
    )
  }

  return (
    <div style={{ width: '100%', height: '100%', position: 'relative' }}>
      <div ref={mountRef} style={{ width: '100%', height: '100%' }} />
      
      {isLoading && (
        <div style={{
          position: 'absolute',
          top: '50%',
          left: '50%',
          transform: 'translate(-50%, -50%)',
          color: '#ffffff',
          fontFamily: 'monospace',
          textAlign: 'center'
        }}>
          <div style={{
            width: '30px',
            height: '30px',
            border: '2px solid rgba(255, 255, 255, 0.1)',
            borderTop: '2px solid #00ff88',
            borderRadius: '50%',
            animation: 'spin 1s linear infinite',
            margin: '0 auto 15px'
          }} />
          <div style={{ fontSize: '12px', opacity: 0.7 }}>
            LOADING SIMULATION...
          </div>
        </div>
      )}
      
      {!isLoading && (
        <div style={{
          position: 'absolute',
          bottom: '20px',
          left: '20px',
          color: '#00ff88',
          fontFamily: 'monospace',
          fontSize: '12px',
          opacity: 0.7
        }}>
          🧬 PROTOZOA v0.1.0 - DEV MODE
        </div>
      )}
    </div>
  )
}
'@

    if (-not $DryRun) {
        Set-Content -Path $canvasComponentPath -Value $canvasComponentContent -Encoding UTF8
        Write-SuccessLog "SimulationCanvas updated for development mode"
    }

    # 6. Create a development-ready composition root
    Write-InfoLog "Updating composition root for development"
    $compositionRootPath = Join-Path $ProjectRoot "src/compositionRoot.ts"
    $compositionRootContent = @'
/**
 * @fileoverview Composition Root - Dependency Injection Container
 * @description Initializes and manages all domain services
 * @author Protozoa Development Team
 * @version 1.0.0
 */

let servicesInitialized = false

export async function initServices(): Promise<void> {
  if (servicesInitialized) {
    console.log('⚠️ Services already initialized')
    return
  }

  console.log('🚀 Initializing Protozoa domain services...')
  
  try {
    // In development mode, we'll gradually initialize services
    // This prevents blocking the initial app load
    
    // Phase 1: Core utilities
    console.log('📦 Phase 1: Core utilities loading...')
    
    // Phase 2: Domain services (placeholder)
    console.log('🧬 Phase 2: Domain services loading...')
    
    // Phase 3: Integration services (placeholder)
    console.log('🔗 Phase 3: Integration services loading...')
    
    servicesInitialized = true
    console.log('✅ All services initialized successfully')
    
  } catch (error) {
    console.error('❌ Service initialization failed:', error)
    throw error
  }
}

export function disposeServices(): void {
  if (!servicesInitialized) {
    return
  }
  
  console.log('🧹 Disposing Protozoa services...')
  
  try {
    // Cleanup logic will go here
    servicesInitialized = false
    console.log('✅ Services disposed successfully')
  } catch (error) {
    console.error('❌ Service disposal failed:', error)
  }
}

export function getServiceStatus(): boolean {
  return servicesInitialized
}
'@

    if (-not $DryRun) {
        Set-Content -Path $compositionRootPath -Value $compositionRootContent -Encoding UTF8
        Write-SuccessLog "Composition root updated for development"
    }

    Write-SuccessLog "Browser/Server requirements setup completed successfully"
    Write-InfoLog "Ready to run: npm run dev"
    
    exit 0

} catch {
    Write-ErrorLog "Browser/Server requirements setup failed: $($_.Exception.Message)"
    exit 1
} 