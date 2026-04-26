import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/pagination/pagination.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/user_model.dart';

/// In-memory User repository for development, demos, and tests.
///
/// State is held in a private list — call [seeded] to bootstrap with mock
/// data, or pass [initial] explicitly.
class UserRepositoryFake implements UserRepository {
  UserRepositoryFake({List<UserModel>? initial})
      : _items = [...?initial];

  factory UserRepositoryFake.seeded({int count = 10}) =>
      UserRepositoryFake(initial: UserModel.dummyList(count));

  final List<UserModel> _items;
  var _nextId = 1000;

  @override
  Future<Either<Failure, List<UserEntity>>> getAll() async {
    return Right(_items.map((m) => m.toEntity()).toList(growable: false));
  }

  @override
  Future<Either<Failure, PaginatedResponse<UserEntity>>> getAllPaginated(
    PaginationParams params,
  ) async {
    final start = params.offset.clamp(0, _items.length);
    final end = (params.offset + params.limit).clamp(0, _items.length);
    final slice = _items
        .sublist(start, end)
        .map((m) => m.toEntity())
        .toList(growable: false);
    return Right(PaginatedResponse<UserEntity>(
      items: slice,
      total: _items.length,
      offset: params.offset,
      limit: params.limit,
    ));
  }

  @override
  Future<Either<Failure, UserEntity>> getById(String id) async {
    final i = _items.indexWhere((m) => m.id == id);
    if (i < 0) return Left(NotFoundFailure('No User with id $id'));
    return Right(_items[i].toEntity());
  }

  @override
  Future<Either<Failure, UserEntity>> add(UserEntity entity) async {
    final assignedId =
        entity.id.isEmpty ? 'user_${_nextId++}' : entity.id;
    final model = UserModel.fromEntity(entity.copyWith(id: assignedId));
    _items.add(model);
    return Right(model.toEntity());
  }

  @override
  Future<Either<Failure, UserEntity>> update(UserEntity entity) async {
    final i = _items.indexWhere((m) => m.id == entity.id);
    if (i < 0) {
      return Left(NotFoundFailure('No User with id ${entity.id}'));
    }
    final model = UserModel.fromEntity(entity);
    _items[i] = model;
    return Right(model.toEntity());
  }

  @override
  Future<Either<Failure, Unit>> delete(String id) async {
    final before = _items.length;
    _items.removeWhere((m) => m.id == id);
    if (_items.length == before) {
      return Left(NotFoundFailure('No User with id $id'));
    }
    return const Right(unit);
  }

  @override
  Future<Either<Failure, List<UserEntity>>> search(String query) async {
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
