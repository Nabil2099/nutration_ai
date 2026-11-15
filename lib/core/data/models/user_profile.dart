import 'package:cloud_firestore/cloud_firestore.dart';

import 'nutrition_goals.dart';

class UserProfile {
  const UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.dailyGoals,
    this.photoPath,
    this.createdAt,
    this.updatedAt,
  });
  final String uid;
  final String name;
  final String email;
  final String? photoPath;
  final NutritionGoals dailyGoals;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserProfile copyWith({
    String? name,
    NutritionGoals? dailyGoals,
    String? photoPath,
  }) => UserProfile(
    uid: uid,
    name: name ?? this.name,
    email: email,
    dailyGoals: dailyGoals ?? this.dailyGoals,
    photoPath: photoPath ?? this.photoPath,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    for (final key in ['uid', 'name', 'email']) {
      if (map[key] is! String) {
        throw FormatException('Missing profile $key');
      }
    }
    if (map['dailyGoals'] is! Map) {
      throw const FormatException('Missing dailyGoals');
    }
    return UserProfile(
      uid: map['uid'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      dailyGoals: NutritionGoals.fromMap(
        Map<String, dynamic>.from(map['dailyGoals'] as Map),
      ),
      photoPath: map['photoPath'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}
