import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/pagination/pagination.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../models/order_model.dart';

/// In-memory Order repository for development, demos, and tests.
///
/// State is held in a private list — call [seeded] to bootstrap with mock
/// data, or pass [initial] explicitly.
class OrderRepositoryFake implements OrderRepository {
  OrderRepositoryFake({List<OrderModel>? initial})
      : _items = [...?initial];

  factory OrderRepositoryFake.seeded({int count = 10}) =>
      OrderRepositoryFake(initial: OrderModel.dummyList(count));

  final List<OrderModel> _items;
  var _nextId = 1000;

  @override
  Future<Either<Failure, List<OrderEntity>>> getAll() async {
    return Right(_items.map((m) => m.toEntity()).toList(growable: false));
  }

  @override
  Future<Either<Failure, PaginatedResponse<OrderEntity>>> getAllPaginated(
    PaginationParams params,
  ) async {
    final start = params.offset.clamp(0, _items.length);
    final end = (params.offset + params.limit).clamp(0, _items.length);
    final slice = _items
        .sublist(start, end)
        .map((m) => m.toEntity())
        .toList(growable: false);
    return Right(PaginatedResponse<OrderEntity>(
      items: slice,
      total: _items.length,
      offset: params.offset,
      limit: params.limit,
    ));
  }

  @override
  Future<Either<Failure, OrderEntity>> getById(String id) async {
    final i = _items.indexWhere((m) => m.id == id);
    if (i < 0) return Left(NotFoundFailure('No Order with id $id'));
    return Right(_items[i].toEntity());
  }

  @override
  Future<Either<Failure, OrderEntity>> add(OrderEntity entity) async {
    final assignedId =
        entity.id.isEmpty ? 'order_${_nextId++}' : entity.id;
    final model = OrderModel.fromEntity(entity.copyWith(id: assignedId));
    _items.add(model);
    return Right(model.toEntity());
  }

  @override
  Future<Either<Failure, OrderEntity>> update(OrderEntity entity) async {
    final i = _items.indexWhere((m) => m.id == entity.id);
    if (i < 0) {
      return Left(NotFoundFailure('No Order with id ${entity.id}'));
    }
    final model = OrderModel.fromEntity(entity);
    _items[i] = model;
    return Right(model.toEntity());
  }

  @override
  Future<Either<Failure, Unit>> delete(String id) async {
    final before = _items.length;
    _items.removeWhere((m) => m.id == id);
    if (_items.length == before) {
      return Left(NotFoundFailure('No Order with id $id'));
    }
    return const Right(unit);
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> search(String query) async {
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
