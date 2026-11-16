import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/data/models/meal_entry.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/day_key.dart';

class CoachMacroChart extends StatelessWidget {
  const CoachMacroChart({
    super.key,
    required this.meals,
    required this.carbsGoalG,
    this.today,
  });

  final List<MealEntry> meals;
  final double carbsGoalG;
  final DateTime? today;

  @override
  Widget build(BuildContext context) {
    final now = today ?? DateTime.now();
    final days = List.generate(7, (i) => calendarDay(now, i - 6));

    double maxStack = 1;
    final stacks = days.map((date) {
      final k = dayKey(date);
      final dayMeals = meals.where((m) => m.localDayKey == k);
      final p = dayMeals.fold<double>(0, (s, m) => s + m.proteinG);
      final c = dayMeals.fold<double>(0, (s, m) => s + m.carbsG);
      final f = dayMeals.fold<double>(0, (s, m) => s + m.fatG);
      maxStack = math.max(maxStack, p + c + f);
      return (p: p, c: c, f: f);
    }).toList();

    final hasMeals = meals.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardTint,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: const [
              Text(
                '7-Day Macro Distribution',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _LegendDot(color: AppColors.carbs, label: 'Carbs'),
                  SizedBox(width: 8),
                  _LegendDot(color: AppColors.protein, label: 'Protein'),
                  SizedBox(width: 8),
                  _LegendDot(color: AppColors.fats, label: 'Fat'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Goal ${carbsGoalG.round()}g',
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 92,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < stacks.length; i++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: _StackedBar(
                        protein: hasMeals ? stacks[i].p : 30 + (i % 3) * 8,
                        carbs: hasMeals ? stacks[i].c : 36 + (i % 2) * 10,
                        fat: hasMeals ? stacks[i].f : 18 + (i % 3) * 4,
                        maxTotal: hasMeals ? maxStack : 110,
                        dimmed: !hasMeals,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StackedBar extends StatelessWidget {
  const _StackedBar({
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.maxTotal,
    required this.dimmed,
  });

  final double protein;
  final double carbs;
  final double fat;
  final double maxTotal;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final total = protein + carbs + fat;
    if (total <= 0) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.border,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      );
    }
    final heightFraction = (total / maxTotal).clamp(0.18, 1.0);
    final totalHeight = 84 * heightFraction;
    final alpha = dimmed ? 0.35 : 1.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _segment(
          carbs / total * totalHeight,
          AppColors.carbs.withValues(alpha: alpha),
        ),
        const SizedBox(height: 2),
        _segment(
          protein / total * totalHeight,
          AppColors.protein.withValues(alpha: alpha),
        ),
        const SizedBox(height: 2),
        _segment(
          fat / total * totalHeight,
          AppColors.fats.withValues(alpha: alpha),
        ),
      ],
    );
  }

  Widget _segment(double h, Color color) => Container(
    height: math.max(3, h - 2),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(4),
    ),
  );
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 4),
      Text(
        label,
        style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
      ),
    ],
  );
}
