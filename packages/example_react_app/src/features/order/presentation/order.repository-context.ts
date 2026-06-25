/// Repository context for Order dependency injection.
/// Allows switching between fake and real implementations.
import { createRepositoryContext } from '../../../core/context/repository-context';
import type { OrderRepository } from '../domain/repositories/order.repository';
import { OrderRepositoryFake } from '../data/repositories/order.repository-fake';

export const {
  Provider: OrderRepositoryProvider,
  useRepository: useOrderRepositoryContext,
} = createRepositoryContext<OrderRepository>();

/// Default repository implementation for development.
/// Override this in production or tests by providing a different implementation
/// to the OrderRepositoryProvider.
export function createDefaultOrderRepository(): OrderRepository {
  return OrderRepositoryFake.seeded();
}
