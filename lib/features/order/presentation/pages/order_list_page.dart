import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/shimmer_tile.dart';
import '../providers/order_providers.dart';
import '../widgets/order_item_tile.dart';
import '../widgets/order_form_dialog.dart';
import '../widgets/order_search_delegate.dart';

class OrderListPage extends ConsumerStatefulWidget {
  const OrderListPage({super.key});

  @override
  ConsumerState<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends ConsumerState<OrderListPage> {
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
      ref.read(orderListProvider.notifier).loadMore();
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
    final state = ref.watch(orderListProvider);
    final hasMore = ref.watch(orderHasMoreProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () => showSearch(
              context: context,
              delegate: OrderSearchDelegate(ref),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () =>
                ref.read(orderListProvider.notifier).refresh(),
          ),
        ],
      ),
      body: state.when(
        loading: () =>
            ShimmerTile.list(),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () =>
              ref.read(orderListProvider.notifier).refresh(),
        ),
        data: (items) => items.isEmpty
            ? const EmptyView(message: 'No Orders yet')
            : RefreshIndicator(
                onRefresh: () =>
                    ref.read(orderListProvider.notifier).refresh(),
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
                    return OrderItemTile(item: items[i]);
                  },
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Order',
        onPressed: () => OrderFormDialog.show(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
