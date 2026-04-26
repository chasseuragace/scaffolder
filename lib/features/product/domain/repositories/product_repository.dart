import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/pagination/pagination.dart';
import '../entities/product_entity.dart';

/// Domain repository contract for Product. Implementations live in the
/// `data/` layer.
abstract class ProductRepository {
  Future<Either<Failure, List<ProductEntity>>> getAll();
  Future<Either<Failure, PaginatedResponse<ProductEntity>>> getAllPaginated(
    PaginationParams params,
  );
  Future<Either<Failure, ProductEntity>> getById(String id);
  Future<Either<Failure, ProductEntity>> add(ProductEntity entity);
  Future<Either<Failure, ProductEntity>> update(ProductEntity entity);
  Future<Either<Failure, Unit>> delete(String id);
  Future<Either<Failure, List<ProductEntity>>> search(String query);
}
