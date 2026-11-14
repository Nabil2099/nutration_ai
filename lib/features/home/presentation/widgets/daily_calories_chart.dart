import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/home_summary.dart';

class DailyCaloriesChart extends StatelessWidget {
  const DailyCaloriesChart({super.key, required this.days, required this.goal});
  final List<DailyCalories> days;
  final double goal;
  @override
  Widget build(BuildContext context) {
    final max = days.fold<double>(
      goal > 0 ? goal : 1,
      (value, day) => math.max(value, day.calories ?? 0),
    );
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Calories',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            const Text(
              'Last 7 calendar days • today is partial',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 160,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final day in days)
                    Expanded(
                      child: Semantics(
                        label:
                            '${DateFormat.MMMd().format(day.day)}: ${day.calories == null ? 'not logged' : '${day.calories!.round()} kcal logged'}',
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              day.calories == null
                                  ? '—'
                                  : '${day.calories!.round()}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: 16,
                              height: day.calories == null
                                  ? 3
                                  : math.max(3, 100 * day.calories! / max),
                              decoration: BoxDecoration(
                                color: day.calories == null
                                    ? AppColors.border
                                    : AppColors.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              DateFormat.E().format(day.day).substring(0, 1),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '— Not logged. Bars show logged intake only.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
