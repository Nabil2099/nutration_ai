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
          Text('Macros', style: Theme.of(context).textTheme.titleLarge),
          const Text(
            "Today's Target",
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          for (final macro in [
            (
              'Protein',
              summary.proteinConsumedG,
              summary.goals.proteinG,
              AppColors.protein,
            ),
            (
              'Carbs',
              summary.carbsConsumedG,
              summary.goals.carbsG,
              AppColors.carbs,
            ),
            ('Fat', summary.fatConsumedG, summary.goals.fatG, AppColors.fats),
          ]) ...[
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 12,
              children: [
                Text(macro.$1),
                Text('${macro.$2.round()} / ${macro.$3.round()} g'),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress(macro.$2, macro.$3),
              minHeight: 10,
              borderRadius: BorderRadius.circular(12),
              color: macro.$4,
              backgroundColor: AppColors.surfaceVariant,
              semanticsLabel:
                  '${macro.$1}: ${macro.$2.round()} of ${macro.$3.round()} grams',
            ),
          ],
        ],
      ),
    ),
  );
}
