import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../models/user_profile_model.dart';

/// In-memory UserProfile repository for development, demos, and tests.
///
/// State is held in a private list — call [seeded] to bootstrap with mock
/// data, or pass [initial] explicitly.
class UserProfileRepositoryFake implements UserProfileRepository {
  UserProfileRepositoryFake({List<UserProfileModel>? initial})
      : _items = [...?initial];

  factory UserProfileRepositoryFake.seeded({int count = 10}) =>
      UserProfileRepositoryFake(initial: UserProfileModel.dummyList(count));

  final List<UserProfileModel> _items;
  var _nextId = 1000;

  @override
  Future<Either<Failure, List<UserProfileEntity>>> getAll() async {
    return Right(_items.map((m) => m.toEntity()).toList(growable: false));
  }

  @override
  Future<Either<Failure, UserProfileEntity>> getById(String id) async {
    final i = _items.indexWhere((m) => m.id == id);
    if (i < 0) return Left(NotFoundFailure('No UserProfile with id $id'));
    return Right(_items[i].toEntity());
  }

  @override
  Future<Either<Failure, UserProfileEntity>> add(UserProfileEntity entity) async {
    final assignedId =
        entity.id.isEmpty ? 'user_profile_${_nextId++}' : entity.id;
    final model = UserProfileModel.fromEntity(entity.copyWith(id: assignedId));
    _items.add(model);
    return Right(model.toEntity());
  }

  @override
  Future<Either<Failure, UserProfileEntity>> update(UserProfileEntity entity) async {
    final i = _items.indexWhere((m) => m.id == entity.id);
    if (i < 0) {
      return Left(NotFoundFailure('No UserProfile with id ${entity.id}'));
    }
    final model = UserProfileModel.fromEntity(entity);
    _items[i] = model;
    return Right(model.toEntity());
  }

  @override
  Future<Either<Failure, Unit>> delete(String id) async {
    final before = _items.length;
    _items.removeWhere((m) => m.id == id);
    if (_items.length == before) {
      return Left(NotFoundFailure('No UserProfile with id $id'));
    }
    return const Right(unit);
  }

}
