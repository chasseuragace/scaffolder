import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { BrowserRouter } from 'react-router-dom'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import App from './App.tsx'
import { ProductRepositoryProvider, createDefaultProductRepository } from './features/product/product.module'

const queryClient = new QueryClient()

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <QueryClientProvider client={queryClient}>
      <ProductRepositoryProvider repository={createDefaultProductRepository()}>
        <BrowserRouter>
          <App />
        </BrowserRouter>
      </ProductRepositoryProvider>
    </QueryClientProvider>
  </StrictMode>,
)
