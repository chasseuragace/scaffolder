/// In-memory fake repository for LoyaltyCard.
import type { Either } from '../../../../core/usecase/usecase';
import { left, right } from '../../../../core/usecase/usecase';
import { NotFoundFailure, type Failure } from '../../../../core/errors/failures';
import type { LoyaltyCardEntity } from '../../domain/entities/loyalty-card.entity';
import type { LoyaltyCardRepository } from '../../domain/repositories/loyalty-card.repository';
import { toEntity, dummyLoyaltyCardList } from '../models/loyalty-card.model';

export class LoyaltyCardRepositoryFake implements LoyaltyCardRepository {
  private data: LoyaltyCardEntity[] = [];

  constructor(seedData: LoyaltyCardEntity[] = []) {
    this.data = seedData;
  }

  static seeded(count: number = 5): LoyaltyCardRepositoryFake {
    const models = dummyLoyaltyCardList(count);
    return new LoyaltyCardRepositoryFake(models.map(toEntity));
  }

  async getAll(): Promise<Either<Failure, LoyaltyCardEntity[]>> {
    return right([...this.data]);
  }

  async getById(id: string): Promise<Either<Failure, LoyaltyCardEntity>> {
    const entity = this.data.find((e) => e.id === id);
    if (!entity) {
      return left(new NotFoundFailure(`LoyaltyCard with id ${id} not found`));
    }
    return right(entity);
  }

  async add(entity: LoyaltyCardEntity): Promise<Either<Failure, LoyaltyCardEntity>> {
    const newEntity = { ...entity, createdAt: new Date(), updatedAt: new Date() };
    this.data.push(newEntity);
    return right(newEntity);
  }

  async update(entity: LoyaltyCardEntity): Promise<Either<Failure, LoyaltyCardEntity>> {
    const index = this.data.findIndex((e) => e.id === entity.id);
    if (index === -1) {
      return left(new NotFoundFailure(`LoyaltyCard with id ${entity.id} not found`));
    }
    const updated = { ...entity, updatedAt: new Date() };
    this.data[index] = updated;
    return right(updated);
  }

  async delete(id: string): Promise<Either<Failure, void>> {
    const index = this.data.findIndex((e) => e.id === id);
    if (index === -1) {
      return left(new NotFoundFailure(`LoyaltyCard with id ${id} not found`));
    }
    this.data.splice(index, 1);
    return right(undefined);
  }

}
