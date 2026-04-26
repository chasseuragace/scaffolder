import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure_messages.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/shimmer_tile.dart';
import '../providers/product_providers.dart';
import '../widgets/product_item_tile.dart';
import '../widgets/product_form_dialog.dart';
import '../widgets/product_search_delegate.dart';

class ProductListPage extends ConsumerStatefulWidget {
  const ProductListPage({super.key});

  @override
  ConsumerState<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends ConsumerState<ProductListPage> {
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
      ref.read(productListProvider.notifier).loadMore();
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
    final state = ref.watch(productListProvider);
    final hasMore = ref.watch(productHasMoreProvider);

    // Mutation feedback: surface failed add/edit/remove as a SnackBar
    // without dropping the whole page into an error state.
    ref.listen<Object?>(productMutationErrorProvider, (_, error) {
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
      ref.read(productMutationErrorProvider.notifier).state = null;
    });

    ref.listen<String?>(productMutationSuccessProvider, (_, op) {
      if (op == null) return;
      final messenger = ScaffoldMessenger.maybeOf(context);
      final label = switch (op) {
        'add' => 'Product added',
        'edit' => 'Product updated',
        'remove' => 'Product removed',
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
      ref.read(productMutationSuccessProvider.notifier).state = null;
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () => showSearch(
              context: context,
              delegate: ProductSearchDelegate(ref),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () =>
                ref.read(productListProvider.notifier).refresh(),
          ),
        ],
      ),
      body: state.when(
        loading: () =>
            ShimmerTile.list(),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () =>
              ref.read(productListProvider.notifier).refresh(),
        ),
        data: (items) => items.isEmpty
            ? const EmptyView(message: 'No Products yet')
            : RefreshIndicator(
                onRefresh: () =>
                    ref.read(productListProvider.notifier).refresh(),
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
                    return ProductItemTile(item: items[i]);
                  },
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Product',
        onPressed: () => ProductFormDialog.show(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
