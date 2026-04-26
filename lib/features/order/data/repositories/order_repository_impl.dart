import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/pagination/pagination.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';

/// Real Order repository implementation.
///
/// Wire your remote data source (HTTP client, gRPC stub, etc.) inside the
/// methods below. Errors should be caught and mapped to [Failure] subtypes
/// using [failureFromError].
///
/// Future direction: swap this template for an openapi-generator (dart-dio)
/// variant that injects an `Api` client and maps DTOs -> Entity. The domain
/// layer above does not change.
class OrderRepositoryImpl implements OrderRepository {
  const OrderRepositoryImpl();

  Future<T> _todo<T>(String op) =>
      Future.error(UnimplementedError('OrderRepositoryImpl.$op'));

  @override
  Future<Either<Failure, List<OrderEntity>>> getAll() async {
    try {
      final list = await _todo<List<OrderEntity>>('getAll');
      return Right(list);
    } catch (e) {
      return Left(failureFromError(e));
    }
  }

  @override
  Future<Either<Failure, PaginatedResponse<OrderEntity>>> getAllPaginated(
    PaginationParams params,
  ) async {
    try {
      final page =
          await _todo<PaginatedResponse<OrderEntity>>('getAllPaginated');
      return Right(page);
    } catch (e) {
      return Left(failureFromError(e));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> getById(String id) async {
    try {
      final item = await _todo<OrderEntity>('getById');
      return Right(item);
    } catch (e) {
      return Left(failureFromError(e));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> add(OrderEntity entity) async {
    try {
      final created = await _todo<OrderEntity>('add');
      return Right(created);
    } catch (e) {
      return Left(failureFromError(e));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> update(OrderEntity entity) async {
    try {
      final updated = await _todo<OrderEntity>('update');
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
  Future<Either<Failure, List<OrderEntity>>> search(String query) async {
    try {
      final list = await _todo<List<OrderEntity>>('search');
      return Right(list);
    } catch (e) {
      return Left(failureFromError(e));
    }
  }
}
