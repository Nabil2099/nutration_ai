import '../../../../core/data/models/user_profile.dart';
import '../../../../core/data/models/meal_entry.dart';
import '../../../../core/utils/day_key.dart';
import '../../../../core/utils/nutrition_math.dart';
import '../models/home_summary.dart';

class HomeMetricsCalculator {
  const HomeMetricsCalculator();
  HomeSummary build(
    UserProfile profile,
    List<MealEntry> meals,
    DateTime today,
  ) {
    final key = dayKey(today);
    final current = meals.where((m) => m.localDayKey == key);
    double sum(Iterable<MealEntry> entries, double Function(MealEntry) value) =>
        entries.fold(0.0, (total, meal) {
          final v = value(meal);
          return total + (v.isFinite && v >= 0 ? v : 0);
        });
    final consumed = sum(current, (m) => m.caloriesKcal);
    return HomeSummary(
      userName: profile.name,
      selectedDayKey: key,
      goals: profile.dailyGoals,
      consumedCalories: consumed,
      remainingCalories: profile.dailyGoals.calories - consumed,
      progressFraction: progress(consumed, profile.dailyGoals.calories),
      proteinConsumedG: sum(current, (m) => m.proteinG),
      carbsConsumedG: sum(current, (m) => m.carbsG),
      fatConsumedG: sum(current, (m) => m.fatG),
      sevenDayTotals: List.generate(7, (i) {
        final date = calendarDay(today, i - 6);
        final entries = meals.where((m) => m.localDayKey == dayKey(date));
        return DailyCalories(
          date,
          entries.isEmpty ? null : sum(entries, (m) => m.caloriesKcal),
        );
      }),
    );
  }
}
