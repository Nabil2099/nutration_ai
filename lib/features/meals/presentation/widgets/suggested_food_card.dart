import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/suggested_food.dart';
import 'meal_info_pill.dart';

class SuggestedFoodCard extends StatelessWidget {
  const SuggestedFoodCard({
    super.key,
    required this.food,
    required this.grams,
    required this.onToggle,
    required this.onPortionChanged,
  });

  final SuggestedFood food;
  final int? grams;
  final VoidCallback onToggle;
  final ValueChanged<int> onPortionChanged;

  @override
  Widget build(BuildContext context) {
    final selected = grams != null;
    final multiplier = (grams ?? 100) / 100;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: selected ? AppColors.border : const Color(0xFFE9EFEB),
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.035),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              _FoodImage(emoji: food.emoji),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      food.subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    MealInfoPill(
                      label:
                          '${(food.caloriesPer100g * multiplier).round()} kcal',
                      backgroundColor: AppColors.surfaceVariant,
                    ),
                  ],
                ),
              ),
              IconButton.filled(
                onPressed: onToggle,
                tooltip: selected ? 'Remove ${food.name}' : 'Add ${food.name}',
                style: IconButton.styleFrom(
                  backgroundColor: selected
                      ? AppColors.primaryBright
                      : AppColors.surfaceVariant,
                  foregroundColor: selected ? Colors.white : AppColors.primary,
                  minimumSize: const Size(36, 36),
                  maximumSize: const Size(36, 36),
                ),
                icon: Icon(
                  selected ? Icons.check_rounded : Icons.add_rounded,
                  size: 20,
                ),
              ),
            ],
          ),
          if (selected) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: AppColors.border),
            ),
            Row(
              children: [
                const Text(
                  'PORTION CONTROL',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: .5,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                const MealInfoPill(
                  label: 'Gram (g)',
                  backgroundColor: AppColors.surfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F8F6),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  _portionButton(
                    Icons.remove_rounded,
                    () => onPortionChanged((grams! - 25).clamp(0, 2000)),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '${grams}g',
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Text(
                          'serving size',
                          style: TextStyle(
                            fontSize: 9,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _portionButton(
                    Icons.add_rounded,
                    () => onPortionChanged((grams! + 25).clamp(25, 2000)),
                    filled: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 9),
            Row(
              children: [
                for (final amount in [50, 100, 150, 200]) ...[
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => onPortionChanged(amount),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        decoration: BoxDecoration(
                          color: grams == amount
                              ? AppColors.primaryContainer
                              : const Color(0xFFF5F8F6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${amount}g',
                          style: TextStyle(
                            fontSize: 11,
                            color: grams == amount
                                ? AppColors.primary
                                : AppColors.textPrimary,
                            fontWeight: grams == amount
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (amount != 200) const SizedBox(width: 6),
                ],
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _nutritionCell(
                  'Protein',
                  '${(food.proteinPer100g * multiplier).toStringAsFixed(food.proteinPer100g == 0 ? 0 : 1)}g',
                  AppColors.protein,
                ),
                const SizedBox(width: 6),
                _nutritionCell(
                  'Carbs',
                  '${(food.carbsPer100g * multiplier).toStringAsFixed(food.carbsPer100g == 0 ? 0 : 1)}g',
                  AppColors.carbs,
                ),
                const SizedBox(width: 6),
                _nutritionCell(
                  'Fats',
                  '${(food.fatPer100g * multiplier).toStringAsFixed(1)}g',
                  AppColors.fats,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _portionButton(
    IconData icon,
    VoidCallback onPressed, {
    bool filled = false,
  }) => IconButton(
    onPressed: onPressed,
    style: IconButton.styleFrom(
      minimumSize: const Size(36, 36),
      backgroundColor: filled ? AppColors.primaryBright : Colors.white,
      foregroundColor: filled ? Colors.white : AppColors.textPrimary,
      side: filled ? null : const BorderSide(color: AppColors.border),
    ),
    icon: Icon(icon, size: 18),
  );

  Widget _nutritionCell(String title, String value, Color color) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8F6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    ),
  );
}

class _FoodImage extends StatelessWidget {
  const _FoodImage({required this.emoji});
  final String emoji;

  @override
  Widget build(BuildContext context) => Container(
    width: 48,
    height: 48,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: const Color(0xFFF0F4F1),
      borderRadius: BorderRadius.circular(13),
    ),
    child: Text(emoji, style: const TextStyle(fontSize: 25)),
  );
}
