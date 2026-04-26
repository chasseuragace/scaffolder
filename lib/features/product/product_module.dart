import 'package:flutter/material.dart';

import '../../core/routing/feature_registry.dart';
import 'presentation/pages/product_list_page.dart';

/// Public surface for the Product feature. Imported by the feature
/// registry; do not import from outside this module otherwise.
class ProductModule {
  static const FeatureDescriptor descriptor = FeatureDescriptor(
    id: 'product',
    title: 'Products',
    routeName: '/product',
    icon: Icons.list_alt,
    builder: _build,
  );

  static Widget _build(BuildContext context) => const ProductListPage();
}
