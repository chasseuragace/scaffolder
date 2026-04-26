import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/pagination/pagination.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../models/product_model.dart';

/// In-memory Product repository for development, demos, and tests.
///
/// State is held in a private list — call [seeded] to bootstrap with mock
/// data, or pass [initial] explicitly.
class ProductRepositoryFake implements ProductRepository {
  ProductRepositoryFake({List<ProductModel>? initial})
      : _items = [...?initial];

  factory ProductRepositoryFake.seeded({int count = 10}) =>
      ProductRepositoryFake(initial: ProductModel.dummyList(count));

  final List<ProductModel> _items;
  var _nextId = 1000;

  @override
  Future<Either<Failure, List<ProductEntity>>> getAll() async {
    return Right(_items.map((m) => m.toEntity()).toList(growable: false));
  }

  @override
  Future<Either<Failure, PaginatedResponse<ProductEntity>>> getAllPaginated(
    PaginationParams params,
  ) async {
    final start = params.offset.clamp(0, _items.length);
    final end = (params.offset + params.limit).clamp(0, _items.length);
    final slice = _items
        .sublist(start, end)
        .map((m) => m.toEntity())
        .toList(growable: false);
    return Right(PaginatedResponse<ProductEntity>(
      items: slice,
      total: _items.length,
      offset: params.offset,
      limit: params.limit,
    ));
  }

  @override
  Future<Either<Failure, ProductEntity>> getById(String id) async {
    final i = _items.indexWhere((m) => m.id == id);
    if (i < 0) return Left(NotFoundFailure('No Product with id $id'));
    return Right(_items[i].toEntity());
  }

  @override
  Future<Either<Failure, ProductEntity>> add(ProductEntity entity) async {
    final assignedId =
        entity.id.isEmpty ? 'product_${_nextId++}' : entity.id;
    final model = ProductModel.fromEntity(entity.copyWith(id: assignedId));
    _items.add(model);
    return Right(model.toEntity());
  }

  @override
  Future<Either<Failure, ProductEntity>> update(ProductEntity entity) async {
    final i = _items.indexWhere((m) => m.id == entity.id);
    if (i < 0) {
      return Left(NotFoundFailure('No Product with id ${entity.id}'));
    }
    final model = ProductModel.fromEntity(entity);
    _items[i] = model;
    return Right(model.toEntity());
  }

  @override
  Future<Either<Failure, Unit>> delete(String id) async {
    final before = _items.length;
    _items.removeWhere((m) => m.id == id);
    if (_items.length == before) {
      return Left(NotFoundFailure('No Product with id $id'));
    }
    return const Right(unit);
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> search(String query) async {
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
