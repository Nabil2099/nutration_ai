import '../../../../core/data/models/meal_entry.dart';

class MacroAverages {
  const MacroAverages({
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });

  final double proteinG;
  final double carbsG;
  final double fatG;

  double get proteinKcal => proteinG * 4;
  double get carbsKcal => carbsG * 4;
  double get fatKcal => fatG * 9;
  double get totalKcal => proteinKcal + carbsKcal + fatKcal;

  double get proteinPercent => totalKcal == 0 ? 0 : proteinKcal / totalKcal;
  double get carbsPercent => totalKcal == 0 ? 0 : carbsKcal / totalKcal;
  double get fatPercent => totalKcal == 0 ? 0 : fatKcal / totalKcal;
}

class AnalyticsService {
  const AnalyticsService();

  Map<String, double> caloriesByDay(List<MealEntry> meals) {
    final totals = <String, double>{};
    for (final meal in meals) {
      totals.update(
        meal.localDayKey,
        (value) => value + meal.caloriesKcal,
        ifAbsent: () => meal.caloriesKcal,
      );
    }
    return totals;
  }

  double weeklyAverageCalories(List<MealEntry> meals) {
    final total = meals.fold<double>(0, (sum, meal) => sum + meal.caloriesKcal);
    return total / 7;
  }

  MacroAverages macroAverages(List<MealEntry> meals) {
    var protein = 0.0;
    var carbs = 0.0;
    var fat = 0.0;
    for (final meal in meals) {
      protein += meal.proteinG;
      carbs += meal.carbsG;
      fat += meal.fatG;
    }
    return MacroAverages(
      proteinG: protein / 7,
      carbsG: carbs / 7,
      fatG: fat / 7,
    );
  }
}
