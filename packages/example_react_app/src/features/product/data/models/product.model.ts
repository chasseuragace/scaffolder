/// Data model for Product with JSON serialization.
import type { ProductEntity } from '../../domain/entities/product.entity';

export interface ProductModel {
  id: string;
  name?: string;
  description?: string;
  created_at?: string;
  updated_at?: string;
}

export function toEntity(model: ProductModel): ProductEntity {
  return {
    id: model.id,
    name: model.name,
    description: model.description,
    createdAt: model.created_at ? new Date(model.created_at) : undefined,
    updatedAt: model.updated_at ? new Date(model.updated_at) : undefined,
  };
}

export function fromModel(entity: ProductEntity): ProductModel {
  return {
    id: entity.id,
    name: entity.name,
    description: entity.description,
    created_at: entity.createdAt?.toISOString(),
    updated_at: entity.updatedAt?.toISOString(),
  };
}

export function dummyProduct(id: string = '1'): ProductModel {
  return {
    id,
    name: `Product ${id}`,
    description: `Description for Product ${id}`,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
  };
}

export function dummyProductList(count: number = 5): ProductModel[] {
  return Array.from({ length: count }, (_, i) => dummyProduct(String(i + 1)));
}
