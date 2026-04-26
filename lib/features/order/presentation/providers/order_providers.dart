import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/pagination/pagination.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../../data/repositories/order_repository_fake.dart';

/// Single source of truth for the Order repository. Override this
/// provider in tests or production wiring.
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepositoryFake.seeded();
});

/// True while there are more pages available. Read this from widgets that
/// render a "load more" affordance; the list notifier keeps it up to date.
final orderHasMoreProvider = StateProvider<bool>((ref) => false);

const _orderPageSize = 20;

/// Async list state with optimistic mutations.
class OrderListNotifier extends AsyncNotifier<List<OrderEntity>> {
  OrderRepository get _repo => ref.read(orderRepositoryProvider);

  bool _loadingMore = false;

  Future<List<OrderEntity>> _fetchInitial() async {
    final result = await _repo.getAllPaginated(
      const PaginationParams(offset: 0, limit: _orderPageSize),
    );
    return result.fold((f) => throw f, (page) {
      ref.read(orderHasMoreProvider.notifier).state = page.hasMore;
      return page.items;
    });
  }

  @override
  Future<List<OrderEntity>> build() async {
    return _fetchInitial();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchInitial);
  }

  /// Appends the next page if one is available. Safe to call repeatedly —
  /// returns immediately when already loading or fully loaded.
  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null) return;
    if (_loadingMore) return;
    if (!ref.read(orderHasMoreProvider)) return;
    _loadingMore = true;
    final result = await _repo.getAllPaginated(
      PaginationParams(offset: current.length, limit: _orderPageSize),
    );
    _loadingMore = false;
    result.fold(
      (_) {
        // Keep existing data on error; surface via a separate channel if needed.
      },
      (page) {
        ref.read(orderHasMoreProvider.notifier).state = page.hasMore;
        state = AsyncData([...current, ...page.items]);
      },
    );
  }

  Future<void> add(OrderEntity entity) async {
    final previous = state.valueOrNull ?? <OrderEntity>[];
    final tempId = entity.id.isEmpty
        ? 'tmp_${DateTime.now().microsecondsSinceEpoch}'
        : entity.id;
    final optimistic = entity.copyWith(id: tempId);
    state = AsyncData([...previous, optimistic]);

    final result = await _repo.add(entity);
    result.fold(
      (f) {
        state = AsyncData(previous);
        state = AsyncError(f, StackTrace.current);
      },
      (created) {
        final next = [
          for (final e in state.valueOrNull ?? <OrderEntity>[])
            if (e.id == tempId) created else e,
        ];
        state = AsyncData(next);
      },
    );
  }

  Future<void> edit(OrderEntity entity) async {
    final previous = state.valueOrNull ?? <OrderEntity>[];
    state = AsyncData([
      for (final e in previous) if (e.id == entity.id) entity else e,
    ]);

    final result = await _repo.update(entity);
    result.fold(
      (f) {
        state = AsyncData(previous);
        state = AsyncError(f, StackTrace.current);
      },
      (saved) {
        state = AsyncData([
          for (final e in state.valueOrNull ?? <OrderEntity>[])
            if (e.id == saved.id) saved else e,
        ]);
      },
    );
  }

  Future<void> remove(String id) async {
    final previous = state.valueOrNull ?? <OrderEntity>[];
    state = AsyncData(previous.where((e) => e.id != id).toList());

    final result = await _repo.delete(id);
    result.fold(
      (f) {
        state = AsyncData(previous);
        state = AsyncError(f, StackTrace.current);
      },
      (_) {},
    );
  }
}

final orderListProvider =
    AsyncNotifierProvider<OrderListNotifier, List<OrderEntity>>(
  OrderListNotifier.new,
);

/// Search results provider, family-keyed on the query string.
final orderSearchProvider = FutureProvider.autoDispose
    .family<List<OrderEntity>, String>((ref, query) async {
  final repo = ref.read(orderRepositoryProvider);
  final result = await repo.search(query);
  return result.fold((f) => throw f, (l) => l);
});
