/// Use cases for LoyaltyCard.
import type { Either } from '../../../../core/usecase/usecase';
import type { Failure } from '../../../../core/errors/failures';
import type { LoyaltyCardEntity } from '../entities/loyalty-card.entity';
import type { LoyaltyCardRepository } from '../repositories/loyalty-card.repository';

export class GetAllLoyaltyCardsUseCase {
  private repository: LoyaltyCardRepository;

  constructor(repository: LoyaltyCardRepository) {
    this.repository = repository;
  }

  async execute(): Promise<Either<Failure, LoyaltyCardEntity[]>> {
    return this.repository.getAll();
  }
}

export class GetLoyaltyCardByIdUseCase {
  private repository: LoyaltyCardRepository;

  constructor(repository: LoyaltyCardRepository) {
    this.repository = repository;
  }

  async execute(id: string): Promise<Either<Failure, LoyaltyCardEntity>> {
    return this.repository.getById(id);
  }
}

export class AddLoyaltyCardUseCase {
  private repository: LoyaltyCardRepository;

  constructor(repository: LoyaltyCardRepository) {
    this.repository = repository;
  }

  async execute(entity: LoyaltyCardEntity): Promise<Either<Failure, LoyaltyCardEntity>> {
    return this.repository.add(entity);
  }
}

export class UpdateLoyaltyCardUseCase {
  private repository: LoyaltyCardRepository;

  constructor(repository: LoyaltyCardRepository) {
    this.repository = repository;
  }

  async execute(entity: LoyaltyCardEntity): Promise<Either<Failure, LoyaltyCardEntity>> {
    return this.repository.update(entity);
  }
}

export class DeleteLoyaltyCardUseCase {
  private repository: LoyaltyCardRepository;

  constructor(repository: LoyaltyCardRepository) {
    this.repository = repository;
  }

  async execute(id: string): Promise<Either<Failure, void>> {
    return this.repository.delete(id);
  }
}
