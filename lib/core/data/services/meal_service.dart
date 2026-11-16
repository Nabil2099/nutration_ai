import 'package:cloud_firestore/cloud_firestore.dart';

import '../../utils/day_key.dart';
import '../models/meal_entry.dart';

/// Reads and writes user meal logs in `users/{uid}/meals` in Firestore.
class MealService {
  MealService(this.firestore);

  final FirebaseFirestore firestore;

  static const _validMealTypes = {'breakfast', 'lunch', 'dinner', 'snack'};

  CollectionReference<Map<String, dynamic>> _mealsRef(String uid) =>
      firestore.collection('users').doc(uid).collection('meals');

  /// Streams meals for [uid] whose `localDayKey` falls within
  /// `[firstDayKey, lastDayKey]` inclusive, ordered chronologically.
  Stream<List<MealEntry>> watchMeals(
    String uid,
    String firstDayKey,
    String lastDayKey,
  ) => _mealsRef(uid)
      .where('localDayKey', isGreaterThanOrEqualTo: firstDayKey)
      .where('localDayKey', isLessThanOrEqualTo: lastDayKey)
      .snapshots()
      .map((snapshot) {
        final entries = snapshot.docs.map((doc) {
          final data = doc.data();
          final consumed =
              (data['consumedAt'] as Timestamp?)?.toDate() ?? DateTime.now();
          return MealEntry(
            id: doc.id,
            name: data['name'] as String? ?? '',
            mealType: data['mealType'] as String? ?? 'snack',
            consumedAt: consumed,
            localDayKey: data['localDayKey'] as String? ?? dayKey(consumed),
            servingGrams: (data['servingGrams'] as num?)?.toDouble() ?? 0,
            caloriesKcal: (data['caloriesKcal'] as num?)?.toDouble() ?? 0,
            proteinG: (data['proteinG'] as num?)?.toDouble() ?? 0,
            carbsG: (data['carbsG'] as num?)?.toDouble() ?? 0,
            fatG: (data['fatG'] as num?)?.toDouble() ?? 0,
          );
        }).toList();
        entries.sort((a, b) => a.consumedAt.compareTo(b.consumedAt));
        return entries;
      });

  /// Persists a new meal document matching `firestore.rules` validation.
  Future<void> addMeal({
    required String uid,
    required String name,
    required String mealType,
    required double servingGrams,
    required double caloriesKcal,
    required double proteinG,
    required double carbsG,
    required double fatG,
    DateTime? consumedAt,
  }) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('Meal name cannot be empty.');
    }
    final safeName = trimmedName.length > 200
        ? trimmedName.substring(0, 200)
        : trimmedName;
    final normalizedType = mealType.trim().toLowerCase();
    if (!_validMealTypes.contains(normalizedType)) {
      throw ArgumentError('Invalid meal type: $mealType');
    }
    if (servingGrams <= 0 || servingGrams > 20000) {
      throw ArgumentError('Serving grams must be between 1 and 20000.');
    }
    if (caloriesKcal < 0 ||
        caloriesKcal > 50000 ||
        proteinG < 0 ||
        proteinG > 10000 ||
        carbsG < 0 ||
        carbsG > 10000 ||
        fatG < 0 ||
        fatG > 10000) {
      throw ArgumentError('Nutrition values are out of allowed bounds.');
    }

    final timestamp = consumedAt ?? DateTime.now();
    return _mealsRef(uid).add({
      'name': safeName,
      'mealType': normalizedType,
      'consumedAt': Timestamp.fromDate(timestamp),
      'localDayKey': dayKey(timestamp),
      'servingGrams': servingGrams,
      'caloriesKcal': caloriesKcal,
      'proteinG': proteinG,
      'carbsG': carbsG,
      'fatG': fatG,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Deletes a meal document by [mealId] for [uid].
  Future<void> deleteMeal({required String uid, required String mealId}) =>
      _mealsRef(uid).doc(mealId).delete();
}
