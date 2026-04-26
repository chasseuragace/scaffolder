import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/order_entity.dart';
import '../providers/order_providers.dart';
import 'order_form_dialog.dart';

class OrderItemTile extends ConsumerWidget {
  const OrderItemTile({super.key, required this.item});

  final OrderEntity item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(item.name ?? '(unnamed)'),
      subtitle: item.description == null ? null : Text(item.description!),
      trailing: PopupMenuButton<_TileAction>(
        onSelected: (action) async {
          switch (action) {
            case _TileAction.edit:
              await OrderFormDialog.show(context, existing: item);
            case _TileAction.delete:
              await ref
                  .read(orderListProvider.notifier)
                  .remove(item.id);
          }
        },
        itemBuilder: (_) => const [
          PopupMenuItem(value: _TileAction.edit, child: Text('Edit')),
          PopupMenuItem(value: _TileAction.delete, child: Text('Delete')),
        ],
      ),
    );
  }
}

enum _TileAction {
  edit,
  delete,
}
