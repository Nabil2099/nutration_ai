import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_profile.dart';
import '../models/nutrition_goals.dart';

class UserProfileService {
  UserProfileService(this.firestore);

  final FirebaseFirestore firestore;

  DocumentReference<Map<String, dynamic>> _ref(String uid) =>
      firestore.collection('users').doc(uid);

  String _normalizeInitialName(String? preferredName) {
    final trimmed = preferredName?.trim() ?? '';
    if (trimmed.length < 2) {
      return 'User';
    }
    return trimmed.length > 80 ? trimmed.substring(0, 80) : trimmed;
  }

  Future<UserProfile> ensureProfile({
    required String uid,
    required String email,
    String? preferredName,
  }) async {
    final ref = _ref(uid);
    final initialName = _normalizeInitialName(preferredName);

    await firestore.runTransaction((tx) async {
      final snapshot = await tx.get(ref);
      if (!snapshot.exists) {
        tx.set(ref, {
          'uid': uid,
          'name': initialName,
          'email': email,
          'photoPath': null,
          'dailyGoals': NutritionGoals.defaults.toMap(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });

    final snapshot = await ref.get();
    final data = snapshot.data();
    if (data == null) {
      throw const FormatException('Profile unavailable');
    }
    return UserProfile.fromMap(data);
  }

  Stream<UserProfile> watchProfile(String uid) =>
      _ref(uid).snapshots().map((doc) {
        if (!doc.exists) {
          throw const FormatException('Profile unavailable');
        }
        return UserProfile.fromMap(doc.data()!);
      });

  Future<void> updateGoals(String uid, NutritionGoals goals) {
    if (!goals.isValid) {
      throw ArgumentError('Invalid nutrition goals');
    }
    return _ref(uid).update({
      'dailyGoals': goals.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateName(String uid, String name) {
    final trimmed = name.trim();
    if (trimmed.length < 2 || trimmed.length > 80) {
      throw ArgumentError('Name must be 2–80 characters');
    }
    return _ref(uid)
        .update({'name': trimmed, 'updatedAt': FieldValue.serverTimestamp()});
  }

  Future<void> saveRegisteredName(String uid, String name) =>
      updateName(uid, name);
}
