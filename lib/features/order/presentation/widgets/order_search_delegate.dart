import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../providers/order_providers.dart';
import 'order_item_tile.dart';

class OrderSearchDelegate extends SearchDelegate<void> {
  OrderSearchDelegate(WidgetRef ref);

  @override
  List<Widget>? buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => query = '',
          ),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => _buildList();

  @override
  Widget buildSuggestions(BuildContext context) =>
      query.length < 2
          ? const EmptyView(message: 'Type at least 2 characters')
          : _buildList();

  Widget _buildList() {
    return Consumer(
      builder: (context, ref, _) {
        final async = ref.watch(orderSearchProvider(query));
        return async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ErrorView(message: e.toString()),
          data: (items) => items.isEmpty
              ? const EmptyView(message: 'No matches')
              : ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) =>
                      OrderItemTile(item: items[i]),
                ),
        );
      },
    );
  }
}
