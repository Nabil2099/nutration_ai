import 'suggested_food.dart';

/// One food component detected in a meal photo by the AI scanner.
///
/// Nutrition values are absolute totals for [grams] of that item.
class AnalyzedMealItem {
  const AnalyzedMealItem({
    required this.name,
    required this.grams,
    required this.caloriesKcal,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    this.emoji = '🍽️',
  });

  final String name;
  final double grams;
  final double caloriesKcal;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final String emoji;

  /// Scales [value] (a total for [grams]) to the per-100 g basis used by
  /// [SuggestedFood]. Returns 0 when the weight is not usable.
  double per100(double value) => grams <= 0 ? 0 : value * 100 / grams;

  double get caloriesPer100g => per100(caloriesKcal);
  double get proteinPer100g => per100(proteinG);
  double get carbsPer100g => per100(carbsG);
  double get fatPer100g => per100(fatG);
}

/// Result of an AI meal-photo analysis: a title plus every detected item.
class MealAnalysis {
  const MealAnalysis({required this.title, required this.items});

  final String title;
  final List<AnalyzedMealItem> items;

  double get totalCaloriesKcal =>
      items.fold<double>(0, (sum, item) => sum + item.caloriesKcal);
  double get totalProteinG =>
      items.fold<double>(0, (sum, item) => sum + item.proteinG);
  double get totalCarbsG =>
      items.fold<double>(0, (sum, item) => sum + item.carbsG);
  double get totalFatG =>
      items.fold<double>(0, (sum, item) => sum + item.fatG);

  /// Converts the analysis into selectable foods pre-portioned to the
  /// estimated weights, so they slot straight into the Add Meal flow.
  List<SuggestedFood> toSuggestedFoods({required String mealType}) => [
    for (final item in items)
      SuggestedFood(
        name: item.name,
        subtitle: 'AI scan · ~${item.grams.round()} g',
        caloriesPer100g: item.caloriesPer100g,
        proteinPer100g: item.proteinPer100g,
        carbsPer100g: item.carbsPer100g,
        fatPer100g: item.fatPer100g,
        emoji: item.emoji,
        mealTypes: {mealType},
      ),
  ];
}
