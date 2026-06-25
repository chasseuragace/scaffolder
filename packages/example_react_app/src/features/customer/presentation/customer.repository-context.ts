/// Repository context for Customer dependency injection.
/// Allows switching between fake and real implementations.
import { createRepositoryContext } from '../../../core/context/repository-context';
import type { CustomerRepository } from '../domain/repositories/customer.repository';
import { CustomerRepositoryFake } from '../data/repositories/customer.repository-fake';

export const {
  Provider: CustomerRepositoryProvider,
  useRepository: useCustomerRepositoryContext,
} = createRepositoryContext<CustomerRepository>();

/// Default repository implementation for development.
/// Override this in production or tests by providing a different implementation
/// to the CustomerRepositoryProvider.
export function createDefaultCustomerRepository(): CustomerRepository {
  return CustomerRepositoryFake.seeded();
}
