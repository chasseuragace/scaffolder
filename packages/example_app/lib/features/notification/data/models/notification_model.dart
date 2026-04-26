import '../../domain/entities/notification_entity.dart';

/// Data-layer model for Notification. Mirrors the on-the-wire shape and
/// provides toEntity / toJson conversions.
class NotificationModel {
  const NotificationModel({
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

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
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

  NotificationEntity toEntity() => NotificationEntity(
        id: id,
        name: name,
        description: description,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  factory NotificationModel.fromEntity(NotificationEntity e) => NotificationModel(
        id: e.id,
        name: e.name,
        description: e.description,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
      );

  static const List<String> _names = [
    'Sample Notification Alpha',
    'Test Notification Beta',
    'Demo Notification Gamma',
    'Mock Notification Delta',
    'Example Notification Epsilon',
    'Premium Notification Zeta',
    'Advanced Notification Eta',
    'Professional Notification Theta',
    'Enterprise Notification Iota',
    'Ultimate Notification Kappa',
  ];
  static const List<String> _descriptions = [
    'A first sample for Notification with realistic content',
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
  factory NotificationModel.dummy({String? id, int seed = 0}) {
    final s = seed.abs();
    final category = _categories[s % _categories.length];
    return NotificationModel(
      id: id ?? 'notification_$s',
      name: _names[s % _names.length],
      description: '${_descriptions[s % _descriptions.length]} [$category]',
      createdAt: DateTime(2024, 1, 1).add(Duration(days: s % 365)),
      updatedAt: DateTime(2024, 1, 1).add(Duration(days: (s % 365) + 1)),
    );
  }

  static List<NotificationModel> dummyList(int count) =>
      List.generate(count, (i) => NotificationModel.dummy(seed: i));
}
