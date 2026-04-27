/// Use cases for Product.
import type { Either } from '../../../../core/usecase/usecase';
import type { Failure } from '../../../../core/errors/failures';
import type { ProductEntity } from '../entities/product.entity';
import type { ProductRepository } from '../repositories/product.repository';
import type { PaginationParams, PaginatedResponse } from '../../../../core/pagination/pagination';

export class GetAllProductsUseCase {
  private repository: ProductRepository;

  constructor(repository: ProductRepository) {
    this.repository = repository;
  }

  async execute(): Promise<Either<Failure, ProductEntity[]>> {
    return this.repository.getAll();
  }
}

export class GetProductByIdUseCase {
  private repository: ProductRepository;

  constructor(repository: ProductRepository) {
    this.repository = repository;
  }

  async execute(id: string): Promise<Either<Failure, ProductEntity>> {
    return this.repository.getById(id);
  }
}

export class AddProductUseCase {
  private repository: ProductRepository;

  constructor(repository: ProductRepository) {
    this.repository = repository;
  }

  async execute(entity: ProductEntity): Promise<Either<Failure, ProductEntity>> {
    return this.repository.add(entity);
  }
}

export class UpdateProductUseCase {
  private repository: ProductRepository;

  constructor(repository: ProductRepository) {
    this.repository = repository;
  }

  async execute(entity: ProductEntity): Promise<Either<Failure, ProductEntity>> {
    return this.repository.update(entity);
  }
}

export class DeleteProductUseCase {
  private repository: ProductRepository;

  constructor(repository: ProductRepository) {
    this.repository = repository;
  }

  async execute(id: string): Promise<Either<Failure, void>> {
    return this.repository.delete(id);
  }
}

export class SearchProductsUseCase {
  private repository: ProductRepository;

  constructor(repository: ProductRepository) {
    this.repository = repository;
  }

  async execute(query: string): Promise<Either<Failure, ProductEntity[]>> {
    return this.repository.search(query);
  }
}

export class GetAllProductsPaginatedUseCase {
  private repository: ProductRepository;

  constructor(repository: ProductRepository) {
    this.repository = repository;
  }

  async execute(params: PaginationParams): Promise<Either<Failure, PaginatedResponse<ProductEntity>>> {
    return this.repository.getAllPaginated(params);
  }
}
