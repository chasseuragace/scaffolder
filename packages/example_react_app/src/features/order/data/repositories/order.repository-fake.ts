/// In-memory fake repository for Order.
import type { Either } from '../../../../core/usecase/usecase';
import { left, right } from '../../../../core/usecase/usecase';
import { NotFoundFailure, type Failure } from '../../../../core/errors/failures';
import type { OrderEntity } from '../../domain/entities/order.entity';
import type { OrderRepository } from '../../domain/repositories/order.repository';
import { toEntity, dummyOrderList } from '../models/order.model';
import type { PaginationParams, PaginatedResponse } from '../../../../core/pagination/pagination';

export class OrderRepositoryFake implements OrderRepository {
  private data: OrderEntity[] = [];

  constructor(seedData: OrderEntity[] = []) {
    this.data = seedData;
  }

  static seeded(count: number = 5): OrderRepositoryFake {
    const models = dummyOrderList(count);
    return new OrderRepositoryFake(models.map(toEntity));
  }

  async getAll(): Promise<Either<Failure, OrderEntity[]>> {
    return right([...this.data]);
  }

  async getById(id: string): Promise<Either<Failure, OrderEntity>> {
    const entity = this.data.find((e) => e.id === id);
    if (!entity) {
      return left(new NotFoundFailure(`Order with id ${id} not found`));
    }
    return right(entity);
  }

  async add(entity: OrderEntity): Promise<Either<Failure, OrderEntity>> {
    const newEntity = { ...entity, createdAt: new Date(), updatedAt: new Date() };
    this.data.push(newEntity);
    return right(newEntity);
  }

  async update(entity: OrderEntity): Promise<Either<Failure, OrderEntity>> {
    const index = this.data.findIndex((e) => e.id === entity.id);
    if (index === -1) {
      return left(new NotFoundFailure(`Order with id ${entity.id} not found`));
    }
    const updated = { ...entity, updatedAt: new Date() };
    this.data[index] = updated;
    return right(updated);
  }

  async delete(id: string): Promise<Either<Failure, void>> {
    const index = this.data.findIndex((e) => e.id === id);
    if (index === -1) {
      return left(new NotFoundFailure(`Order with id ${id} not found`));
    }
    this.data.splice(index, 1);
    return right(undefined);
  }

  async search(query: string): Promise<Either<Failure, OrderEntity[]>> {
    const lowerQuery = query.toLowerCase();
    const results = this.data.filter(
      (e) =>
        e.name?.toLowerCase().includes(lowerQuery) ||
        e.description?.toLowerCase().includes(lowerQuery)
    );
    return right(results);
  }

  async getAllPaginated(params: PaginationParams): Promise<Either<Failure, PaginatedResponse<OrderEntity>>> {
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
