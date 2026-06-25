/// In-memory fake repository for Customer.
import type { Either } from '../../../../core/usecase/usecase';
import { left, right } from '../../../../core/usecase/usecase';
import { NotFoundFailure, type Failure } from '../../../../core/errors/failures';
import type { CustomerEntity } from '../../domain/entities/customer.entity';
import type { CustomerRepository } from '../../domain/repositories/customer.repository';
import { toEntity, dummyCustomerList } from '../models/customer.model';
import type { PaginationParams, PaginatedResponse } from '../../../../core/pagination/pagination';

export class CustomerRepositoryFake implements CustomerRepository {
  private data: CustomerEntity[] = [];

  constructor(seedData: CustomerEntity[] = []) {
    this.data = seedData;
  }

  static seeded(count: number = 5): CustomerRepositoryFake {
    const models = dummyCustomerList(count);
    return new CustomerRepositoryFake(models.map(toEntity));
  }

  async getAll(): Promise<Either<Failure, CustomerEntity[]>> {
    return right([...this.data]);
  }

  async getById(id: string): Promise<Either<Failure, CustomerEntity>> {
    const entity = this.data.find((e) => e.id === id);
    if (!entity) {
      return left(new NotFoundFailure(`Customer with id ${id} not found`));
    }
    return right(entity);
  }

  async add(entity: CustomerEntity): Promise<Either<Failure, CustomerEntity>> {
    const newEntity = { ...entity, createdAt: new Date(), updatedAt: new Date() };
    this.data.push(newEntity);
    return right(newEntity);
  }

  async update(entity: CustomerEntity): Promise<Either<Failure, CustomerEntity>> {
    const index = this.data.findIndex((e) => e.id === entity.id);
    if (index === -1) {
      return left(new NotFoundFailure(`Customer with id ${entity.id} not found`));
    }
    const updated = { ...entity, updatedAt: new Date() };
    this.data[index] = updated;
    return right(updated);
  }

  async delete(id: string): Promise<Either<Failure, void>> {
    const index = this.data.findIndex((e) => e.id === id);
    if (index === -1) {
      return left(new NotFoundFailure(`Customer with id ${id} not found`));
    }
    this.data.splice(index, 1);
    return right(undefined);
  }

  async search(query: string): Promise<Either<Failure, CustomerEntity[]>> {
    const lowerQuery = query.toLowerCase();
    const results = this.data.filter(
      (e) =>
        e.name?.toLowerCase().includes(lowerQuery) ||
        e.description?.toLowerCase().includes(lowerQuery)
    );
    return right(results);
  }

  async getAllPaginated(params: PaginationParams): Promise<Either<Failure, PaginatedResponse<CustomerEntity>>> {
    const { offset, limit } = params;
    const items = this.data.slice(offset, offset + limit);
    return right({
      items,
      total: this.data.length,
      offset,
      limit,
    });
  }
}
