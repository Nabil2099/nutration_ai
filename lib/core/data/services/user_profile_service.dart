import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_profile.dart';
import '../models/nutrition_goals.dart';

class UserProfileService {
  UserProfileService(this.firestore);
  final FirebaseFirestore firestore;
  DocumentReference<Map<String, dynamic>> _ref(String uid) =>
      firestore.collection('users').doc(uid);
  Future<UserProfile> ensureProfile({
    required String uid,
    required String email,
    String? preferredName,
  }) async {
    final ref = _ref(uid);
    await firestore.runTransaction((tx) async {
      final snapshot = await tx.get(ref);
      if (!snapshot.exists) {
        tx.set(ref, {
          'uid': uid,
          'name': preferredName?.trim().isNotEmpty == true
              ? preferredName!.trim()
              : 'User',
          'email': email,
          'photoPath': null,
          'dailyGoals': NutritionGoals.defaults.toMap(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
    return UserProfile.fromMap((await ref.get()).data()!);
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
    if (name.trim().length < 2 || name.trim().length > 80) {
      throw ArgumentError('Name must be 2–80 characters');
    }
    return _ref(
      uid,
    ).update({'name': name.trim(), 'updatedAt': FieldValue.serverTimestamp()});
  }

  Future<void> saveRegisteredName(String uid, String name) =>
      updateName(uid, name);
}
