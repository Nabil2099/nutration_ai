import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/data/models/nutrition_goals.dart';
import '../../../../core/theme/app_colors.dart';

class DailyGoalsCard extends StatelessWidget {
  const DailyGoalsCard({super.key, required this.goals, required this.onEdit});

  final NutritionGoals goals;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.decimalPattern();
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Daily Goals',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
              TextButton(onPressed: onEdit, child: const Text('Edit')),
            ],
          ),
          Container(
            color: const Color(0xFFF1F8F3),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'DAILY CALORIE GOAL',
                    style: TextStyle(
                      fontSize: 9,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Text(
                  formatter.format(goals.calories.round()),
                  style: const TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 5),
                const Text(
                  'kcal',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _macroRow('Protein', goals.proteinG, AppColors.protein),
          _macroRow('Carbs', goals.carbsG, AppColors.carbs),
          _macroRow('Fats', goals.fatG, AppColors.fats),
          const Divider(height: 16, color: AppColors.border),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Targets automatically adjust your daily pacing.',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _macroRow(String label, double grams, Color color) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      children: [
        CircleAvatar(radius: 5, backgroundColor: color),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '${grams.round()}g',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}
