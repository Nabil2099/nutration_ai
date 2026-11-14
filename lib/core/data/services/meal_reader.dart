import '../models/meal_entry.dart';

// Minimal read-only integration boundary; no production meal implementation.
// Inject the teammate MealService methods as tear-offs into App.mealReader.
typedef MealPeriodReader = Stream<List<MealEntry>> Function(
  String uid,
  String firstDayKey,
  String lastDayKey,
);
