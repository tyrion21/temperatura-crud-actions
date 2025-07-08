import { useState, useEffect } from 'react'
import axios from 'axios'

interface Temperatura {
  id: number
  valor: number
  ubicacion: string
  fechaCreacion: string
}

export default function Home() {
  const [temperaturas, setTemperaturas] = useState<Temperatura[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [newTemperatura, setNewTemperatura] = useState({
    valor: '',
    ubicacion: ''
  })

  const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8081'

  useEffect(() => {
    fetchTemperaturas()
  }, [])

  const fetchTemperaturas = async () => {
    try {
      setLoading(true)
      const response = await axios.get(`${API_URL}/api/temperaturas`)
      setTemperaturas(response.data)
      setError(null)
    } catch (err) {
      setError('Error al cargar las temperaturas')
      console.error('Error:', err)
    } finally {
      setLoading(false)
    }
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    try {
      await axios.post(`${API_URL}/api/temperaturas`, {
        valor: parseFloat(newTemperatura.valor),
        ubicacion: newTemperatura.ubicacion
      })
      setNewTemperatura({ valor: '', ubicacion: '' })
      fetchTemperaturas()
    } catch (err) {
      setError('Error al crear la temperatura')
      console.error('Error:', err)
    }
  }

  const handleDelete = async (id: number) => {
    try {
      await axios.delete(`${API_URL}/api/temperaturas/${id}`)
      fetchTemperaturas()
    } catch (err) {
      setError('Error al eliminar la temperatura')
      console.error('Error:', err)
    }
  }

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleString('es-ES', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit'
    })
  }

  return (
    <div className="container">
      <header className="header">
        <h1>🌡️ Temperatura CRUD - GitHub Actions</h1>
        <p>Gestión de temperaturas con CI/CD automatizado</p>
      </header>

      <main className="main">
        <div className="form-section">
          <h2>📝 Agregar Nueva Temperatura</h2>
          <form onSubmit={handleSubmit} className="form">
            <div className="form-group">
              <label htmlFor="valor">Temperatura (°C):</label>
              <input
                type="number"
                id="valor"
                step="0.1"
                value={newTemperatura.valor}
                onChange={(e) => setNewTemperatura({...newTemperatura, valor: e.target.value})}
                required
                className="input"
              />
            </div>
            <div className="form-group">
              <label htmlFor="ubicacion">Ubicación:</label>
              <input
                type="text"
                id="ubicacion"
                value={newTemperatura.ubicacion}
                onChange={(e) => setNewTemperatura({...newTemperatura, ubicacion: e.target.value})}
                required
                className="input"
              />
            </div>
            <button type="submit" className="btn btn-primary">
              ➕ Agregar Temperatura
            </button>
          </form>
        </div>

        <div className="data-section">
          <h2>📊 Registros de Temperatura</h2>
          {error && <div className="error">{error}</div>}
          {loading ? (
            <div className="loading">Cargando temperaturas...</div>
          ) : (
            <div className="table-container">
              <table className="table">
                <thead>
                  <tr>
                    <th>ID</th>
                    <th>Temperatura</th>
                    <th>Ubicación</th>
                    <th>Fecha/Hora</th>
                    <th>Acciones</th>
                  </tr>
                </thead>
                <tbody>
                  {temperaturas.map((temp) => (
                    <tr key={temp.id}>
                      <td>{temp.id}</td>
                      <td className="temperature">{temp.valor}°C</td>
                      <td>{temp.ubicacion}</td>
                      <td className="date">{formatDate(temp.fechaCreacion)}</td>
                      <td>
                        <button 
                          onClick={() => handleDelete(temp.id)}
                          className="btn btn-danger btn-sm"
                        >
                          🗑️ Eliminar
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
              {temperaturas.length === 0 && (
                <div className="empty-state">
                  No hay temperaturas registradas
                </div>
              )}
            </div>
          )}
        </div>
      </main>

      <footer className="footer">
        <p>🚀 Powered by GitHub Actions CI/CD Pipeline</p>
      </footer>
    </div>
  )
}
