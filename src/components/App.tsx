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
        console.log('âœ… Protozoa services initialized')
      } catch (err) {
        const errorMsg = err instanceof Error ? err.message : 'Unknown error'
        setError(errorMsg)
        console.error('âŒ Failed to initialize services:', errorMsg)
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
        <h2>ðŸš« Initialization Error</h2>
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
