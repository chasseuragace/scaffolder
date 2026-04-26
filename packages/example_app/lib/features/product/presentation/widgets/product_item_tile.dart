import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/confirmation_dialog.dart';
import '../../domain/entities/product_entity.dart';
import '../pages/product_details_page.dart';
import '../providers/product_providers.dart';
import 'product_form_dialog.dart';

class ProductItemTile extends ConsumerWidget {
  const ProductItemTile({super.key, required this.item});

  final ProductEntity item;

  String get _initial {
    final n = item.name;
    if (n == null || n.isEmpty) return '?';
    return n.characters.first.toUpperCase();
  }

  String _formatDate(DateTime d) =>
      '${d.year.toString().padLeft(4, "0")}-${d.month.toString().padLeft(2, "0")}-${d.day.toString().padLeft(2, "0")}';

  Future<void> _handleDelete(BuildContext context, WidgetRef ref) async {
    final ok = await ConfirmationDialog.show(
      context,
      title: 'Delete Product?',
      message: 'This action cannot be undone.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!ok) return;
    await ref.read(productListProvider.notifier).remove(item.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        onTap: () => Navigator.of(context).push(ProductDetailsPage.route(item.id)),
        leading: CircleAvatar(child: Text(_initial)),
        title: Text(
          item.name ?? '(unnamed)',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.description != null && item.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2, bottom: 4),
                child: Text(
                  item.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            Text(
              [
                'id: ${item.id}',
                if (item.createdAt != null) 'created ${_formatDate(item.createdAt!)}',
              ].join(' · '),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.outline,
                  ),
            ),
          ],
        ),
        trailing: PopupMenuButton<_TileAction>(
          onSelected: (action) async {
            switch (action) {
              case _TileAction.edit:
                await ProductFormDialog.show(context, existing: item);
              case _TileAction.delete:
                await _handleDelete(context, ref);
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: _TileAction.edit,
              child: ListTile(
                leading: Icon(Icons.edit_outlined),
                title: Text('Edit'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: _TileAction.delete,
              child: ListTile(
                leading: Icon(Icons.delete_outline, color: scheme.error),
                title: Text('Delete', style: TextStyle(color: scheme.error)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _TileAction {
  edit,
  delete,
}
