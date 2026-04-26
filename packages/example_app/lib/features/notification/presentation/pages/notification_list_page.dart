import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure_messages.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/shimmer_tile.dart';
import '../providers/notification_providers.dart';
import '../widgets/notification_item_tile.dart';
import '../widgets/notification_form_dialog.dart';
import '../widgets/notification_search_delegate.dart';

class NotificationListPage extends ConsumerStatefulWidget {
  const NotificationListPage({super.key});

  @override
  ConsumerState<NotificationListPage> createState() => _NotificationListPageState();
}

class _NotificationListPageState extends ConsumerState<NotificationListPage> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_maybeLoadMore);
  }

  void _maybeLoadMore() {
    if (!_scroll.hasClients) return;
    final pos = _scroll.position;
    if (pos.pixels > pos.maxScrollExtent - 200) {
      ref.read(notificationListProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scroll.removeListener(_maybeLoadMore);
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationListProvider);
    final hasMore = ref.watch(notificationHasMoreProvider);

    // Mutation feedback: surface failed add/edit/remove as a SnackBar
    // without dropping the whole page into an error state.
    ref.listen<Object?>(notificationMutationErrorProvider, (_, error) {
      if (error == null) return;
      final messenger = ScaffoldMessenger.maybeOf(context);
      messenger
        ?..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(failureToMessage(error)),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Dismiss',
              onPressed: () => messenger.hideCurrentSnackBar(),
            ),
          ),
        );
      ref.read(notificationMutationErrorProvider.notifier).state = null;
    });

    ref.listen<String?>(notificationMutationSuccessProvider, (_, op) {
      if (op == null) return;
      final messenger = ScaffoldMessenger.maybeOf(context);
      final label = switch (op) {
        'add' => 'Notification added',
        'edit' => 'Notification updated',
        'remove' => 'Notification removed',
        _ => 'Done',
      };
      messenger
        ?..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(label),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(milliseconds: 1500),
          ),
        );
      ref.read(notificationMutationSuccessProvider.notifier).state = null;
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () => showSearch(
              context: context,
              delegate: NotificationSearchDelegate(ref),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () =>
                ref.read(notificationListProvider.notifier).refresh(),
          ),
        ],
      ),
      body: state.when(
        loading: () =>
            ShimmerTile.list(),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () =>
              ref.read(notificationListProvider.notifier).refresh(),
        ),
        data: (items) => items.isEmpty
            ? const EmptyView(message: 'No Notifications yet')
            : RefreshIndicator(
                onRefresh: () =>
                    ref.read(notificationListProvider.notifier).refresh(),
                child: ListView.separated(
                  controller: _scroll,
                  itemCount: items.length + (hasMore ? 1 : 0),
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    if (i >= items.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    return NotificationItemTile(item: items[i]);
                  },
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Notification',
        onPressed: () => NotificationFormDialog.show(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
