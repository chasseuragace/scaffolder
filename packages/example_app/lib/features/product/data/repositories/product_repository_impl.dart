import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/pagination/pagination.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';

/// Real Product repository implementation.
///
/// Wire your remote data source (HTTP client, gRPC stub, etc.) inside the
/// methods below. Errors should be caught and mapped to [Failure] subtypes
/// using [failureFromError].
///
/// Future direction: swap this template for an openapi-generator (dart-dio)
/// variant that injects an `Api` client and maps DTOs -> Entity. The domain
/// layer above does not change.
class ProductRepositoryImpl implements ProductRepository {
  const ProductRepositoryImpl();

  Future<T> _todo<T>(String op) =>
      Future.error(UnimplementedError('ProductRepositoryImpl.$op'));

  @override
  Future<Either<Failure, List<ProductEntity>>> getAll() async {
    try {
      final list = await _todo<List<ProductEntity>>('getAll');
      return Right(list);
    } catch (e) {
      return Left(failureFromError(e));
    }
  }

  @override
  Future<Either<Failure, PaginatedResponse<ProductEntity>>> getAllPaginated(
    PaginationParams params,
  ) async {
    try {
      final page =
          await _todo<PaginatedResponse<ProductEntity>>('getAllPaginated');
      return Right(page);
    } catch (e) {
      return Left(failureFromError(e));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> getById(String id) async {
    try {
      final item = await _todo<ProductEntity>('getById');
      return Right(item);
    } catch (e) {
      return Left(failureFromError(e));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> add(ProductEntity entity) async {
    try {
      final created = await _todo<ProductEntity>('add');
      return Right(created);
    } catch (e) {
      return Left(failureFromError(e));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> update(ProductEntity entity) async {
    try {
      final updated = await _todo<ProductEntity>('update');
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
  Future<Either<Failure, List<ProductEntity>>> search(String query) async {
    try {
      final list = await _todo<List<ProductEntity>>('search');
      return Right(list);
    } catch (e) {
      return Left(failureFromError(e));
    }
  }
}
