/// Real repository implementation for Customer.
/// Currently throws UnimplementedError — replace with actual API calls.
import type { Either } from '../../../../core/usecase/usecase';
import type { Failure } from '../../../../core/errors/failures';
import type { CustomerEntity } from '../../domain/entities/customer.entity';
import type { CustomerRepository } from '../../domain/repositories/customer.repository';
import type { PaginationParams, PaginatedResponse } from '../../../../core/pagination/pagination';

export class CustomerRepositoryImpl implements CustomerRepository {
  async getAll(): Promise<Either<Failure, CustomerEntity[]>> {
    throw new Error('UnimplementedError: Real repository not yet implemented');
  }

  async getById(_id: string): Promise<Either<Failure, CustomerEntity>> {
    throw new Error('UnimplementedError: Real repository not yet implemented');
  }

  async add(_entity: CustomerEntity): Promise<Either<Failure, CustomerEntity>> {
    throw new Error('UnimplementedError: Real repository not yet implemented');
  }

  async update(_entity: CustomerEntity): Promise<Either<Failure, CustomerEntity>> {
    throw new Error('UnimplementedError: Real repository not yet implemented');
  }

  async delete(_id: string): Promise<Either<Failure, void>> {
    throw new Error('UnimplementedError: Real repository not yet implemented');
  }

  async search(_query: string): Promise<Either<Failure, CustomerEntity[]>> {
    throw new Error('UnimplementedError: Real repository not yet implemented');
  }

  async getAllPaginated(_params: PaginationParams): Promise<Either<Failure, PaginatedResponse<CustomerEntity>>> {
    throw new Error('UnimplementedError: Real repository not yet implemented');
  }
}
