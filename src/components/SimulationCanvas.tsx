import React, { useRef, useEffect, useState } from 'react'

export function SimulationCanvas() {
  const mountRef = useRef<HTMLDivElement>(null)
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    async function initializeThreeJS() {
      try {
        console.log('ðŸŽ® Initializing THREE.js simulation...')
        
        // Placeholder for THREE.js initialization
        // This will be replaced with actual simulation code
        setTimeout(() => {
          setIsLoading(false)
          console.log('âœ… Simulation ready (development mode)')
        }, 1000)
        
      } catch (err) {
        const errorMsg = err instanceof Error ? err.message : 'Unknown error'
        setError(errorMsg)
        setIsLoading(false)
        console.error('âŒ Failed to initialize THREE.js:', errorMsg)
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
        <h3>ðŸŽ® Simulation Error</h3>
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
          ðŸ§¬ PROTOZOA v0.1.0 - DEV MODE
        </div>
      )}
    </div>
  )
}
