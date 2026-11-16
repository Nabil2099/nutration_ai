import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/services/analytics_service.dart';

class MacroDistributionCard extends StatelessWidget {
  const MacroDistributionCard({super.key, required this.macros});

  final MacroAverages macros;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
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
          Text('Macro Distribution', style: textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'How your calories are balanced',
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          if (macros.totalKcal == 0)
            Text(
              'No macro data yet',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          else ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 12,
                child: Row(
                  children: [
                    Expanded(
                      flex: (macros.proteinPercent * 100).round().clamp(1, 100),
                      child: const ColoredBox(color: AppColors.protein),
                    ),
                    Expanded(
                      flex: (macros.carbsPercent * 100).round().clamp(1, 100),
                      child: const ColoredBox(color: AppColors.carbs),
                    ),
                    Expanded(
                      flex: (macros.fatPercent * 100).round().clamp(1, 100),
                      child: const ColoredBox(color: AppColors.fats),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _MacroTile(
                  label: 'Protein',
                  color: AppColors.protein,
                  percent: macros.proteinPercent,
                  grams: macros.proteinG,
                ),
                const SizedBox(width: 8),
                _MacroTile(
                  label: 'Carbs',
                  color: AppColors.carbs,
                  percent: macros.carbsPercent,
                  grams: macros.carbsG,
                ),
                const SizedBox(width: 8),
                _MacroTile(
                  label: 'Fats',
                  color: AppColors.fats,
                  percent: macros.fatPercent,
                  grams: macros.fatG,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MacroTile extends StatelessWidget {
  const _MacroTile({
    required this.label,
    required this.color,
    required this.percent,
    required this.grams,
  });

  final String label;
  final Color color;
  final double percent;
  final double grams;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(radius: 4, backgroundColor: color),
                const SizedBox(width: 6),
                Text(label, style: textTheme.labelMedium),
              ],
            ),
            const SizedBox(height: 6),
            Text('${(percent * 100).round()}%', style: textTheme.titleLarge),
            Text(
              '${grams.round()}g / day',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
