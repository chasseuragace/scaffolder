/// Data model for Order with JSON serialization.
import type { OrderEntity } from '../../domain/entities/order.entity';

export interface OrderModel {
  id: string;
  name?: string;
  description?: string;
  created_at?: string;
  updated_at?: string;
}

export function toEntity(model: OrderModel): OrderEntity {
  return {
    id: model.id,
    name: model.name,
    description: model.description,
    createdAt: model.created_at ? new Date(model.created_at) : undefined,
    updatedAt: model.updated_at ? new Date(model.updated_at) : undefined,
  };
}

export function fromModel(entity: OrderEntity): OrderModel {
  return {
    id: entity.id,
    name: entity.name,
    description: entity.description,
    created_at: entity.createdAt?.toISOString(),
    updated_at: entity.updatedAt?.toISOString(),
  };
}

export function dummyOrder(id: string = '1'): OrderModel {
  return {
    id,
    name: `Order ${id}`,
    description: `Description for Order ${id}`,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
  };
}

export function dummyOrderList(count: number = 5): OrderModel[] {
  return Array.from({ length: count }, (_, i) => dummyOrder(String(i + 1)));
}
