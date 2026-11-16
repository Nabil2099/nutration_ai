import '../../data/models/suggested_food.dart';

class AddMealState {
  AddMealState({
    required this.mealType,
    required this.query,
    required Map<String, int> portions,
    List<SuggestedFood> customFoods = const [],
    this.filterByMealType = false,
    this.saving = false,
    this.errorMessage,
  }) : portions = Map.unmodifiable(portions),
       customFoods = List.unmodifiable(customFoods);

  static const mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];

  final String mealType;
  final String query;
  final Map<String, int> portions;
  final List<SuggestedFood> customFoods;
  final bool filterByMealType;
  final bool saving;
  final String? errorMessage;

  List<SuggestedFood> get allFoods => [
    ...customFoods,
    ...SuggestedFood.suggestions,
  ];

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

    // Prioritize custom foods and foods matching the selected mealType first.
    filtered.sort((a, b) {
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
