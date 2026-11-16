import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class SuggestedFoodHeader extends StatelessWidget {
  const SuggestedFoodHeader({
    super.key,
    this.mealType = 'Lunch',
    this.filterByMealType = false,
    this.onToggleFilter,
    this.onAddCustom,
  });

  final String mealType;
  final bool filterByMealType;
  final VoidCallback? onToggleFilter;
  final VoidCallback? onAddCustom;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: Row(
      children: [
        const Expanded(
          child: Text(
            'Suggested foods',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ),
        if (onAddCustom != null)
          TextButton.icon(
            onPressed: onAddCustom,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              backgroundColor: AppColors.mintBadge,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: const Icon(Icons.add_rounded, size: 15),
            label: const Text(
              'Custom meal',
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
            ),
          ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onToggleFilter,
          child: Text(
            filterByMealType ? 'Only $mealType' : 'See all',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}
