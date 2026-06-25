/// Real repository implementation for LoyaltyCard.
/// Currently throws UnimplementedError — replace with actual API calls.
import type { Either } from '../../../../core/usecase/usecase';
import type { Failure } from '../../../../core/errors/failures';
import type { LoyaltyCardEntity } from '../../domain/entities/loyalty-card.entity';
import type { LoyaltyCardRepository } from '../../domain/repositories/loyalty-card.repository';

export class LoyaltyCardRepositoryImpl implements LoyaltyCardRepository {
  async getAll(): Promise<Either<Failure, LoyaltyCardEntity[]>> {
    throw new Error('UnimplementedError: Real repository not yet implemented');
  }

  async getById(_id: string): Promise<Either<Failure, LoyaltyCardEntity>> {
    throw new Error('UnimplementedError: Real repository not yet implemented');
  }

  async add(_entity: LoyaltyCardEntity): Promise<Either<Failure, LoyaltyCardEntity>> {
    throw new Error('UnimplementedError: Real repository not yet implemented');
  }

  async update(_entity: LoyaltyCardEntity): Promise<Either<Failure, LoyaltyCardEntity>> {
    throw new Error('UnimplementedError: Real repository not yet implemented');
  }

  async delete(_id: string): Promise<Either<Failure, void>> {
    throw new Error('UnimplementedError: Real repository not yet implemented');
  }

}
