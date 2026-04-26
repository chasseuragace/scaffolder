import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/pagination/pagination.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../../data/repositories/user_repository_fake.dart';

/// Single source of truth for the User repository. Override this
/// provider in tests or production wiring.
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryFake.seeded();
});

/// True while there are more pages available. Read this from widgets that
/// render a "load more" affordance; the list notifier keeps it up to date.
final userHasMoreProvider = StateProvider<bool>((ref) => false);

const _userPageSize = 20;

/// Async list state with optimistic mutations.
class UserListNotifier extends AsyncNotifier<List<UserEntity>> {
  UserRepository get _repo => ref.read(userRepositoryProvider);

  bool _loadingMore = false;

  Future<List<UserEntity>> _fetchInitial() async {
    final result = await _repo.getAllPaginated(
      const PaginationParams(offset: 0, limit: _userPageSize),
    );
    return result.fold((f) => throw f, (page) {
      ref.read(userHasMoreProvider.notifier).state = page.hasMore;
      return page.items;
    });
  }

  @override
  Future<List<UserEntity>> build() async {
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
    if (!ref.read(userHasMoreProvider)) return;
    _loadingMore = true;
    final result = await _repo.getAllPaginated(
      PaginationParams(offset: current.length, limit: _userPageSize),
    );
    _loadingMore = false;
    result.fold(
      (_) {
        // Keep existing data on error; surface via a separate channel if needed.
      },
      (page) {
        ref.read(userHasMoreProvider.notifier).state = page.hasMore;
        state = AsyncData([...current, ...page.items]);
      },
    );
  }

  Future<void> add(UserEntity entity) async {
    final previous = state.valueOrNull ?? <UserEntity>[];
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
          for (final e in state.valueOrNull ?? <UserEntity>[])
            if (e.id == tempId) created else e,
        ];
        state = AsyncData(next);
      },
    );
  }

  Future<void> edit(UserEntity entity) async {
    final previous = state.valueOrNull ?? <UserEntity>[];
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
          for (final e in state.valueOrNull ?? <UserEntity>[])
            if (e.id == saved.id) saved else e,
        ]);
      },
    );
  }

  Future<void> remove(String id) async {
    final previous = state.valueOrNull ?? <UserEntity>[];
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

final userListProvider =
    AsyncNotifierProvider<UserListNotifier, List<UserEntity>>(
  UserListNotifier.new,
);

/// Search results provider, family-keyed on the query string.
final userSearchProvider = FutureProvider.autoDispose
    .family<List<UserEntity>, String>((ref, query) async {
  final repo = ref.read(userRepositoryProvider);
  final result = await repo.search(query);
  return result.fold((f) => throw f, (l) => l);
});
