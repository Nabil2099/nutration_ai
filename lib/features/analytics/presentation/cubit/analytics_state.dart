import '../../../../core/data/models/meal_entry.dart';
import '../../data/services/analytics_service.dart';

abstract class AnalyticsState {
  const AnalyticsState();
}

class AnalyticsInitial extends AnalyticsState {
  const AnalyticsInitial();
}

class AnalyticsLoading extends AnalyticsState {
  const AnalyticsLoading();
}

class AnalyticsLoaded extends AnalyticsState {
  const AnalyticsLoaded({
    required this.meals,
    required this.selectedDay,
    required this.selectedDayMeals,
    required this.caloriesByDay,
    required this.weeklyAverage,
    required this.macros,
  });
  final List<MealEntry> meals;
  final DateTime selectedDay;
  final List<MealEntry> selectedDayMeals;
  final Map<String, double> caloriesByDay;
  final double weeklyAverage;
  final MacroAverages macros;
}

class AnalyticsError extends AnalyticsState {
  const AnalyticsError({required this.message});
  final String message;
}