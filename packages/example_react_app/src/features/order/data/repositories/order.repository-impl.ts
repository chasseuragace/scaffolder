/// Real repository implementation for Order.
/// Currently throws UnimplementedError — replace with actual API calls.
import type { Either } from '../../../../core/usecase/usecase';
import type { Failure } from '../../../../core/errors/failures';
import type { OrderEntity } from '../../domain/entities/order.entity';
import type { OrderRepository } from '../../domain/repositories/order.repository';
import type { PaginationParams, PaginatedResponse } from '../../../../core/pagination/pagination';

export class OrderRepositoryImpl implements OrderRepository {
  async getAll(): Promise<Either<Failure, OrderEntity[]>> {
    throw new Error('UnimplementedError: Real repository not yet implemented');
  }

  async getById(_id: string): Promise<Either<Failure, OrderEntity>> {
    throw new Error('UnimplementedError: Real repository not yet implemented');
  }

  async add(_entity: OrderEntity): Promise<Either<Failure, OrderEntity>> {
    throw new Error('UnimplementedError: Real repository not yet implemented');
  }

  async update(_entity: OrderEntity): Promise<Either<Failure, OrderEntity>> {
    throw new Error('UnimplementedError: Real repository not yet implemented');
  }

  async delete(_id: string): Promise<Either<Failure, void>> {
    throw new Error('UnimplementedError: Real repository not yet implemented');
  }

  async search(_query: string): Promise<Either<Failure, OrderEntity[]>> {
    throw new Error('UnimplementedError: Real repository not yet implemented');
  }

  async getAllPaginated(_params: PaginationParams): Promise<Either<Failure, PaginatedResponse<OrderEntity>>> {
    throw new Error('UnimplementedError: Real repository not yet implemented');
  }
}
