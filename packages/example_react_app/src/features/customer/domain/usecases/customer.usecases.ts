/// Use cases for Customer.
import type { Either } from '../../../../core/usecase/usecase';
import type { Failure } from '../../../../core/errors/failures';
import type { CustomerEntity } from '../entities/customer.entity';
import type { CustomerRepository } from '../repositories/customer.repository';
import type { PaginationParams, PaginatedResponse } from '../../../../core/pagination/pagination';

export class GetAllCustomersUseCase {
  private repository: CustomerRepository;

  constructor(repository: CustomerRepository) {
    this.repository = repository;
  }

  async execute(): Promise<Either<Failure, CustomerEntity[]>> {
    return this.repository.getAll();
  }
}

export class GetCustomerByIdUseCase {
  private repository: CustomerRepository;

  constructor(repository: CustomerRepository) {
    this.repository = repository;
  }

  async execute(id: string): Promise<Either<Failure, CustomerEntity>> {
    return this.repository.getById(id);
  }
}

export class AddCustomerUseCase {
  private repository: CustomerRepository;

  constructor(repository: CustomerRepository) {
    this.repository = repository;
  }

  async execute(entity: CustomerEntity): Promise<Either<Failure, CustomerEntity>> {
    return this.repository.add(entity);
  }
}

export class UpdateCustomerUseCase {
  private repository: CustomerRepository;

  constructor(repository: CustomerRepository) {
    this.repository = repository;
  }

  async execute(entity: CustomerEntity): Promise<Either<Failure, CustomerEntity>> {
    return this.repository.update(entity);
  }
}

export class DeleteCustomerUseCase {
  private repository: CustomerRepository;

  constructor(repository: CustomerRepository) {
    this.repository = repository;
  }

  async execute(id: string): Promise<Either<Failure, void>> {
    return this.repository.delete(id);
  }
}

export class SearchCustomersUseCase {
  private repository: CustomerRepository;

  constructor(repository: CustomerRepository) {
    this.repository = repository;
  }

  async execute(query: string): Promise<Either<Failure, CustomerEntity[]>> {
    return this.repository.search(query);
  }
}

export class GetAllCustomersPaginatedUseCase {
  private repository: CustomerRepository;

  constructor(repository: CustomerRepository) {
    this.repository = repository;
  }

  async execute(params: PaginationParams): Promise<Either<Failure, PaginatedResponse<CustomerEntity>>> {
    return this.repository.getAllPaginated(params);
  }
}
