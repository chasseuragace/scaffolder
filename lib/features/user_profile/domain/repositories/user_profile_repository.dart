import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user_profile_entity.dart';

/// Domain repository contract for UserProfile. Implementations live in the
/// `data/` layer.
abstract class UserProfileRepository {
  Future<Either<Failure, List<UserProfileEntity>>> getAll();
  Future<Either<Failure, UserProfileEntity>> getById(String id);
  Future<Either<Failure, UserProfileEntity>> add(UserProfileEntity entity);
  Future<Either<Failure, UserProfileEntity>> update(UserProfileEntity entity);
  Future<Either<Failure, Unit>> delete(String id);
}
