import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../../core/widgets/error_view.dart';
import '../providers/user_profile_providers.dart';
import '../widgets/user_profile_form_dialog.dart';

class UserProfileDetailsPage extends ConsumerWidget {
  const UserProfileDetailsPage({super.key, required this.id});

  final String id;

  static Route<void> route(String id) => MaterialPageRoute(
        builder: (_) => UserProfileDetailsPage(id: id),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(userProfileByIdProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('UserProfile details'),
        actions: [
          async.maybeWhen(
            data: (entity) => IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit',
              onPressed: () =>
                  UserProfileFormDialog.show(context, existing: entity),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
          async.maybeWhen(
            data: (entity) => IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete',
              onPressed: () async {
                final ok = await ConfirmationDialog.show(
                  context,
                  title: 'Delete UserProfile?',
                  message: 'This action cannot be undone.',
                  confirmLabel: 'Delete',
                  destructive: true,
                );
                if (!ok) return;
                await ref
                    .read(userProfileListProvider.notifier)
                    .remove(entity.id);
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(userProfileByIdProvider(id)),
        ),
        data: (entity) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _DetailRow(label: 'ID', value: entity.id),
            _DetailRow(label: 'Name', value: entity.name ?? '—'),
            _DetailRow(
              label: 'Description',
              value: entity.description ?? '—',
            ),
            _DetailRow(
              label: 'Created',
              value: entity.createdAt?.toIso8601String() ?? '—',
            ),
            _DetailRow(
              label: 'Updated',
              value: entity.updatedAt?.toIso8601String() ?? '—',
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 2),
          SelectableText(value),
        ],
      ),
    );
  }
}
