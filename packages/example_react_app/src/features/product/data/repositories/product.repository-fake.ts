/// In-memory fake repository for Product.
import type { Either } from '../../../../core/usecase/usecase';
import { left, right } from '../../../../core/usecase/usecase';
import { NotFoundFailure, type Failure } from '../../../../core/errors/failures';
import type { ProductEntity } from '../../domain/entities/product.entity';
import type { ProductRepository } from '../../domain/repositories/product.repository';
import { toEntity, dummyProductList } from '../models/product.model';
import type { PaginationParams, PaginatedResponse } from '../../../../core/pagination/pagination';

export class ProductRepositoryFake implements ProductRepository {
  private data: ProductEntity[] = [];

  constructor(seedData: ProductEntity[] = []) {
    this.data = seedData;
  }

  static seeded(count: number = 5): ProductRepositoryFake {
    const models = dummyProductList(count);
    return new ProductRepositoryFake(models.map(toEntity));
  }

  async getAll(): Promise<Either<Failure, ProductEntity[]>> {
    return right([...this.data]);
  }

  async getById(id: string): Promise<Either<Failure, ProductEntity>> {
    const entity = this.data.find((e) => e.id === id);
    if (!entity) {
      return left(new NotFoundFailure(`Product with id ${id} not found`));
    }
    return right(entity);
  }

  async add(entity: ProductEntity): Promise<Either<Failure, ProductEntity>> {
    const newEntity = { ...entity, createdAt: new Date(), updatedAt: new Date() };
    this.data.push(newEntity);
    return right(newEntity);
  }

  async update(entity: ProductEntity): Promise<Either<Failure, ProductEntity>> {
    const index = this.data.findIndex((e) => e.id === entity.id);
    if (index === -1) {
      return left(new NotFoundFailure(`Product with id ${entity.id} not found`));
    }
    const updated = { ...entity, updatedAt: new Date() };
    this.data[index] = updated;
    return right(updated);
  }

  async delete(id: string): Promise<Either<Failure, void>> {
    const index = this.data.findIndex((e) => e.id === id);
    if (index === -1) {
      return left(new NotFoundFailure(`Product with id ${id} not found`));
    }
    this.data.splice(index, 1);
    return right(undefined);
  }

  async search(query: string): Promise<Either<Failure, ProductEntity[]>> {
    const lowerQuery = query.toLowerCase();
    const results = this.data.filter(
      (e) =>
        e.name?.toLowerCase().includes(lowerQuery) ||
        e.description?.toLowerCase().includes(lowerQuery)
    );
    return right(results);
  }

  async getAllPaginated(params: PaginationParams): Promise<Either<Failure, PaginatedResponse<ProductEntity>>> {
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
