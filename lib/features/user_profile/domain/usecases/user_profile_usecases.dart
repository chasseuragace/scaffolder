import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user_profile_entity.dart';
import '../repositories/user_profile_repository.dart';

class GetAllUserProfiles extends UseCase<List<UserProfileEntity>, NoParams> {
  const GetAllUserProfiles(this._repo);
  final UserProfileRepository _repo;

  @override
  Future<Either<Failure, List<UserProfileEntity>>> call(NoParams params) =>
      _repo.getAll();
}

class GetUserProfileById extends UseCase<UserProfileEntity, String> {
  const GetUserProfileById(this._repo);
  final UserProfileRepository _repo;

  @override
  Future<Either<Failure, UserProfileEntity>> call(String id) => _repo.getById(id);
}

class AddUserProfile extends UseCase<UserProfileEntity, UserProfileEntity> {
  const AddUserProfile(this._repo);
  final UserProfileRepository _repo;

  @override
  Future<Either<Failure, UserProfileEntity>> call(UserProfileEntity params) =>
      _repo.add(params);
}

class UpdateUserProfile extends UseCase<UserProfileEntity, UserProfileEntity> {
  const UpdateUserProfile(this._repo);
  final UserProfileRepository _repo;

  @override
  Future<Either<Failure, UserProfileEntity>> call(UserProfileEntity params) =>
      _repo.update(params);
}

class DeleteUserProfile extends UseCase<Unit, String> {
  const DeleteUserProfile(this._repo);
  final UserProfileRepository _repo;

  @override
  Future<Either<Failure, Unit>> call(String id) => _repo.delete(id);
}
