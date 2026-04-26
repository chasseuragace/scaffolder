import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';

class GetAllUsers extends UseCase<List<UserEntity>, NoParams> {
  const GetAllUsers(this._repo);
  final UserRepository _repo;

  @override
  Future<Either<Failure, List<UserEntity>>> call(NoParams params) =>
      _repo.getAll();
}

class GetUserById extends UseCase<UserEntity, String> {
  const GetUserById(this._repo);
  final UserRepository _repo;

  @override
  Future<Either<Failure, UserEntity>> call(String id) => _repo.getById(id);
}

class AddUser extends UseCase<UserEntity, UserEntity> {
  const AddUser(this._repo);
  final UserRepository _repo;

  @override
  Future<Either<Failure, UserEntity>> call(UserEntity params) =>
      _repo.add(params);
}

class UpdateUser extends UseCase<UserEntity, UserEntity> {
  const UpdateUser(this._repo);
  final UserRepository _repo;

  @override
  Future<Either<Failure, UserEntity>> call(UserEntity params) =>
      _repo.update(params);
}

class DeleteUser extends UseCase<Unit, String> {
  const DeleteUser(this._repo);
  final UserRepository _repo;

  @override
  Future<Either<Failure, Unit>> call(String id) => _repo.delete(id);
}

class SearchUsers extends UseCase<List<UserEntity>, String> {
  const SearchUsers(this._repo);
  final UserRepository _repo;

  @override
  Future<Either<Failure, List<UserEntity>>> call(String query) =>
      _repo.search(query);
}
