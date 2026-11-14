import 'package:flutter_test/flutter_test.dart';
import 'package:nutration_ai/core/data/models/meal_entry.dart';
import 'package:nutration_ai/core/data/models/nutrition_goals.dart';
import 'package:nutration_ai/core/utils/day_key.dart';
import 'package:nutration_ai/features/home/data/calculators/home_metrics_calculator.dart';

import 'support.dart';

MealEntry meal(double kcal, {String key = '2026-11-15'}) => MealEntry(
  id: '1',
  name: 'Lunch',
  mealType: 'lunch',
  consumedAt: DateTime(2026, 11, 15),
  localDayKey: key,
  servingGrams: 100,
  caloriesKcal: kcal,
  proteinG: 31,
  carbsG: 20,
  fatG: 5,
);
void main() {
  const calculator = HomeMetricsCalculator();
  final date = DateTime(2026, 11, 15);
  test(
    '1350 of 2000 leaves 650; macros and missing calendar days are correct',
    () {
      final summary = calculator.build(profile(), [
        meal(1350),
        meal(400, key: '2026-11-14'),
      ], date);
      expect(summary.remainingCalories, 650);
      expect(summary.progressFraction, .675);
      expect(summary.proteinConsumedG, 31);
      expect(summary.carbsConsumedG, 20);
      expect(summary.fatConsumedG, 5);
      expect(summary.sevenDayTotals.length, 7);
      expect(summary.sevenDayTotals.first.calories, null);
      expect(summary.sevenDayTotals[5].calories, 400);
    },
  );
  test('over goal caps ring and retains negative remaining', () {
    final summary = calculator.build(profile(), [meal(2500)], date);
    expect(summary.remainingCalories, -500);
    expect(summary.progressFraction, 1);
  });
  test('zero goal, empty and invalid inputs produce finite progress', () {
    final summary = calculator.build(
      profile(
        'a',
        const NutritionGoals(calories: 0, proteinG: 0, carbsG: 0, fatG: 0),
      ),
      [meal(double.nan)],
      date,
    );
    expect(summary.progressFraction, 0);
    expect(summary.consumedCalories, 0);
    expect(
      calculator
          .build(profile(), [], date)
          .sevenDayTotals
          .every((d) => d.calories == null),
      true,
    );
  });
  test('calendar keys cross year boundaries without UTC remapping', () {
    expect(dayKey(calendarDay(DateTime(2026, 1, 1), -1)), '2025-12-31');
  });
}
