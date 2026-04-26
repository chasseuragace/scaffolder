import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/pagination/pagination.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';

/// Real User repository implementation.
///
/// Wire your remote data source (HTTP client, gRPC stub, etc.) inside the
/// methods below. Errors should be caught and mapped to [Failure] subtypes
/// using [failureFromError].
///
/// Future direction: swap this template for an openapi-generator (dart-dio)
/// variant that injects an `Api` client and maps DTOs -> Entity. The domain
/// layer above does not change.
class UserRepositoryImpl implements UserRepository {
  const UserRepositoryImpl();

  Future<T> _todo<T>(String op) =>
      Future.error(UnimplementedError('UserRepositoryImpl.$op'));

  @override
  Future<Either<Failure, List<UserEntity>>> getAll() async {
    try {
      final list = await _todo<List<UserEntity>>('getAll');
      return Right(list);
    } catch (e) {
      return Left(failureFromError(e));
    }
  }

  @override
  Future<Either<Failure, PaginatedResponse<UserEntity>>> getAllPaginated(
    PaginationParams params,
  ) async {
    try {
      final page =
          await _todo<PaginatedResponse<UserEntity>>('getAllPaginated');
      return Right(page);
    } catch (e) {
      return Left(failureFromError(e));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getById(String id) async {
    try {
      final item = await _todo<UserEntity>('getById');
      return Right(item);
    } catch (e) {
      return Left(failureFromError(e));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> add(UserEntity entity) async {
    try {
      final created = await _todo<UserEntity>('add');
      return Right(created);
    } catch (e) {
      return Left(failureFromError(e));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> update(UserEntity entity) async {
    try {
      final updated = await _todo<UserEntity>('update');
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

  @override
  Future<Either<Failure, List<UserEntity>>> search(String query) async {
    try {
      final list = await _todo<List<UserEntity>>('search');
      return Right(list);
    } catch (e) {
      return Left(failureFromError(e));
    }
  }
}
