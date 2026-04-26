import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/pagination/pagination.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../data/repositories/notification_repository_fake.dart';

/// Single source of truth for the Notification repository. Override this
/// provider in tests or production wiring.
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryFake.seeded();
});

/// True while there are more pages available. Read this from widgets that
/// render a "load more" affordance; the list notifier keeps it up to date.
final notificationHasMoreProvider = StateProvider<bool>((ref) => false);

const _notificationPageSize = 20;

/// Surfaced when a mutation (add/edit/remove) fails. The list state itself
/// is rolled back to its pre-mutation value so the page stays usable; this
/// provider lets the UI show transient feedback (e.g. a SnackBar) without
/// putting the whole page into an error state. Reset to null after handling.
final notificationMutationErrorProvider = StateProvider<Object?>((ref) => null);

/// Names which mutation succeeded — `'add'`, `'edit'`, or `'remove'`.
/// The list page listens to this and shows a brief confirmation SnackBar.
/// Reset to null after handling.
final notificationMutationSuccessProvider = StateProvider<String?>((ref) => null);

/// Single-entity fetch used by the details page. Family-keyed on entity id;
/// `autoDispose` so closing the details page releases the cache.
final notificationByIdProvider = FutureProvider.autoDispose
    .family<NotificationEntity, String>((ref, id) async {
  final repo = ref.read(notificationRepositoryProvider);
  final result = await repo.getById(id);
  return result.fold((f) => throw f, (e) => e);
});

/// Async list state with optimistic mutations.
class NotificationListNotifier extends AsyncNotifier<List<NotificationEntity>> {
  NotificationRepository get _repo => ref.read(notificationRepositoryProvider);

  void _emitMutationError(Object error) =>
      ref.read(notificationMutationErrorProvider.notifier).state = error;

  void _emitMutationSuccess(String op) =>
      ref.read(notificationMutationSuccessProvider.notifier).state = op;

  bool _loadingMore = false;

  Future<List<NotificationEntity>> _fetchInitial() async {
    final result = await _repo.getAllPaginated(
      const PaginationParams(offset: 0, limit: _notificationPageSize),
    );
    return result.fold((f) => throw f, (page) {
      ref.read(notificationHasMoreProvider.notifier).state = page.hasMore;
      return page.items;
    });
  }

  @override
  Future<List<NotificationEntity>> build() async {
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
    if (!ref.read(notificationHasMoreProvider)) return;
    _loadingMore = true;
    final result = await _repo.getAllPaginated(
      PaginationParams(offset: current.length, limit: _notificationPageSize),
    );
    _loadingMore = false;
    result.fold(
      _emitMutationError,
      (page) {
        ref.read(notificationHasMoreProvider.notifier).state = page.hasMore;
        state = AsyncData([...current, ...page.items]);
      },
    );
  }

  Future<void> add(NotificationEntity entity) async {
    final previous = state.valueOrNull ?? <NotificationEntity>[];
    final tempId = entity.id.isEmpty
        ? 'tmp_${DateTime.now().microsecondsSinceEpoch}'
        : entity.id;
    final optimistic = entity.copyWith(id: tempId);
    state = AsyncData([...previous, optimistic]);

    final result = await _repo.add(entity);
    result.fold(
      (f) {
        state = AsyncData(previous);
        _emitMutationError(f);
      },
      (created) {
        state = AsyncData([
          for (final e in state.valueOrNull ?? <NotificationEntity>[])
            if (e.id == tempId) created else e,
        ]);
        _emitMutationSuccess('add');
      },
    );
  }

  Future<void> edit(NotificationEntity entity) async {
    final previous = state.valueOrNull ?? <NotificationEntity>[];
    state = AsyncData([
      for (final e in previous) if (e.id == entity.id) entity else e,
    ]);

    final result = await _repo.update(entity);
    result.fold(
      (f) {
        state = AsyncData(previous);
        _emitMutationError(f);
      },
      (saved) {
        state = AsyncData([
          for (final e in state.valueOrNull ?? <NotificationEntity>[])
            if (e.id == saved.id) saved else e,
        ]);
        _emitMutationSuccess('edit');
      },
    );
  }

  Future<void> remove(String id) async {
    final previous = state.valueOrNull ?? <NotificationEntity>[];
    state = AsyncData(previous.where((e) => e.id != id).toList());

    final result = await _repo.delete(id);
    result.fold(
      (f) {
        state = AsyncData(previous);
        _emitMutationError(f);
      },
      (_) {
        _emitMutationSuccess('remove');
      },
    );
  }
}

final notificationListProvider =
    AsyncNotifierProvider<NotificationListNotifier, List<NotificationEntity>>(
  NotificationListNotifier.new,
);

/// Search results provider, family-keyed on the query string.
final notificationSearchProvider = FutureProvider.autoDispose
    .family<List<NotificationEntity>, String>((ref, query) async {
  final repo = ref.read(notificationRepositoryProvider);
  final result = await repo.search(query);
  return result.fold((f) => throw f, (l) => l);
});
