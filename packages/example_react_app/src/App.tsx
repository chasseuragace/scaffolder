import { Routes, Route, Link, useLocation } from 'react-router-dom'
import { FeatureRegistry, routes } from './core/routing/feature-registry'
import './App.css'

function App() {
  const location = useLocation()

  return (
    <div className="min-h-screen bg-gray-50">
      <nav className="border-b bg-white px-6 py-4">
        <div className="mx-auto flex max-w-6xl items-center justify-between">
          <h1 className="text-xl font-bold">React Feature Generator</h1>
          <div className="space-x-4">
            <Link to="/" className="text-blue-600 hover:underline">
              Home
            </Link>
            {FeatureRegistry.all.map((feature) => (
              <Link
                key={feature.id}
                to={feature.path}
                className={`hover:underline ${
                  location.pathname === feature.path ? 'font-bold text-blue-600' : 'text-gray-600'
                }`}
              >
                {feature.title}
              </Link>
            ))}
          </div>
        </div>
      </nav>

      <main className="mx-auto max-w-6xl p-6">
        <Routes>
          <Route
            path="/"
            element={
              <div className="text-center">
                <h2 className="mb-4 text-2xl font-bold">Welcome</h2>
                <p className="mb-8 text-gray-600">
                  Select a feature from the navigation above to get started.
                </p>
                {FeatureRegistry.all.length === 0 ? (
                  <p className="text-gray-500">No features generated yet.</p>
                ) : (
                  <div className="grid gap-4 md:grid-cols-3">
                    {FeatureRegistry.all.map((feature) => (
                      <Link
                        key={feature.id}
                        to={feature.path}
                        className="rounded border p-4 hover:bg-gray-50"
                      >
                        <h3 className="font-semibold">{feature.title}</h3>
                      </Link>
                    ))}
                  </div>
                )}
              </div>
            }
          />
          {routes.map((route) => (
            <Route key={route.path} path={route.path} element={route.element} />
          ))}
        </Routes>
      </main>
    </div>
  )
}

export default App
