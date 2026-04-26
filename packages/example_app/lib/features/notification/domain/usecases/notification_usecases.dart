import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';

class GetAllNotifications extends UseCase<List<NotificationEntity>, NoParams> {
  const GetAllNotifications(this._repo);
  final NotificationRepository _repo;

  @override
  Future<Either<Failure, List<NotificationEntity>>> call(NoParams params) =>
      _repo.getAll();
}

class GetNotificationById extends UseCase<NotificationEntity, String> {
  const GetNotificationById(this._repo);
  final NotificationRepository _repo;

  @override
  Future<Either<Failure, NotificationEntity>> call(String id) => _repo.getById(id);
}

class AddNotification extends UseCase<NotificationEntity, NotificationEntity> {
  const AddNotification(this._repo);
  final NotificationRepository _repo;

  @override
  Future<Either<Failure, NotificationEntity>> call(NotificationEntity params) =>
      _repo.add(params);
}

class UpdateNotification extends UseCase<NotificationEntity, NotificationEntity> {
  const UpdateNotification(this._repo);
  final NotificationRepository _repo;

  @override
  Future<Either<Failure, NotificationEntity>> call(NotificationEntity params) =>
      _repo.update(params);
}

class DeleteNotification extends UseCase<Unit, String> {
  const DeleteNotification(this._repo);
  final NotificationRepository _repo;

  @override
  Future<Either<Failure, Unit>> call(String id) => _repo.delete(id);
}

class SearchNotifications extends UseCase<List<NotificationEntity>, String> {
  const SearchNotifications(this._repo);
  final NotificationRepository _repo;

  @override
  Future<Either<Failure, List<NotificationEntity>>> call(String query) =>
      _repo.search(query);
}
