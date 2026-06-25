/// Domain entity for LoyaltyCard.
/// Plain immutable value object — zero framework dependencies.
/// Spread-clone to update: `{ ...entity, name: 'new value' }`
export interface LoyaltyCardEntity {
  readonly id: string;
  readonly name?: string;
  readonly description?: string;
  readonly createdAt?: Date;
  readonly updatedAt?: Date;
}
