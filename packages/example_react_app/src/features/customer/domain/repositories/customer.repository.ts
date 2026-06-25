/// Repository contract for Customer.
import type { Either } from '../../../../core/usecase/usecase';
import type { Failure } from '../../../../core/errors/failures';
import type { CustomerEntity } from '../entities/customer.entity';
import type { PaginationParams, PaginatedResponse } from '../../../../core/pagination/pagination';

export interface CustomerRepository {
  getAll(): Promise<Either<Failure, CustomerEntity[]>>;
  getById(id: string): Promise<Either<Failure, CustomerEntity>>;
  add(entity: CustomerEntity): Promise<Either<Failure, CustomerEntity>>;
  update(entity: CustomerEntity): Promise<Either<Failure, CustomerEntity>>;
  delete(id: string): Promise<Either<Failure, void>>;
  search(query: string): Promise<Either<Failure, CustomerEntity[]>>;
  getAllPaginated(params: PaginationParams): Promise<Either<Failure, PaginatedResponse<CustomerEntity>>>;
}
