import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/user_profile_repository.dart';

/// Real UserProfile repository implementation.
///
/// Wire your remote data source (HTTP client, gRPC stub, etc.) inside the
/// methods below. Errors should be caught and mapped to [Failure] subtypes
/// using [failureFromError].
///
/// Future direction: swap this template for an openapi-generator (dart-dio)
/// variant that injects an `Api` client and maps DTOs -> Entity. The domain
/// layer above does not change.
class UserProfileRepositoryImpl implements UserProfileRepository {
  const UserProfileRepositoryImpl();

  Future<T> _todo<T>(String op) =>
      Future.error(UnimplementedError('UserProfileRepositoryImpl.$op'));

  @override
  Future<Either<Failure, List<UserProfileEntity>>> getAll() async {
    try {
      final list = await _todo<List<UserProfileEntity>>('getAll');
      return Right(list);
    } catch (e) {
      return Left(failureFromError(e));
    }
  }

  @override
  Future<Either<Failure, UserProfileEntity>> getById(String id) async {
    try {
      final item = await _todo<UserProfileEntity>('getById');
      return Right(item);
    } catch (e) {
      return Left(failureFromError(e));
    }
  }

  @override
  Future<Either<Failure, UserProfileEntity>> add(UserProfileEntity entity) async {
    try {
      final created = await _todo<UserProfileEntity>('add');
      return Right(created);
    } catch (e) {
      return Left(failureFromError(e));
    }
  }

  @override
  Future<Either<Failure, UserProfileEntity>> update(UserProfileEntity entity) async {
    try {
      final updated = await _todo<UserProfileEntity>('update');
      return Right(updated);
    } catch (e) {
      return Left(failureFromError(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> delete(String id) async {
    try {
      await _todo<void>('delete');
      return const Right(unit);
    } catch (e) {
      return Left(failureFromError(e));
    }
  }

}
