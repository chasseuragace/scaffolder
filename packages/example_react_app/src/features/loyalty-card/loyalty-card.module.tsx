/// Public surface for the LoyaltyCard feature.
///
/// Fix vs v1:
///   - Only exports the public API (entity type, hooks, provider, routes).
///   - Internal layers (model, repository-impl, usecases) are NOT re-exported
///     so they don't leak into consumers or break tree-shaking.
///   - Adds LoyaltyCardModuleProvider so callers wire one component, not N providers.
import React from 'react';
import { LoyaltyCardRepositoryProvider, createDefaultLoyaltyCardRepository } from './presentation/loyalty-card.repository-context';
import { LoyaltyCardListPage } from './presentation/pages/loyalty-card-list-page';
import { LoyaltyCardDetailsPage } from './presentation/pages/loyalty-card-details-page';

// --- Public types -----------------------------------------------------------
export type { LoyaltyCardEntity } from './domain/entities/loyalty-card.entity';
export type { LoyaltyCardRepository } from './domain/repositories/loyalty-card.repository';

// --- Public hooks -----------------------------------------------------------
export {
  useLoyaltyCardList,
  useLoyaltyCardById,
  useLoyaltyCardMutations,
} from './presentation/hooks/loyalty-card.hooks';

// --- DI surface -------------------------------------------------------------
export { LoyaltyCardRepositoryProvider, createDefaultLoyaltyCardRepository } from './presentation/loyalty-card.repository-context';

// --- Module provider --------------------------------------------------------
/// Drop-in provider that wires the default repository.
/// Mount once in your app shell — no manual provider nesting required.
///
/// Usage:
///   import { LoyaltyCardModuleProvider } from './features/loyalty-card/loyalty-card.module';
///   <LoyaltyCardModuleProvider><App /></LoyaltyCardModuleProvider>
export function LoyaltyCardModuleProvider({ children }: { children: React.ReactNode }) {
  return (
    <LoyaltyCardRepositoryProvider repository={createDefaultLoyaltyCardRepository()}>
      {children}
    </LoyaltyCardRepositoryProvider>
  );
}

// --- Routing ----------------------------------------------------------------
export const LoyaltyCardDescriptor = {
  id: 'loyalty-card',
  title: 'LoyaltyCards',
  path: '/loyalty-card',
} as const;

export const LoyaltyCardRoutes = [
  { path: '/loyalty-card', element: <LoyaltyCardListPage /> },
  { path: '/loyalty-card/:id', element: <LoyaltyCardDetailsPage /> },
];
