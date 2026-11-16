import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/data/services/meal_reader.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/analytics_cubit.dart';
import '../cubit/analytics_state.dart';
import '../widgets/calorie_intake_chart.dart';
import '../widgets/date_strip.dart';
import '../widgets/macro_distribution_card.dart';
import '../widgets/meal_history_card.dart';
import '../widgets/today_nutrition_card.dart';
import '../widgets/weekly_balance_card.dart';
import '../widgets/weekly_insight_card.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key, this.mealReader, this.uid});

  final MealPeriodReader? mealReader;
  final String? uid;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AnalyticsCubit(mealReader)..start(uid ?? ''),
      child: const _AnalyticsBody(),
    );
  }
}

class _AnalyticsBody extends StatefulWidget {
  const _AnalyticsBody();

  @override
  State<_AnalyticsBody> createState() => _AnalyticsBodyState();
}

class _AnalyticsBodyState extends State<_AnalyticsBody> {
  bool _showMealHistory = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnalyticsCubit, AnalyticsState>(
      builder: (context, state) {
        return switch (state) {
          AnalyticsLoaded loaded => _loadedView(context, loaded),
          AnalyticsError(:final message) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(message, textAlign: TextAlign.center),
            ),
          ),
          _ => const Center(child: CircularProgressIndicator()),
        };
      },
    );
  }

  Widget _loadedView(BuildContext context, AnalyticsLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _TabSwitch(
            showMealHistory: _showMealHistory,
            onChanged: (value) => setState(() => _showMealHistory = value),
          ),
          const SizedBox(height: 16),
          if (_showMealHistory)
            ..._mealHistory(context, state)
          else
            ..._trends(state),
        ],
      ),
    );
  }

  List<Widget> _trends(AnalyticsLoaded state) => [
    WeeklyBalanceCard(weeklyAverage: state.weeklyAverage),
    const SizedBox(height: 16),
    CalorieIntakeChart(
      caloriesByDay: state.caloriesByDay,
      today: DateTime.now(),
    ),
    const SizedBox(height: 16),
    MacroDistributionCard(macros: state.macros),
    const SizedBox(height: 16),
    const WeeklyInsightCard(
      message: 'Your insight will appear here once AI Coach is connected.',
    ),
  ];

  List<Widget> _mealHistory(BuildContext context, AnalyticsLoaded state) {
    final consumed = state.selectedDayMeals.fold<double>(
      0,
      (sum, meal) => sum + meal.caloriesKcal,
    );
    return [
      DateStrip(
        today: DateTime.now(),
        selectedDay: state.selectedDay,
        onSelected: (day) => context.read<AnalyticsCubit>().selectDay(day),
      ),
      const SizedBox(height: 16),
      TodayNutritionCard(consumedKcal: consumed),
      const SizedBox(height: 16),
      if (state.selectedDayMeals.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(
            'No meals logged for this day.',
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: AppColors.textSecondary),
          ),
        )
      else
        for (final meal in state.selectedDayMeals) ...[
          MealHistoryCard(meal: meal),
          const SizedBox(height: 12),
        ],
    ];
  }
}

class _TabSwitch extends StatelessWidget {
  const _TabSwitch({required this.showMealHistory, required this.onChanged});

  final bool showMealHistory;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _TabButton(
            label: 'Nutrition Trends',
            selected: !showMealHistory,
            onTap: () => onChanged(false),
          ),
          _TabButton(
            label: 'Meal History',
            selected: showMealHistory,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: selected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
