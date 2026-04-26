import 'package:flutter/material.dart';

import '../../core/routing/feature_registry.dart';
import 'presentation/pages/notification_list_page.dart';

/// Public surface for the Notification feature. Imported by the feature
/// registry; do not import from outside this module otherwise.
class NotificationModule {
  static const FeatureDescriptor descriptor = FeatureDescriptor(
    id: 'notification',
    title: 'Notifications',
    routeName: '/notification',
    icon: Icons.list_alt,
    builder: _build,
  );

  static Widget _build(BuildContext context) => const NotificationListPage();
}
