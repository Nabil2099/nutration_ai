import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class SuggestedFoodHeader extends StatelessWidget {
  const SuggestedFoodHeader({super.key});

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Suggested foods',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        Text(
          'See all',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}
