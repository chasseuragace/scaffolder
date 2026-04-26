import '../../domain/entities/user_profile_entity.dart';

/// Data-layer model for UserProfile. Mirrors the on-the-wire shape and
/// provides toEntity / toJson conversions.
class UserProfileModel {
  const UserProfileModel({
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

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
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

  UserProfileEntity toEntity() => UserProfileEntity(
        id: id,
        name: name,
        description: description,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  factory UserProfileModel.fromEntity(UserProfileEntity e) => UserProfileModel(
        id: e.id,
        name: e.name,
        description: e.description,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
      );

  static const List<String> _names = [
    'Sample UserProfile Alpha',
    'Test UserProfile Beta',
    'Demo UserProfile Gamma',
    'Mock UserProfile Delta',
    'Example UserProfile Epsilon',
  ];
  static const List<String> _descriptions = [
    'A first sample for UserProfile',
    'A second sample for UserProfile',
    'A third sample for UserProfile',
  ];

  /// Deterministic dummy. Pass [seed] for reproducible variety.
  factory UserProfileModel.dummy({String? id, int seed = 0}) {
    final s = seed.abs();
    return UserProfileModel(
      id: id ?? 'user_profile_$s',
      name: _names[s % _names.length],
      description: _descriptions[s % _descriptions.length],
      createdAt: DateTime(2024, 1, 1).add(Duration(days: s % 365)),
      updatedAt: DateTime(2024, 1, 1).add(Duration(days: (s % 365) + 1)),
    );
  }

  static List<UserProfileModel> dummyList(int count) =>
      List.generate(count, (i) => UserProfileModel.dummy(seed: i));
}
