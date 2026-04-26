import 'package:flutter/material.dart';

import '../../core/routing/feature_registry.dart';
import 'presentation/pages/order_list_page.dart';

/// Public surface for the Order feature. Imported by the feature
/// registry; do not import from outside this module otherwise.
class OrderModule {
  static const FeatureDescriptor descriptor = FeatureDescriptor(
    id: 'order',
    title: 'Orders',
    routeName: '/order',
    icon: Icons.list_alt,
    builder: _build,
  );

  static Widget _build(BuildContext context) => const OrderListPage();
}
