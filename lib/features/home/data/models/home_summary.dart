import '../../../../core/data/models/nutrition_goals.dart';

class DailyCalories {
  const DailyCalories(this.day, this.calories);
  final DateTime day;
  final double? calories;
}

class HomeSummary {
  HomeSummary({
    required this.userName,
    required this.selectedDayKey,
    required this.goals,
    required this.consumedCalories,
    required this.remainingCalories,
    required this.progressFraction,
    required this.proteinConsumedG,
    required this.carbsConsumedG,
    required this.fatConsumedG,
    required List<DailyCalories> sevenDayTotals,
  }) : sevenDayTotals = List.unmodifiable(sevenDayTotals);
  final String userName;
  final String selectedDayKey;
  final NutritionGoals goals;

  double get goalCalories => goals.calories;
  bool get hasLoggedMealsToday =>
      sevenDayTotals.isNotEmpty && sevenDayTotals.last.calories != null;

  final double consumedCalories;
  final double remainingCalories;
  final double progressFraction;
  final double proteinConsumedG;
  final double carbsConsumedG;
  final double fatConsumedG;
  final List<DailyCalories> sevenDayTotals;
}
