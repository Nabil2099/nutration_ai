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
  final String userName, selectedDayKey;
  final NutritionGoals goals;
  double get goalCalories => goals.calories;
  final double consumedCalories, remainingCalories, progressFraction;
  final double proteinConsumedG, carbsConsumedG, fatConsumedG;
  final List<DailyCalories> sevenDayTotals;
}
