import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class TodayNutritionCard extends StatelessWidget {
  const TodayNutritionCard({
    super.key,
    required this.consumedKcal,
    this.goalKcal = 2000,
  });

  final double consumedKcal;
  final double goalKcal;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final remaining = (goalKcal - consumedKcal).clamp(0.0, goalKcal).round();
    final progress = goalKcal == 0
        ? 0.0
        : (consumedKcal / goalKcal).clamp(0.0, 1.0);
    final percent = (progress * 100).round();

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
          Text(
            "TODAY'S NUTRITION",
            style: textTheme.labelMedium?.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            '${consumedKcal.round()} kcal',
            style: textTheme.headlineSmall?.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            'of ${goalKcal.round()} kcal target consumed',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.surfaceVariant,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  '$remaining kcal remaining',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
              Text(
                '$percent% of daily goal',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
