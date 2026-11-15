import 'package:flutter/material.dart';

import '../../../../core/data/models/meal_entry.dart';
import '../../../../core/theme/app_colors.dart';

class MealHistoryCard extends StatelessWidget {
  const MealHistoryCard({super.key, required this.meal});

  final MealEntry meal;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.mealType.toUpperCase(),
                  style: textTheme.labelSmall?.copyWith(color: AppColors.primary),
                ),
                const SizedBox(height: 4),
                Text(
                  meal.name,
                  style: textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _MacroLabel(
                      color: AppColors.protein,
                      text: '${meal.proteinG.round()}g P',
                    ),
                    const SizedBox(width: 12),
                    _MacroLabel(
                      color: AppColors.carbs,
                      text: '${meal.carbsG.round()}g C',
                    ),
                    const SizedBox(width: 12),
                    _MacroLabel(
                      color: AppColors.fats,
                      text: '${meal.fatG.round()}g F',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${meal.caloriesKcal.round()}', style: textTheme.titleLarge),
              Text(
                'kcal',
                style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroLabel extends StatelessWidget {
  const _MacroLabel({required this.color, required this.text});

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(radius: 4, backgroundColor: color),
        const SizedBox(width: 4),
        Text(text, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
