import '../../data/models/suggested_food.dart';

class AddMealState {
  AddMealState({
    required this.mealType,
    required this.query,
    required Map<String, int> portions,
    this.saving = false,
    this.errorMessage,
  }) : portions = Map.unmodifiable(portions);

  static const mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];

  final String mealType;
  final String query;
  final Map<String, int> portions;
  final bool saving;
  final String? errorMessage;

  List<SuggestedFood> get visibleFoods => SuggestedFood.suggestions
      .where(
        (food) =>
            food.name.toLowerCase().contains(query.toLowerCase()) ||
            food.subtitle.toLowerCase().contains(query.toLowerCase()),
      )
      .toList(growable: false);

  List<SuggestedFood> get selectedFoods => SuggestedFood.suggestions
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
