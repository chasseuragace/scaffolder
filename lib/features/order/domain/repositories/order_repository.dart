import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/pagination/pagination.dart';
import '../entities/order_entity.dart';

/// Domain repository contract for Order. Implementations live in the
/// `data/` layer.
abstract class OrderRepository {
  Future<Either<Failure, List<OrderEntity>>> getAll();
  Future<Either<Failure, PaginatedResponse<OrderEntity>>> getAllPaginated(
    PaginationParams params,
  );
  Future<Either<Failure, OrderEntity>> getById(String id);
  Future<Either<Failure, OrderEntity>> add(OrderEntity entity);
  Future<Either<Failure, OrderEntity>> update(OrderEntity entity);
  Future<Either<Failure, Unit>> delete(String id);
  Future<Either<Failure, List<OrderEntity>>> search(String query);
}
