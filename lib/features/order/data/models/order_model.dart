import '../../domain/entities/order_entity.dart';

/// Data-layer model for Order. Mirrors the on-the-wire shape and
/// provides toEntity / toJson conversions.
class OrderModel {
  const OrderModel({
    required this.id,
    this.name,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String? name;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      name: json['name'] as String?,
      description: json['description'] as String?,
      createdAt: json['created_at'] is String
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] is String
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  OrderEntity toEntity() => OrderEntity(
        id: id,
        name: name,
        description: description,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  factory OrderModel.fromEntity(OrderEntity e) => OrderModel(
        id: e.id,
        name: e.name,
        description: e.description,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
      );

  static const List<String> _names = [
    'Sample Order Alpha',
    'Test Order Beta',
    'Demo Order Gamma',
    'Mock Order Delta',
    'Example Order Epsilon',
    'Premium Order Zeta',
    'Advanced Order Eta',
    'Professional Order Theta',
    'Enterprise Order Iota',
    'Ultimate Order Kappa',
  ];
  static const List<String> _descriptions = [
    'A first sample for Order with realistic content',
    'A second sample showcasing varied properties',
    'A third sample demonstrating typical usage',
    'A fourth sample with extended detail and context',
    'A fifth sample exercising the longer-form layout',
  ];
  static const List<String> _categories = [
    'work',
    'personal',
    'archived',
    'pinned',
    'draft',
  ];

  /// Deterministic dummy. Pass [seed] for reproducible variety. The
  /// description includes a category tag so the variety surfaces in
  /// list rendering.
  factory OrderModel.dummy({String? id, int seed = 0}) {
    final s = seed.abs();
    final category = _categories[s % _categories.length];
    return OrderModel(
      id: id ?? 'order_$s',
      name: _names[s % _names.length],
      description: '${_descriptions[s % _descriptions.length]} [$category]',
      createdAt: DateTime(2024, 1, 1).add(Duration(days: s % 365)),
      updatedAt: DateTime(2024, 1, 1).add(Duration(days: (s % 365) + 1)),
    );
  }

  static List<OrderModel> dummyList(int count) =>
      List.generate(count, (i) => OrderModel.dummy(seed: i));
}
