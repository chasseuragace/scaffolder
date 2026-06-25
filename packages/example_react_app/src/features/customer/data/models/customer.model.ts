/// Data model for Customer with JSON serialization.
import type { CustomerEntity } from '../../domain/entities/customer.entity';

export interface CustomerModel {
  id: string;
  name?: string;
  description?: string;
  created_at?: string;
  updated_at?: string;
}

export function toEntity(model: CustomerModel): CustomerEntity {
  return {
    id: model.id,
    name: model.name,
    description: model.description,
    createdAt: model.created_at ? new Date(model.created_at) : undefined,
    updatedAt: model.updated_at ? new Date(model.updated_at) : undefined,
  };
}

export function fromModel(entity: CustomerEntity): CustomerModel {
  return {
    id: entity.id,
    name: entity.name,
    description: entity.description,
    created_at: entity.createdAt?.toISOString(),
    updated_at: entity.updatedAt?.toISOString(),
  };
}

export function dummyCustomer(id: string = '1'): CustomerModel {
  return {
    id,
    name: `Customer ${id}`,
    description: `Description for Customer ${id}`,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
  };
}

export function dummyCustomerList(count: number = 5): CustomerModel[] {
  return Array.from({ length: count }, (_, i) => dummyCustomer(String(i + 1)));
}
