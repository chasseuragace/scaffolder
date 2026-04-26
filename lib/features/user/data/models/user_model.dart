import '../../domain/entities/user_entity.dart';

/// Data-layer model for User. Mirrors the on-the-wire shape and
/// provides toEntity / toJson conversions.
class UserModel {
  const UserModel({
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

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
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

  UserEntity toEntity() => UserEntity(
        id: id,
        name: name,
        description: description,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  factory UserModel.fromEntity(UserEntity e) => UserModel(
        id: e.id,
        name: e.name,
        description: e.description,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
      );

  static const List<String> _names = [
    'Sample User Alpha',
    'Test User Beta',
    'Demo User Gamma',
    'Mock User Delta',
    'Example User Epsilon',
  ];
  static const List<String> _descriptions = [
    'A first sample for User',
    'A second sample for User',
    'A third sample for User',
  ];

  /// Deterministic dummy. Pass [seed] for reproducible variety.
  factory UserModel.dummy({String? id, int seed = 0}) {
    final s = seed.abs();
    return UserModel(
      id: id ?? 'user_$s',
      name: _names[s % _names.length],
      description: _descriptions[s % _descriptions.length],
      createdAt: DateTime(2024, 1, 1).add(Duration(days: s % 365)),
      updatedAt: DateTime(2024, 1, 1).add(Duration(days: (s % 365) + 1)),
    );
  }

  static List<UserModel> dummyList(int count) =>
      List.generate(count, (i) => UserModel.dummy(seed: i));
}
