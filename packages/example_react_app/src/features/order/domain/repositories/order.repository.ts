/// Repository contract for Order.
import type { Either } from '../../../../core/usecase/usecase';
import type { Failure } from '../../../../core/errors/failures';
import type { OrderEntity } from '../entities/order.entity';
import type { PaginationParams, PaginatedResponse } from '../../../../core/pagination/pagination';

export interface OrderRepository {
  getAll(): Promise<Either<Failure, OrderEntity[]>>;
  getById(id: string): Promise<Either<Failure, OrderEntity>>;
  add(entity: OrderEntity): Promise<Either<Failure, OrderEntity>>;
  update(entity: OrderEntity): Promise<Either<Failure, OrderEntity>>;
  delete(id: string): Promise<Either<Failure, void>>;
  search(query: string): Promise<Either<Failure, OrderEntity[]>>;
  getAllPaginated(params: PaginationParams): Promise<Either<Failure, PaginatedResponse<OrderEntity>>>;
}
