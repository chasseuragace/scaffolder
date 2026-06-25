/// Data model for LoyaltyCard with JSON serialization.
import type { LoyaltyCardEntity } from '../../domain/entities/loyalty-card.entity';

export interface LoyaltyCardModel {
  id: string;
  name?: string;
  description?: string;
  created_at?: string;
  updated_at?: string;
}

export function toEntity(model: LoyaltyCardModel): LoyaltyCardEntity {
  return {
    id: model.id,
    name: model.name,
    description: model.description,
    createdAt: model.created_at ? new Date(model.created_at) : undefined,
    updatedAt: model.updated_at ? new Date(model.updated_at) : undefined,
  };
}

export function fromModel(entity: LoyaltyCardEntity): LoyaltyCardModel {
  return {
    id: entity.id,
    name: entity.name,
    description: entity.description,
    created_at: entity.createdAt?.toISOString(),
    updated_at: entity.updatedAt?.toISOString(),
  };
}

export function dummyLoyaltyCard(id: string = '1'): LoyaltyCardModel {
  return {
    id,
    name: `LoyaltyCard ${id}`,
    description: `Description for LoyaltyCard ${id}`,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
  };
}

export function dummyLoyaltyCardList(count: number = 5): LoyaltyCardModel[] {
  return Array.from({ length: count }, (_, i) => dummyLoyaltyCard(String(i + 1)));
}
