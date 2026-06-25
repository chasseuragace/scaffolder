/// Domain entity for Customer.
/// Plain immutable value object — zero framework dependencies.
/// Spread-clone to update: `{ ...entity, name: 'new value' }`
export interface CustomerEntity {
  readonly id: string;
  readonly name?: string;
  readonly description?: string;
  readonly createdAt?: Date;
  readonly updatedAt?: Date;
}
