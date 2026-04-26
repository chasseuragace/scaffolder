import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/pagination/pagination.dart';
import '../entities/notification_entity.dart';

/// Domain repository contract for Notification. Implementations live in the
/// `data/` layer.
abstract class NotificationRepository {
  Future<Either<Failure, List<NotificationEntity>>> getAll();
  Future<Either<Failure, PaginatedResponse<NotificationEntity>>> getAllPaginated(
    PaginationParams params,
  );
  Future<Either<Failure, NotificationEntity>> getById(String id);
  Future<Either<Failure, NotificationEntity>> add(NotificationEntity entity);
  Future<Either<Failure, NotificationEntity>> update(NotificationEntity entity);
  Future<Either<Failure, Unit>> delete(String id);
  Future<Either<Failure, List<NotificationEntity>>> search(String query);
}
