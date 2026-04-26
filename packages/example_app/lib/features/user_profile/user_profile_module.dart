import 'package:flutter/material.dart';

import '../../core/routing/feature_registry.dart';
import 'presentation/pages/user_profile_list_page.dart';

/// Public surface for the UserProfile feature. Imported by the feature
/// registry; do not import from outside this module otherwise.
class UserProfileModule {
  static const FeatureDescriptor descriptor = FeatureDescriptor(
    id: 'user_profile',
    title: 'UserProfiles',
    routeName: '/user-profile',
    icon: Icons.list_alt,
    builder: _build,
  );

  static Widget _build(BuildContext context) => const UserProfileListPage();
}
