import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/home_summary.dart';

class CoachTeaserCard extends StatelessWidget {
  const CoachTeaserCard({super.key, required this.onTap, this.summary});

  final VoidCallback onTap;
  final HomeSummary? summary;

  @override
  Widget build(BuildContext context) {
    final proteinGap = summary == null
        ? 52
        : (summary!.goals.proteinG - summary!.proteinConsumedG).round();
    final message = proteinGap > 0
        ? "You're ${proteinGap}g shy of your protein goal. A post-workout Greek yogurt bowl would hit your target seamlessly tonight."
        : 'Your protein target is on track today. Tap to open your nutrition coach for evening meal ideas.';

    return Card(
      margin: EdgeInsets.zero,
      color: AppColors.cardTint,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: AppColors.mintBadge,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome_outlined,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI Nutrition Coach',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: 12.5,
                        height: 1.45,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
