/// Repository context for LoyaltyCard dependency injection.
/// Allows switching between fake and real implementations.
import { createRepositoryContext } from '../../../core/context/repository-context';
import type { LoyaltyCardRepository } from '../domain/repositories/loyalty-card.repository';
import { LoyaltyCardRepositoryFake } from '../data/repositories/loyalty-card.repository-fake';

export const {
  Provider: LoyaltyCardRepositoryProvider,
  useRepository: useLoyaltyCardRepositoryContext,
} = createRepositoryContext<LoyaltyCardRepository>();

/// Default repository implementation for development.
/// Override this in production or tests by providing a different implementation
/// to the LoyaltyCardRepositoryProvider.
export function createDefaultLoyaltyCardRepository(): LoyaltyCardRepository {
  return LoyaltyCardRepositoryFake.seeded();
}
