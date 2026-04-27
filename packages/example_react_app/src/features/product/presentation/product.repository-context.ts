/// Repository context for Product dependency injection.
/// Allows switching between fake and real implementations.
import { createRepositoryContext } from '../../../core/context/repository-context';
import type { ProductRepository } from '../domain/repositories/product.repository';
import { ProductRepositoryFake } from '../data/repositories/product.repository-fake';

export const {
  Provider: ProductRepositoryProvider,
  useRepository: useProductRepositoryContext,
} = createRepositoryContext<ProductRepository>();

/// Default repository implementation for development.
/// Override this in production or tests by providing a different implementation
/// to the ProductRepositoryProvider.
export function createDefaultProductRepository(): ProductRepository {
  return ProductRepositoryFake.seeded();
}
