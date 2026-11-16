import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'meal_info_pill.dart';

class AddMealSummaryBar extends StatelessWidget {
  const AddMealSummaryBar({
    super.key,
    required this.mealType,
    required this.foodCount,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  final String mealType;
  final int foodCount;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.10),
          blurRadius: 18,
          offset: const Offset(0, -5),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Added to $mealType',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '${calories.round()} kcal',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
            ),
            const SizedBox(width: 8),
            MealInfoPill(
              label: '${protein.round()}g P',
              backgroundColor: const Color(0xFFF8E8E3),
              textColor: AppColors.textPrimary,
              fontSize: 9,
              radius: 6,
              horizontalPadding: 6,
            ),
            const SizedBox(width: 4),
            MealInfoPill(
              label: '${carbs.round()}g C',
              backgroundColor: const Color(0xFFF8F1DF),
              textColor: AppColors.textPrimary,
              fontSize: 9,
              radius: 6,
              horizontalPadding: 6,
            ),
            const SizedBox(width: 4),
            MealInfoPill(
              label: '${fat.toStringAsFixed(1)}g F',
              backgroundColor: const Color(0xFFE7F1F8),
              textColor: AppColors.textPrimary,
              fontSize: 9,
              radius: 6,
              horizontalPadding: 6,
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: foodCount == 0
                ? null
                : () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Meal selected. Saving will be enabled when the meal service is connected.',
                      ),
                    ),
                  ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryBright,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            icon: const Icon(Icons.check_rounded, size: 18),
            label: const Text('Add to My Log'),
          ),
        ),
      ],
    ),
  );
}
