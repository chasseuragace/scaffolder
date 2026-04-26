import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../../data/repositories/user_profile_repository_fake.dart';

/// Single source of truth for the UserProfile repository. Override this
/// provider in tests or production wiring.
final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  return UserProfileRepositoryFake.seeded();
});

/// Surfaced when a mutation (add/edit/remove) fails. The list state itself
/// is rolled back to its pre-mutation value so the page stays usable; this
/// provider lets the UI show transient feedback (e.g. a SnackBar) without
/// putting the whole page into an error state. Reset to null after handling.
final userProfileMutationErrorProvider = StateProvider<Object?>((ref) => null);

/// Single-entity fetch used by the details page. Family-keyed on entity id;
/// `autoDispose` so closing the details page releases the cache.
final userProfileByIdProvider = FutureProvider.autoDispose
    .family<UserProfileEntity, String>((ref, id) async {
  final repo = ref.read(userProfileRepositoryProvider);
  final result = await repo.getById(id);
  return result.fold((f) => throw f, (e) => e);
});

/// Async list state with optimistic mutations.
class UserProfileListNotifier extends AsyncNotifier<List<UserProfileEntity>> {
  UserProfileRepository get _repo => ref.read(userProfileRepositoryProvider);

  void _emitMutationError(Object error) =>
      ref.read(userProfileMutationErrorProvider.notifier).state = error;

  void _emitMutationSuccess(String op) {}

  Future<List<UserProfileEntity>> _fetchInitial() async {
    final result = await _repo.getAll();
    return result.fold((f) => throw f, (l) => l);
  }

  @override
  Future<List<UserProfileEntity>> build() async {
    return _fetchInitial();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchInitial);
  }

  Future<void> add(UserProfileEntity entity) async {
    final previous = state.valueOrNull ?? <UserProfileEntity>[];
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
          for (final e in state.valueOrNull ?? <UserProfileEntity>[])
            if (e.id == tempId) created else e,
        ]);
        _emitMutationSuccess('add');
      },
    );
  }

  Future<void> edit(UserProfileEntity entity) async {
    final previous = state.valueOrNull ?? <UserProfileEntity>[];
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
          for (final e in state.valueOrNull ?? <UserProfileEntity>[])
            if (e.id == saved.id) saved else e,
        ]);
        _emitMutationSuccess('edit');
      },
    );
  }

  Future<void> remove(String id) async {
    final previous = state.valueOrNull ?? <UserProfileEntity>[];
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

final userProfileListProvider =
    AsyncNotifierProvider<UserProfileListNotifier, List<UserProfileEntity>>(
  UserProfileListNotifier.new,
);
