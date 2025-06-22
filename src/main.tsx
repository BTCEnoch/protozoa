import React from 'react'
import ReactDOM from 'react-dom/client'
import './index.css'

// Temporary placeholder component for build validation
function App() {
  return (
    <div className="App">
      <h1>Protozoa Automation Suite</h1>
      <p>This is a placeholder during automation setup.</p>
    </div>
  )
}

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
)
