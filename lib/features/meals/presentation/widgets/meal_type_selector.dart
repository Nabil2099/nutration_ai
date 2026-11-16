import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../cubit/add_meal_state.dart';

class MealTypeSelector extends StatelessWidget {
  const MealTypeSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        for (final mealType in AddMealState.mealTypes) ...[
          ChoiceChip(
            label: Text(mealType),
            selected: selected == mealType,
            onSelected: (_) => onSelected(mealType),
            showCheckmark: false,
            labelStyle: TextStyle(
              color: selected == mealType
                  ? AppColors.primary
                  : AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            backgroundColor: Colors.white,
            selectedColor: AppColors.primaryContainer,
            side: BorderSide(
              color: selected == mealType
                  ? AppColors.primaryContainer
                  : AppColors.border,
            ),
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
          if (mealType != AddMealState.mealTypes.last) const SizedBox(width: 8),
        ],
      ],
    ),
  );
}
