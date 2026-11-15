import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class WeeklyBalanceCard extends StatelessWidget {
  const WeeklyBalanceCard({super.key, required this.weeklyAverage});

  final double weeklyAverage;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YOUR WEEKLY BALANCE',
            style: textTheme.labelMedium?.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            "You're building healthier habits.",
            style: textTheme.titleLarge?.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'Based on your last 7 days of food logs',
            style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Text(
            'Weekly Average',
            style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          Text(
            '${weeklyAverage.round()} kcal/day',
            style: textTheme.headlineSmall?.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}