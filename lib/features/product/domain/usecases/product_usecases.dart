import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class GetAllProducts extends UseCase<List<ProductEntity>, NoParams> {
  const GetAllProducts(this._repo);
  final ProductRepository _repo;

  @override
  Future<Either<Failure, List<ProductEntity>>> call(NoParams params) =>
      _repo.getAll();
}

class GetProductById extends UseCase<ProductEntity, String> {
  const GetProductById(this._repo);
  final ProductRepository _repo;

  @override
  Future<Either<Failure, ProductEntity>> call(String id) => _repo.getById(id);
}

class AddProduct extends UseCase<ProductEntity, ProductEntity> {
  const AddProduct(this._repo);
  final ProductRepository _repo;

  @override
  Future<Either<Failure, ProductEntity>> call(ProductEntity params) =>
      _repo.add(params);
}

class UpdateProduct extends UseCase<ProductEntity, ProductEntity> {
  const UpdateProduct(this._repo);
  final ProductRepository _repo;

  @override
  Future<Either<Failure, ProductEntity>> call(ProductEntity params) =>
      _repo.update(params);
}

class DeleteProduct extends UseCase<Unit, String> {
  const DeleteProduct(this._repo);
  final ProductRepository _repo;

  @override
  Future<Either<Failure, Unit>> call(String id) => _repo.delete(id);
}

class SearchProducts extends UseCase<List<ProductEntity>, String> {
  const SearchProducts(this._repo);
  final ProductRepository _repo;

  @override
  Future<Either<Failure, List<ProductEntity>>> call(String query) =>
      _repo.search(query);
}
