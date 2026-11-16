import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/data/models/meal_entry.dart';
import '../../../../core/data/services/meal_reader.dart';
import '../../../../core/utils/day_key.dart';
import '../../data/services/analytics_service.dart';
import 'analytics_state.dart';

class AnalyticsCubit extends Cubit<AnalyticsState> {
  AnalyticsCubit(this.mealReader, {AnalyticsService? service})
    : _service = service ?? const AnalyticsService(),
      super(const AnalyticsInitial());

  final MealPeriodReader? mealReader;
  final AnalyticsService _service;
  StreamSubscription<List<MealEntry>>? _mealSub;
  List<MealEntry>? _meals;
  DateTime _selectedDay = DateTime.now();

  Future<void> start(String uid) async {
    emit(const AnalyticsLoading());
    await _mealSub?.cancel();

    final reader = mealReader;
    if (reader == null) {
      emit(const AnalyticsError(message: 'No meal data connected.'));
      return;
    }

    final today = DateTime.now();
    _selectedDay = today;
    _mealSub = reader(uid, dayKey(calendarDay(today, -6)), dayKey(today)).listen(
      (meals) {
        _meals = meals;
        _emitLoaded();
      },
      onError: (_) {
        _meals = null;
        emit(
          const AnalyticsError(
            message:
                'Could not load your meals. Check your connection and retry.',
          ),
        );
      },
    );
  }

  void selectDay(DateTime day) {
    _selectedDay = day;
    _emitLoaded();
  }

  void _emitLoaded() {
    final meals = _meals;
    if (meals == null) return;
    final selectedKey = dayKey(_selectedDay);
    emit(
      AnalyticsLoaded(
        meals: meals,
        selectedDay: _selectedDay,
        selectedDayMeals: meals
            .where((meal) => meal.localDayKey == selectedKey)
            .toList(),
        caloriesByDay: _service.caloriesByDay(meals),
        weeklyAverage: _service.weeklyAverageCalories(meals),
        macros: _service.macroAverages(meals),
      ),
    );
  }

  @override
  Future<void> close() async {
    await _mealSub?.cancel();
    return super.close();
  }
}
