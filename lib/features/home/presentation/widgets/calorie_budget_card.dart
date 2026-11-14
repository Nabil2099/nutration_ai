import 'package:flutter/material.dart';

import '../../data/models/home_summary.dart';
import '../../../../core/theme/app_colors.dart';
import 'calorie_progress_ring.dart';

class CalorieBudgetCard extends StatelessWidget {
  const CalorieBudgetCard({
    super.key,
    required this.summary,
    required this.onLog,
  });
  final HomeSummary summary;
  final VoidCallback onLog;
  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Calorie Budget',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 20),
          Center(
            child: CalorieProgressRing(
              progress: summary.progressFraction,
              remaining: summary.remainingCalories,
              goal: summary.goalCalories,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 20,
              runSpacing: 12,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Consumed Food', style: TextStyle(fontSize: 12)),
                    Text(
                      '${summary.consumedCalories.round()} kcal',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Daily Goal', style: TextStyle(fontSize: 12)),
                    Text(
                      '${summary.goalCalories.round()} kcal',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onLog,
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Quick Log Meal'),
          ),
          if (summary.sevenDayTotals.last.calories == null)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text(
                'No meals logged today. Start with your first meal.',
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    ),
  );
}
