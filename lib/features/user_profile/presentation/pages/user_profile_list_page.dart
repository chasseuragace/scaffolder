import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../providers/user_profile_providers.dart';
import '../widgets/user_profile_item_tile.dart';
import '../widgets/user_profile_form_dialog.dart';

class UserProfileListPage extends ConsumerStatefulWidget {
  const UserProfileListPage({super.key});

  @override
  ConsumerState<UserProfileListPage> createState() => _UserProfileListPageState();
}

class _UserProfileListPageState extends ConsumerState<UserProfileListPage> {

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userProfileListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('UserProfiles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () =>
                ref.read(userProfileListProvider.notifier).refresh(),
          ),
        ],
      ),
      body: state.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () =>
              ref.read(userProfileListProvider.notifier).refresh(),
        ),
        data: (items) => items.isEmpty
            ? const EmptyView(message: 'No UserProfiles yet')
            : RefreshIndicator(
                onRefresh: () =>
                    ref.read(userProfileListProvider.notifier).refresh(),
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    return UserProfileItemTile(item: items[i]);
                  },
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add UserProfile',
        onPressed: () => UserProfileFormDialog.show(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
