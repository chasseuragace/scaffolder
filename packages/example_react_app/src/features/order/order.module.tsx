/// Public surface for the Order feature.
///
/// Fix vs v1:
///   - Only exports the public API (entity type, hooks, provider, routes).
///   - Internal layers (model, repository-impl, usecases) are NOT re-exported
///     so they don't leak into consumers or break tree-shaking.
///   - Adds OrderModuleProvider so callers wire one component, not N providers.
import React from 'react';
import { OrderRepositoryProvider, createDefaultOrderRepository } from './presentation/order.repository-context';
import { OrderListPage } from './presentation/pages/order-list-page';
import { OrderDetailsPage } from './presentation/pages/order-details-page';

// --- Public types -----------------------------------------------------------
export type { OrderEntity } from './domain/entities/order.entity';
export type { OrderRepository } from './domain/repositories/order.repository';

// --- Public hooks -----------------------------------------------------------
export {
  useOrderList,
  useOrderById,
  useOrderMutations,
  useOrderSearch,
  useOrderListInfinite,
} from './presentation/hooks/order.hooks';

// --- DI surface -------------------------------------------------------------
export { OrderRepositoryProvider, createDefaultOrderRepository } from './presentation/order.repository-context';

// --- Module provider --------------------------------------------------------
/// Drop-in provider that wires the default repository.
/// Mount once in your app shell — no manual provider nesting required.
///
/// Usage:
///   import { OrderModuleProvider } from './features/order/order.module';
///   <OrderModuleProvider><App /></OrderModuleProvider>
export function OrderModuleProvider({ children }: { children: React.ReactNode }) {
  return (
    <OrderRepositoryProvider repository={createDefaultOrderRepository()}>
      {children}
    </OrderRepositoryProvider>
  );
}

// --- Routing ----------------------------------------------------------------
export const OrderDescriptor = {
  id: 'order',
  title: 'Orders',
  path: '/order',
} as const;

export const OrderRoutes = [
  { path: '/order', element: <OrderListPage /> },
  { path: '/order/:id', element: <OrderDetailsPage /> },
];
