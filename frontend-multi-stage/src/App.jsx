import React from 'react'

function App() {
  return (
    <div style={{
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center',
      height: '100vh',
      textAlign: 'center',
      padding: '0 20px'
    }}>
      <h1 style={{ color: '#4285F4', fontSize: '2.5rem', marginBottom: '10px' }}>
        ¡Hola desde React + Vite! 🚀
      </h1>
      <p style={{ fontSize: '1.2rem', color: '#9aa0a6', maxWidth: '600px', lineHeight: '1.6' }}>
        Este frontend se compiló en una etapa temporal de Node.js y se está sirviendo mediante una imagen optimizada de Nginx.
      </p>
      <div style={{
        marginTop: '30px',
        padding: '15px 25px',
        backgroundColor: '#1e1e1e',
        borderRadius: '8px',
        border: '1px solid #333'
      }}>
        <code style={{ color: '#34A853' }}>Dockerfile: Multi-Stage Build Complete</code>
      </div>
    </div>
  )
}

export default App
