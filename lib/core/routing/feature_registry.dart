import 'package:flutter/material.dart';

// GENERATED:imports BEGIN
import 'package:flutter_project/features/order/order_module.dart';
import 'package:flutter_project/features/user/user_module.dart';
import 'package:flutter_project/features/user_profile/user_profile_module.dart';
// GENERATED:imports END

/// Describes a feature that can be linked from the app shell.
///
/// Generated features expose a `static const FeatureDescriptor descriptor`
/// from their module file and the generator inserts them into
/// [FeatureRegistry.all] within the markers below.
class FeatureDescriptor {
  const FeatureDescriptor({
    required this.id,
    required this.title,
    required this.routeName,
    required this.icon,
    required this.builder,
  });

  final String id;
  final String title;
  final String routeName;
  final IconData icon;
  final WidgetBuilder builder;
}

class FeatureRegistry {
  static const List<FeatureDescriptor> all = <FeatureDescriptor>[
    // GENERATED:entries BEGIN
    OrderModule.descriptor,
    UserModule.descriptor,
    UserProfileModule.descriptor,
    // GENERATED:entries END
  ];

  static Map<String, WidgetBuilder> routes() {
    return {for (final f in all) f.routeName: f.builder};
  }
}
