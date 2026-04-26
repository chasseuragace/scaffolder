import 'package:flutter/material.dart';

import '../../core/routing/feature_registry.dart';
import 'presentation/pages/user_list_page.dart';

/// Public surface for the User feature. Imported by the feature
/// registry; do not import from outside this module otherwise.
class UserModule {
  static const FeatureDescriptor descriptor = FeatureDescriptor(
    id: 'user',
    title: 'Users',
    routeName: '/user',
    icon: Icons.list_alt,
    builder: _build,
  );

  static Widget _build(BuildContext context) => const UserListPage();
}
