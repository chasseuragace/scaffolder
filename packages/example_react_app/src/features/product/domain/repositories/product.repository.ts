/// Repository contract for Product.
import type { Either } from '../../../../core/usecase/usecase';
import type { Failure } from '../../../../core/errors/failures';
import type { ProductEntity } from '../entities/product.entity';
import type { PaginationParams, PaginatedResponse } from '../../../../core/pagination/pagination';

export interface ProductRepository {
  getAll(): Promise<Either<Failure, ProductEntity[]>>;
  getById(id: string): Promise<Either<Failure, ProductEntity>>;
  add(entity: ProductEntity): Promise<Either<Failure, ProductEntity>>;
  update(entity: ProductEntity): Promise<Either<Failure, ProductEntity>>;
  delete(id: string): Promise<Either<Failure, void>>;
  search(query: string): Promise<Either<Failure, ProductEntity[]>>;
  getAllPaginated(params: PaginationParams): Promise<Either<Failure, PaginatedResponse<ProductEntity>>>;
}
