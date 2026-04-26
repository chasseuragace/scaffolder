import '../../domain/entities/product_entity.dart';

/// Data-layer model for Product. Mirrors the on-the-wire shape and
/// provides toEntity / toJson conversions.
class ProductModel {
  const ProductModel({
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

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
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

  ProductEntity toEntity() => ProductEntity(
        id: id,
        name: name,
        description: description,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  factory ProductModel.fromEntity(ProductEntity e) => ProductModel(
        id: e.id,
        name: e.name,
        description: e.description,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
      );

  static const List<String> _names = [
    'Sample Product Alpha',
    'Test Product Beta',
    'Demo Product Gamma',
    'Mock Product Delta',
    'Example Product Epsilon',
    'Premium Product Zeta',
    'Advanced Product Eta',
    'Professional Product Theta',
    'Enterprise Product Iota',
    'Ultimate Product Kappa',
  ];
  static const List<String> _descriptions = [
    'A first sample for Product with realistic content',
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
  factory ProductModel.dummy({String? id, int seed = 0}) {
    final s = seed.abs();
    final category = _categories[s % _categories.length];
    return ProductModel(
      id: id ?? 'product_$s',
      name: _names[s % _names.length],
      description: '${_descriptions[s % _descriptions.length]} [$category]',
      createdAt: DateTime(2024, 1, 1).add(Duration(days: s % 365)),
      updatedAt: DateTime(2024, 1, 1).add(Duration(days: (s % 365) + 1)),
    );
  }

  static List<ProductModel> dummyList(int count) =>
      List.generate(count, (i) => ProductModel.dummy(seed: i));
}
