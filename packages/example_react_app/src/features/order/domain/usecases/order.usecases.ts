/// Use cases for Order.
import type { Either } from '../../../../core/usecase/usecase';
import type { Failure } from '../../../../core/errors/failures';
import type { OrderEntity } from '../entities/order.entity';
import type { OrderRepository } from '../repositories/order.repository';
import type { PaginationParams, PaginatedResponse } from '../../../../core/pagination/pagination';

export class GetAllOrdersUseCase {
  private repository: OrderRepository;

  constructor(repository: OrderRepository) {
    this.repository = repository;
  }

  async execute(): Promise<Either<Failure, OrderEntity[]>> {
    return this.repository.getAll();
  }
}

export class GetOrderByIdUseCase {
  private repository: OrderRepository;

  constructor(repository: OrderRepository) {
    this.repository = repository;
  }

  async execute(id: string): Promise<Either<Failure, OrderEntity>> {
    return this.repository.getById(id);
  }
}

export class AddOrderUseCase {
  private repository: OrderRepository;

  constructor(repository: OrderRepository) {
    this.repository = repository;
  }

  async execute(entity: OrderEntity): Promise<Either<Failure, OrderEntity>> {
    return this.repository.add(entity);
  }
}

export class UpdateOrderUseCase {
  private repository: OrderRepository;

  constructor(repository: OrderRepository) {
    this.repository = repository;
  }

  async execute(entity: OrderEntity): Promise<Either<Failure, OrderEntity>> {
    return this.repository.update(entity);
  }
}

export class DeleteOrderUseCase {
  private repository: OrderRepository;

  constructor(repository: OrderRepository) {
    this.repository = repository;
  }

  async execute(id: string): Promise<Either<Failure, void>> {
    return this.repository.delete(id);
  }
}

export class SearchOrdersUseCase {
  private repository: OrderRepository;

  constructor(repository: OrderRepository) {
    this.repository = repository;
  }

  async execute(query: string): Promise<Either<Failure, OrderEntity[]>> {
    return this.repository.search(query);
  }
}

export class GetAllOrdersPaginatedUseCase {
  private repository: OrderRepository;

  constructor(repository: OrderRepository) {
    this.repository = repository;
  }

  async execute(params: PaginationParams): Promise<Either<Failure, PaginatedResponse<OrderEntity>>> {
    return this.repository.getAllPaginated(params);
  }
}
