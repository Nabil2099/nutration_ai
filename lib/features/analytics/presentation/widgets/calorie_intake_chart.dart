import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/day_key.dart';

class CalorieIntakeChart extends StatelessWidget {
  const CalorieIntakeChart({
    super.key,
    required this.caloriesByDay,
    required this.today,
    this.goal = 2000,
  });

  final Map<String, double> caloriesByDay;
  final DateTime today;
  final double goal;

  static const _barHeight = 160.0;
  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final days = List.generate(7, (i) => calendarDay(today, i - 6));
    final values = [for (final day in days) caloriesByDay[dayKey(day)] ?? 0];
    final maxValue = values.fold<double>(goal, (m, v) => v > m ? v : m);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Calorie Intake', style: textTheme.titleMedium),
              ),
              Text(
                'Goal: ${goal.round()}',
                style: textTheme.labelMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Your daily calories this week',
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: _Bar(
                    value: values[i],
                    maxValue: maxValue,
                    goal: goal,
                    label: _weekdays[days[i].weekday - 1],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.value,
    required this.maxValue,
    required this.goal,
    required this.label,
  });

  final double value;
  final double maxValue;
  final double goal;
  final String label;

  @override
  Widget build(BuildContext context) {
    final fraction = maxValue == 0 ? 0.0 : value / maxValue;
    final isAboveGoal = value > goal;
    return Column(
      children: [
        SizedBox(
          height: CalorieIntakeChart._barHeight,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: fraction,
              child: Container(
                decoration: BoxDecoration(
                  color: isAboveGoal ? AppColors.carbs : AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
