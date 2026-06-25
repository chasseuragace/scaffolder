/// Repository contract for LoyaltyCard.
import type { Either } from '../../../../core/usecase/usecase';
import type { Failure } from '../../../../core/errors/failures';
import type { LoyaltyCardEntity } from '../entities/loyalty-card.entity';

export interface LoyaltyCardRepository {
  getAll(): Promise<Either<Failure, LoyaltyCardEntity[]>>;
  getById(id: string): Promise<Either<Failure, LoyaltyCardEntity>>;
  add(entity: LoyaltyCardEntity): Promise<Either<Failure, LoyaltyCardEntity>>;
  update(entity: LoyaltyCardEntity): Promise<Either<Failure, LoyaltyCardEntity>>;
  delete(id: string): Promise<Either<Failure, void>>;
}
