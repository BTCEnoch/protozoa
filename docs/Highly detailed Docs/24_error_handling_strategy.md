# Error Handling Strategy

This document outlines the comprehensive error handling strategy for the Beast Import project, focusing on graceful error recovery and user feedback.

## Error Handling Philosophy

Since the application will be deployed as an immutable inscription on Bitcoin, error handling is critical:

1. **Prevention First**: Prevent errors through thorough testing and validation
2. **Graceful Degradation**: When errors occur, degrade gracefully rather than crashing
3. **Informative Feedback**: Provide clear, helpful information to users
4. **Recovery When Possible**: Attempt to recover from errors when feasible

## React Error Boundaries

Error boundaries are React components that catch JavaScript errors in their child component tree, log those errors, and display a fallback UI.

### Implementation

```tsx
import React, { Component, ErrorInfo, ReactNode } from 'react';

interface ErrorBoundaryProps {
  children: ReactNode;
  fallback?: ReactNode;
  onError?: (error: Error, errorInfo: ErrorInfo) => void;
}

interface ErrorBoundaryState {
  hasError: boolean;
  error: Error | null;
}

class ErrorBoundary extends Component<ErrorBoundaryProps, ErrorBoundaryState> {
  constructor(props: ErrorBoundaryProps) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error: Error): ErrorBoundaryState {
    // Update state so the next render will show the fallback UI
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo): void {
    // Log the error to an error reporting service
    console.error('Error caught by ErrorBoundary:', error, errorInfo);
    
    // Call the onError callback if provided
    if (this.props.onError) {
      this.props.onError(error, errorInfo);
    }
  }

  render(): ReactNode {
    if (this.state.hasError) {
      // Render fallback UI
      if (this.props.fallback) {
        return this.props.fallback;
      }
      
      // Default fallback UI
      return (
        <div className="error-boundary">
          <h2>Something went wrong.</h2>
          <p>The application encountered an error. Please try refreshing the page.</p>
          {this.state.error && (
            <details>
              <summary>Error details</summary>
              <pre>{this.state.error.toString()}</pre>
            </details>
          )}
        </div>
      );
    }

    return this.props.children;
  }
}

export default ErrorBoundary;
```

### Error Boundary Hierarchy

Error boundaries should be strategically placed in the component tree:

```tsx
const App = () => {
  return (
    <ErrorBoundary fallback={<CriticalErrorScreen />} onError={logCriticalError}>
      {/* App-wide error boundary */}
      <Layout>
        <Header />
        <ErrorBoundary fallback={<ParticleSimulationError />} onError={logSimulationError}>
          {/* Simulation-specific error boundary */}
          <ParticleSimulation />
        </ErrorBoundary>
        <ErrorBoundary fallback={<ControlPanelError />} onError={logControlError}>
          {/* Control panel-specific error boundary */}
          <ControlPanel />
        </ErrorBoundary>
      </Layout>
    </ErrorBoundary>
  );
};
```

### Custom Error Components

Create specific error components for different parts of the application:

```tsx
const ParticleSimulationError = () => (
  <div className="simulation-error">
    <h3>Simulation Error</h3>
    <p>There was a problem with the particle simulation. The application will attempt to recover.</p>
    <button onClick={() => window.location.reload()}>Reload Application</button>
  </div>
);

const ControlPanelError = () => (
  <div className="control-panel-error">
    <h3>Control Panel Error</h3>
    <p>There was a problem with the control panel. You can still view the simulation.</p>
    <button onClick={() => window.location.reload()}>Reload Application</button>
  </div>
);

const CriticalErrorScreen = () => (
  <div className="critical-error">
    <h2>Critical Error</h2>
    <p>The application encountered a critical error and cannot continue.</p>
    <p>Please try refreshing the page or come back later.</p>
    <button onClick={() => window.location.reload()}>Reload Application</button>
  </div>
);
```

## Error Recovery Strategies

### 1. Component Reset

For component-level errors, reset the component to its initial state:

```tsx
const ParticleGroup = () => {
  const [error, setError] = useState<Error | null>(null);
  const [key, setKey] = useState(0);
  
  const handleError = (err: Error) => {
    setError(err);
    // Log the error
    console.error('Particle group error:', err);
    // Reset the component
    setKey(prev => prev + 1);
  };
  
  if (error) {
    return (
      <div className="particle-group-error">
        <p>Error in particle group. Attempting to recover...</p>
        <button onClick={() => setKey(prev => prev + 1)}>Retry</button>
      </div>
    );
  }
  
  return (
    <ErrorBoundary onError={handleError}>
      <ParticleGroupRenderer key={key} />
    </ErrorBoundary>
  );
};
```

### 2. State Rollback

For state-related errors, roll back to a previous valid state:

```tsx
const useSimulationState = () => {
  const [currentState, setCurrentState] = useState(initialState);
  const [previousState, setPreviousState] = useState(initialState);
  
  const updateState = (newState) => {
    try {
      // Validate the new state
      validateState(newState);
      
      // Store the current state as previous
      setPreviousState(currentState);
      
      // Update to the new state
      setCurrentState(newState);
    } catch (error) {
      // Log the error
      console.error('Invalid state update:', error);
      
      // Keep the current state
      return false;
    }
    
    return true;
  };
  
  const rollbackState = () => {
    // Roll back to the previous state
    setCurrentState(previousState);
  };
  
  return { currentState, updateState, rollbackState };
};
```

### 3. Feature Degradation

Disable features that are causing errors:

```tsx
const ParticleSimulation = () => {
  const [enabledFeatures, setEnabledFeatures] = useState({
    advancedPhysics: true,
    visualEffects: true,
    interactivity: true
  });
  
  const handlePhysicsError = () => {
    // Disable advanced physics
    setEnabledFeatures(prev => ({
      ...prev,
      advancedPhysics: false
    }));
  };
  
  const handleVisualError = () => {
    // Disable visual effects
    setEnabledFeatures(prev => ({
      ...prev,
      visualEffects: false
    }));
  };
  
  return (
    <div>
      <ErrorBoundary onError={handlePhysicsError}>
        <PhysicsEngine advanced={enabledFeatures.advancedPhysics} />
      </ErrorBoundary>
      
      <ErrorBoundary onError={handleVisualError}>
        <VisualEffects enabled={enabledFeatures.visualEffects} />
      </ErrorBoundary>
    </div>
  );
};
```

## Async Error Handling

### Promise Error Handling

```tsx
const fetchBlockData = async (blockNumber: number) => {
  try {
    const response = await fetch(`/api/block/${blockNumber}`);
    
    if (!response.ok) {
      throw new Error(`HTTP error ${response.status}`);
    }
    
    return await response.json();
  } catch (error) {
    // Log the error
    console.error('Error fetching block data:', error);
    
    // Return fallback data
    return getFallbackBlockData(blockNumber);
  }
};
```

### React Query for API Calls

```tsx
import { useQuery } from 'react-query';

const useBlockData = (blockNumber: number) => {
  return useQuery(
    ['blockData', blockNumber],
    () => fetchBlockData(blockNumber),
    {
      retry: 3,
      retryDelay: (attemptIndex) => Math.min(1000 * 2 ** attemptIndex, 30000),
      onError: (error) => {
        console.error('Failed to fetch block data:', error);
      },
      fallbackData: getFallbackBlockData(blockNumber)
    }
  );
};
```

## Web Worker Error Handling

```tsx
const usePhysicsWorker = () => {
  const [error, setError] = useState<Error | null>(null);
  const workerRef = useRef<Worker | null>(null);
  
  useEffect(() => {
    try {
      // Create worker
      workerRef.current = new Worker(new URL('../workers/physics.worker.ts', import.meta.url));
      
      // Handle worker errors
      workerRef.current.onerror = (event) => {
        console.error('Physics worker error:', event);
        setError(new Error('Physics worker failed'));
        
        // Attempt to restart the worker
        restartWorker();
      };
      
      // Handle worker messages
      workerRef.current.onmessage = (event) => {
        // Process worker message
      };
    } catch (error) {
      console.error('Failed to create physics worker:', error);
      setError(error as Error);
    }
    
    return () => {
      workerRef.current?.terminate();
    };
  }, []);
  
  const restartWorker = () => {
    // Terminate existing worker
    workerRef.current?.terminate();
    
    // Create new worker
    try {
      workerRef.current = new Worker(new URL('../workers/physics.worker.ts', import.meta.url));
      // Re-initialize worker
    } catch (error) {
      console.error('Failed to restart physics worker:', error);
      setError(error as Error);
    }
  };
  
  return { worker: workerRef.current, error, restartWorker };
};
```

## Resource Loading Error Handling

```tsx
const useResource = (inscriptionId: string) => {
  const [resource, setResource] = useState<any>(null);
  const [error, setError] = useState<Error | null>(null);
  const [loading, setLoading] = useState(true);
  
  useEffect(() => {
    const loadResource = async () => {
      try {
        setLoading(true);
        
        // Try to load from inscription
        const inscriptionUrl = `/content/${inscriptionId}`;
        const response = await fetch(inscriptionUrl);
        
        if (!response.ok) {
          throw new Error(`Failed to load resource: ${response.status}`);
        }
        
        const data = await response.json();
        setResource(data);
      } catch (error) {
        console.error('Resource loading error:', error);
        setError(error as Error);
        
        // Try to load fallback
        try {
          const fallbackData = getFallbackResource(inscriptionId);
          setResource(fallbackData);
          // Clear error since we have fallback
          setError(null);
        } catch (fallbackError) {
          console.error('Fallback resource loading error:', fallbackError);
          // Keep the original error
        }
      } finally {
        setLoading(false);
      }
    };
    
    loadResource();
  }, [inscriptionId]);
  
  return { resource, error, loading };
};
```

## User Feedback

### Error Messages

```tsx
const ErrorMessage = ({ error, retry }: { error: Error; retry?: () => void }) => {
  // Determine error type and message
  let title = 'Error';
  let message = 'An unexpected error occurred.';
  
  if (error.message.includes('network') || error.message.includes('fetch')) {
    title = 'Network Error';
    message = 'Unable to connect to the server. Please check your internet connection.';
  } else if (error.message.includes('timeout')) {
    title = 'Request Timeout';
    message = 'The server took too long to respond. Please try again later.';
  } else if (error.message.includes('memory')) {
    title = 'Memory Error';
    message = 'The application ran out of memory. Try closing other tabs or refreshing the page.';
  }
  
  return (
    <div className="error-message">
      <h3>{title}</h3>
      <p>{message}</p>
      {retry && (
        <button onClick={retry}>Try Again</button>
      )}
    </div>
  );
};
```

### Loading States

```tsx
const LoadingState = ({ status, progress }: { status: string; progress?: number }) => {
  return (
    <div className="loading-state">
      <div className="spinner"></div>
      <p>{status}</p>
      {progress !== undefined && (
        <div className="progress-bar">
          <div className="progress" style={{ width: `${progress}%` }}></div>
        </div>
      )}
    </div>
  );
};
```

### Error Logging

```tsx
const logError = (error: Error, context: Record<string, any> = {}) => {
  // In development, log to console
  if (process.env.NODE_ENV === 'development') {
    console.error('Error:', error, 'Context:', context);
  }
  
  // In production, log to local storage for debugging
  if (process.env.NODE_ENV === 'production') {
    try {
      const errors = JSON.parse(localStorage.getItem('error_log') || '[]');
      errors.push({
        timestamp: new Date().toISOString(),
        message: error.message,
        stack: error.stack,
        context
      });
      
      // Keep only the last 10 errors
      if (errors.length > 10) {
        errors.shift();
      }
      
      localStorage.setItem('error_log', JSON.stringify(errors));
    } catch (e) {
      // Ignore localStorage errors
    }
  }
};
```

## Implementation Plan

1. **Set Up Error Boundaries**:
   - Create ErrorBoundary component
   - Place error boundaries strategically in the component tree

2. **Implement Recovery Strategies**:
   - Component reset mechanism
   - State rollback system
   - Feature degradation approach

3. **Add Async Error Handling**:
   - Promise error handling
   - React Query setup
   - Web Worker error handling

4. **Create User Feedback Components**:
   - Error message components
   - Loading state components
   - Progress indicators

5. **Implement Error Logging**:
   - Development logging
   - Production logging to local storage

6. **Test Error Scenarios**:
   - Component errors
   - API errors
   - Resource loading errors
   - Worker errors
