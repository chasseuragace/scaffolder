import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class GetAllOrders extends UseCase<List<OrderEntity>, NoParams> {
  const GetAllOrders(this._repo);
  final OrderRepository _repo;

  @override
  Future<Either<Failure, List<OrderEntity>>> call(NoParams params) =>
      _repo.getAll();
}

class GetOrderById extends UseCase<OrderEntity, String> {
  const GetOrderById(this._repo);
  final OrderRepository _repo;

  @override
  Future<Either<Failure, OrderEntity>> call(String id) => _repo.getById(id);
}

class AddOrder extends UseCase<OrderEntity, OrderEntity> {
  const AddOrder(this._repo);
  final OrderRepository _repo;

  @override
  Future<Either<Failure, OrderEntity>> call(OrderEntity params) =>
      _repo.add(params);
}

class UpdateOrder extends UseCase<OrderEntity, OrderEntity> {
  const UpdateOrder(this._repo);
  final OrderRepository _repo;

  @override
  Future<Either<Failure, OrderEntity>> call(OrderEntity params) =>
      _repo.update(params);
}

class DeleteOrder extends UseCase<Unit, String> {
  const DeleteOrder(this._repo);
  final OrderRepository _repo;

  @override
  Future<Either<Failure, Unit>> call(String id) => _repo.delete(id);
}

class SearchOrders extends UseCase<List<OrderEntity>, String> {
  const SearchOrders(this._repo);
  final OrderRepository _repo;

  @override
  Future<Either<Failure, List<OrderEntity>>> call(String query) =>
      _repo.search(query);
}
