import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/nutrition_math.dart';
import '../../data/models/home_summary.dart';

class MacroProgressCard extends StatelessWidget {
  const MacroProgressCard({super.key, required this.summary});

  final HomeSummary summary;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 6,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Macros',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Text(
                    "Today's Target",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.pie_chart_outline_rounded,
                    size: 15,
                    color: AppColors.primaryBright,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Balanced',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryBright,
                    ),
                  ),
                ],
              ),
            ],
          ),
          for (final macro
              in <({String label, double consumed, double goal, Color color})>[
                (
                  label: 'Protein',
                  consumed: summary.proteinConsumedG,
                  goal: summary.goals.proteinG,
                  color: AppColors.protein,
                ),
                (
                  label: 'Carbs',
                  consumed: summary.carbsConsumedG,
                  goal: summary.goals.carbsG,
                  color: AppColors.carbs,
                ),
                (
                  label: 'Fat',
                  consumed: summary.fatConsumedG,
                  goal: summary.goals.fatG,
                  color: AppColors.fats,
                ),
              ]) ...[
            const SizedBox(height: 18),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 4,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: macro.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      macro.label,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Text.rich(
                  TextSpan(
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                    ),
                    children: [
                      TextSpan(
                        text: '${macro.consumed.round()}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextSpan(text: ' / ${macro.goal.round()}g  '),
                      TextSpan(
                        text:
                            '(${(progress(macro.consumed, macro.goal) * 100).round()}%)',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress(macro.consumed, macro.goal),
              minHeight: 10,
              borderRadius: BorderRadius.circular(12),
              color: macro.color,
              backgroundColor: AppColors.surfaceVariant,
              semanticsLabel:
                  '${macro.label}: ${macro.consumed.round()} of ${macro.goal.round()} grams',
            ),
          ],
        ],
      ),
    ),
  );
}
