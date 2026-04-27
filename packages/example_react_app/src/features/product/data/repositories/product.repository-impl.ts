/// Real repository implementation for Product.
/// Currently throws UnimplementedError — replace with actual API calls.
import type { Either } from '../../../../core/usecase/usecase';
import type { Failure } from '../../../../core/errors/failures';
import type { ProductEntity } from '../../domain/entities/product.entity';
import type { ProductRepository } from '../../domain/repositories/product.repository';
import type { PaginationParams, PaginatedResponse } from '../../../../core/pagination/pagination';

export class ProductRepositoryImpl implements ProductRepository {
  async getAll(): Promise<Either<Failure, ProductEntity[]>> {
    throw new Error('UnimplementedError: Real repository not yet implemented');
  }

  async getById(_id: string): Promise<Either<Failure, ProductEntity>> {
    throw new Error('UnimplementedError: Real repository not yet implemented');
  }

  async add(_entity: ProductEntity): Promise<Either<Failure, ProductEntity>> {
    throw new Error('UnimplementedError: Real repository not yet implemented');
  }

  async update(_entity: ProductEntity): Promise<Either<Failure, ProductEntity>> {
    throw new Error('UnimplementedError: Real repository not yet implemented');
  }

  async delete(_id: string): Promise<Either<Failure, void>> {
    throw new Error('UnimplementedError: Real repository not yet implemented');
  }

  async search(_query: string): Promise<Either<Failure, ProductEntity[]>> {
    throw new Error('UnimplementedError: Real repository not yet implemented');
  }

  async getAllPaginated(_params: PaginationParams): Promise<Either<Failure, PaginatedResponse<ProductEntity>>> {
    throw new Error('UnimplementedError: Real repository not yet implemented');
  }
}
