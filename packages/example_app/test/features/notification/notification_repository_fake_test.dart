// ignore: unused_import
import 'package:dartz/dartz.dart';
import 'package:flutter_project/core/errors/failures.dart';
import 'package:flutter_project/core/pagination/pagination.dart';
import 'package:flutter_project/features/notification/data/repositories/notification_repository_fake.dart';
import 'package:flutter_project/features/notification/domain/entities/notification_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationRepositoryFake', () {
    test('seeded repo returns the expected count', () async {
      final repo = NotificationRepositoryFake.seeded(count: 3);
      final result = await repo.getAll();
      expect(result.isRight(), isTrue);
      expect(
        result.getOrElse(() => const []).length,
        3,
      );
    });

    test('add then getById round-trips', () async {
      final repo = NotificationRepositoryFake();
      final added = await repo.add(const NotificationEntity(
        id: '',
        name: 'New',
        description: 'desc',
      ));
      final id = added.fold((_) => '', (e) => e.id);
      expect(id, isNotEmpty);
      final fetched = await repo.getById(id);
      expect(fetched.isRight(), isTrue);
      expect(fetched.fold((_) => null, (e) => e.name), 'New');
    });

    test('delete returns NotFoundFailure for missing id', () async {
      final repo = NotificationRepositoryFake();
      final result = await repo.delete('nope');
      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<NotFoundFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('getAllPaginated returns the requested slice with hasMore', () async {
      final repo = NotificationRepositoryFake.seeded(count: 25);
      final firstPage = await repo.getAllPaginated(
        const PaginationParams(offset: 0, limit: 10),
      );
      expect(firstPage.isRight(), isTrue);
      firstPage.fold((_) => fail('expected Right'), (page) {
        expect(page.items.length, 10);
        expect(page.total, 25);
        expect(page.hasMore, isTrue);
      });

      final lastPage = await repo.getAllPaginated(
        const PaginationParams(offset: 20, limit: 10),
      );
      lastPage.fold((_) => fail('expected Right'), (page) {
        expect(page.items.length, 5);
        expect(page.hasMore, isFalse);
      });
    });

    test('search filters by name and description', () async {
      final repo = NotificationRepositoryFake.seeded(count: 5);
      final result = await repo.search('Alpha');
      expect(result.isRight(), isTrue);
      expect(
        result.getOrElse(() => const []).every(
              (e) => (e.name ?? '').contains('Alpha'),
            ),
        isTrue,
      );
    });
  });

}
