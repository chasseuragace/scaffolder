import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/pagination/pagination.dart';
import '../entities/user_entity.dart';

/// Domain repository contract for User. Implementations live in the
/// `data/` layer.
abstract class UserRepository {
  Future<Either<Failure, List<UserEntity>>> getAll();
  Future<Either<Failure, PaginatedResponse<UserEntity>>> getAllPaginated(
    PaginationParams params,
  );
  Future<Either<Failure, UserEntity>> getById(String id);
  Future<Either<Failure, UserEntity>> add(UserEntity entity);
  Future<Either<Failure, UserEntity>> update(UserEntity entity);
  Future<Either<Failure, Unit>> delete(String id);
  Future<Either<Failure, List<UserEntity>>> search(String query);
}
