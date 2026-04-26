import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/pagination/pagination.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';

/// Real Notification repository implementation.
///
/// Wire your remote data source (HTTP client, gRPC stub, etc.) inside the
/// methods below. Errors should be caught and mapped to [Failure] subtypes
/// using [failureFromError].
///
/// Future direction: swap this template for an openapi-generator (dart-dio)
/// variant that injects an `Api` client and maps DTOs -> Entity. The domain
/// layer above does not change.
class NotificationRepositoryImpl implements NotificationRepository {
  const NotificationRepositoryImpl();

  Future<T> _todo<T>(String op) =>
      Future.error(UnimplementedError('NotificationRepositoryImpl.$op'));

  @override
  Future<Either<Failure, List<NotificationEntity>>> getAll() async {
    try {
      final list = await _todo<List<NotificationEntity>>('getAll');
      return Right(list);
    } catch (e) {
      return Left(failureFromError(e));
    }
  }

  @override
  Future<Either<Failure, PaginatedResponse<NotificationEntity>>> getAllPaginated(
    PaginationParams params,
  ) async {
    try {
      final page =
          await _todo<PaginatedResponse<NotificationEntity>>('getAllPaginated');
      return Right(page);
    } catch (e) {
      return Left(failureFromError(e));
    }
  }

  @override
  Future<Either<Failure, NotificationEntity>> getById(String id) async {
    try {
      final item = await _todo<NotificationEntity>('getById');
      return Right(item);
    } catch (e) {
      return Left(failureFromError(e));
    }
  }

  @override
  Future<Either<Failure, NotificationEntity>> add(NotificationEntity entity) async {
    try {
      final created = await _todo<NotificationEntity>('add');
      return Right(created);
    } catch (e) {
      return Left(failureFromError(e));
    }
  }

  @override
  Future<Either<Failure, NotificationEntity>> update(NotificationEntity entity) async {
    try {
      final updated = await _todo<NotificationEntity>('update');
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
  Future<Either<Failure, List<NotificationEntity>>> search(String query) async {
    try {
      final list = await _todo<List<NotificationEntity>>('search');
      return Right(list);
    } catch (e) {
      return Left(failureFromError(e));
    }
  }
}
