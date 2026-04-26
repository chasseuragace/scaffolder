import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user_entity.dart';
import '../providers/user_providers.dart';
import 'user_form_dialog.dart';

class UserItemTile extends ConsumerWidget {
  const UserItemTile({super.key, required this.item});

  final UserEntity item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(item.name ?? '(unnamed)'),
      subtitle: item.description == null ? null : Text(item.description!),
      trailing: PopupMenuButton<_TileAction>(
        onSelected: (action) async {
          switch (action) {
            case _TileAction.edit:
              await UserFormDialog.show(context, existing: item);
            case _TileAction.delete:
              await ref
                  .read(userListProvider.notifier)
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
