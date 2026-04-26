import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/pagination/pagination.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../models/notification_model.dart';

/// In-memory Notification repository for development, demos, and tests.
///
/// State is held in a private list — call [seeded] to bootstrap with mock
/// data, or pass [initial] explicitly.
class NotificationRepositoryFake implements NotificationRepository {
  NotificationRepositoryFake({List<NotificationModel>? initial})
      : _items = [...?initial];

  factory NotificationRepositoryFake.seeded({int count = 10}) =>
      NotificationRepositoryFake(initial: NotificationModel.dummyList(count));

  final List<NotificationModel> _items;
  var _nextId = 1000;

  @override
  Future<Either<Failure, List<NotificationEntity>>> getAll() async {
    return Right(_items.map((m) => m.toEntity()).toList(growable: false));
  }

  @override
  Future<Either<Failure, PaginatedResponse<NotificationEntity>>> getAllPaginated(
    PaginationParams params,
  ) async {
    final start = params.offset.clamp(0, _items.length);
    final end = (params.offset + params.limit).clamp(0, _items.length);
    final slice = _items
        .sublist(start, end)
        .map((m) => m.toEntity())
        .toList(growable: false);
    return Right(PaginatedResponse<NotificationEntity>(
      items: slice,
      total: _items.length,
      offset: params.offset,
      limit: params.limit,
    ));
  }

  @override
  Future<Either<Failure, NotificationEntity>> getById(String id) async {
    final i = _items.indexWhere((m) => m.id == id);
    if (i < 0) return Left(NotFoundFailure('No Notification with id $id'));
    return Right(_items[i].toEntity());
  }

  @override
  Future<Either<Failure, NotificationEntity>> add(NotificationEntity entity) async {
    final assignedId =
        entity.id.isEmpty ? 'notification_${_nextId++}' : entity.id;
    final model = NotificationModel.fromEntity(entity.copyWith(id: assignedId));
    _items.add(model);
    return Right(model.toEntity());
  }

  @override
  Future<Either<Failure, NotificationEntity>> update(NotificationEntity entity) async {
    final i = _items.indexWhere((m) => m.id == entity.id);
    if (i < 0) {
      return Left(NotFoundFailure('No Notification with id ${entity.id}'));
    }
    final model = NotificationModel.fromEntity(entity);
    _items[i] = model;
    return Right(model.toEntity());
  }

  @override
  Future<Either<Failure, Unit>> delete(String id) async {
    final before = _items.length;
    _items.removeWhere((m) => m.id == id);
    if (_items.length == before) {
      return Left(NotFoundFailure('No Notification with id $id'));
    }
    return const Right(unit);
  }

  @override
  Future<Either<Failure, List<NotificationEntity>>> search(String query) async {
    final q = query.toLowerCase();
    final hits = _items
        .where((m) =>
            (m.name ?? '').toLowerCase().contains(q) ||
            (m.description ?? '').toLowerCase().contains(q))
        .map((m) => m.toEntity())
        .toList(growable: false);
    return Right(hits);
  }
}
