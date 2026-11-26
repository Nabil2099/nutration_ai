import '../../data/models/meal_analysis.dart';
import '../../data/models/suggested_food.dart';

class AddMealState {
  AddMealState({
    required this.mealType,
    required this.query,
    required Map<String, int> portions,
    List<SuggestedFood> customFoods = const [],
    this.filterByMealType = false,
    this.saving = false,
    this.analyzing = false,
    this.analysis,
    this.errorMessage,
  }) : portions = Map.unmodifiable(portions),
       customFoods = List.unmodifiable(customFoods),
       scannedFoods = List.unmodifiable(
         analysis?.toSuggestedFoods(mealType: mealType) ?? const [],
       );

  static const mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];

  final String mealType;
  final String query;
  final Map<String, int> portions;
  final List<SuggestedFood> customFoods;
  final bool filterByMealType;
  final bool saving;

  /// True while a meal photo is being analyzed by the AI.
  final bool analyzing;

  /// Result of the latest successful meal-photo analysis (null if none).
  final MealAnalysis? analysis;

  /// Foods derived from [analysis], pre-portioned to the estimated weights.
  /// Recomputed whenever the state is copied so meal-type filters stay fresh.
  final List<SuggestedFood> scannedFoods;

  final String? errorMessage;

  List<SuggestedFood> get allFoods {
    final scannedNames = {for (final food in scannedFoods) food.name};
    return [
      ...scannedFoods,
      ...customFoods.where((food) => !scannedNames.contains(food.name)),
      ...SuggestedFood.suggestions.where(
        (food) => !scannedNames.contains(food.name),
      ),
    ];
  }

  List<SuggestedFood> get visibleFoods {
    final lowerQuery = query.toLowerCase();
    final filtered = allFoods.where((food) {
      final matchesQuery =
          lowerQuery.isEmpty ||
          food.name.toLowerCase().contains(lowerQuery) ||
          food.subtitle.toLowerCase().contains(lowerQuery);
      if (!matchesQuery) return false;
      if (filterByMealType) {
        return food.mealTypes.contains(mealType) || customFoods.contains(food);
      }
      return true;
    }).toList();

    // Prioritize scanned foods, then customs, then foods matching mealType.
    filtered.sort((a, b) {
      final aScan = scannedFoods.contains(a) ? 0 : 1;
      final bScan = scannedFoods.contains(b) ? 0 : 1;
      if (aScan != bScan) return aScan.compareTo(bScan);
      final aCustom = customFoods.contains(a) ? 0 : 1;
      final bCustom = customFoods.contains(b) ? 0 : 1;
      if (aCustom != bCustom) return aCustom.compareTo(bCustom);
      final aMatch = a.mealTypes.contains(mealType) ? 0 : 1;
      final bMatch = b.mealTypes.contains(mealType) ? 0 : 1;
      return aMatch.compareTo(bMatch);
    });
    return List.unmodifiable(filtered);
  }

  List<SuggestedFood> get selectedFoods => allFoods
      .where((food) => portions.containsKey(food.name))
      .toList(growable: false);

  double totalFor(double Function(SuggestedFood food) value) =>
      selectedFoods.fold<double>(
        0,
        (sum, food) => sum + value(food) * (portions[food.name]! / 100),
      );

  double get calories => totalFor((food) => food.caloriesPer100g);
  double get protein => totalFor((food) => food.proteinPer100g);
  double get carbs => totalFor((food) => food.carbsPer100g);
  double get fat => totalFor((food) => food.fatPer100g);
}
