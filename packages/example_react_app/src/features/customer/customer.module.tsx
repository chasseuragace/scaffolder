/// Public surface for the Customer feature.
///
/// Fix vs v1:
///   - Only exports the public API (entity type, hooks, provider, routes).
///   - Internal layers (model, repository-impl, usecases) are NOT re-exported
///     so they don't leak into consumers or break tree-shaking.
///   - Adds CustomerModuleProvider so callers wire one component, not N providers.
import React from 'react';
import { CustomerRepositoryProvider, createDefaultCustomerRepository } from './presentation/customer.repository-context';
import { CustomerListPage } from './presentation/pages/customer-list-page';
import { CustomerDetailsPage } from './presentation/pages/customer-details-page';

// --- Public types -----------------------------------------------------------
export type { CustomerEntity } from './domain/entities/customer.entity';
export type { CustomerRepository } from './domain/repositories/customer.repository';

// --- Public hooks -----------------------------------------------------------
export {
  useCustomerList,
  useCustomerById,
  useCustomerMutations,
  useCustomerSearch,
  useCustomerListInfinite,
} from './presentation/hooks/customer.hooks';

// --- DI surface -------------------------------------------------------------
export { CustomerRepositoryProvider, createDefaultCustomerRepository } from './presentation/customer.repository-context';

// --- Module provider --------------------------------------------------------
/// Drop-in provider that wires the default repository.
/// Mount once in your app shell — no manual provider nesting required.
///
/// Usage:
///   import { CustomerModuleProvider } from './features/customer/customer.module';
///   <CustomerModuleProvider><App /></CustomerModuleProvider>
export function CustomerModuleProvider({ children }: { children: React.ReactNode }) {
  return (
    <CustomerRepositoryProvider repository={createDefaultCustomerRepository()}>
      {children}
    </CustomerRepositoryProvider>
  );
}

// --- Routing ----------------------------------------------------------------
export const CustomerDescriptor = {
  id: 'customer',
  title: 'Customers',
  path: '/customer',
} as const;

export const CustomerRoutes = [
  { path: '/customer', element: <CustomerListPage /> },
  { path: '/customer/:id', element: <CustomerDetailsPage /> },
];
