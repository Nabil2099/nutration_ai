import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class MealSearchField extends StatelessWidget {
  const MealSearchField({super.key, required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => TextField(
    onChanged: onChanged,
    decoration: InputDecoration(
      hintText: 'Search foods and meals…',
      prefixIcon: const Icon(
        Icons.search_rounded,
        color: AppColors.textSecondary,
      ),
      suffixIcon: IconButton(
        tooltip: 'Food filters',
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Food filters will be available soon.')),
        ),
        icon: const Icon(Icons.tune_rounded, color: AppColors.primary),
      ),
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(32),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(32),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    ),
  );
}
