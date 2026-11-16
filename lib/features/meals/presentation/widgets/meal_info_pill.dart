import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class MealInfoPill extends StatelessWidget {
  const MealInfoPill({
    super.key,
    required this.label,
    required this.backgroundColor,
    this.textColor = AppColors.primary,
    this.fontSize = 10,
    this.radius = 12,
    this.horizontalPadding = 7,
    this.verticalPadding = 4,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;
  final double radius;
  final double horizontalPadding;
  final double verticalPadding;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(
      horizontal: horizontalPadding,
      vertical: verticalPadding,
    ),
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(radius),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: fontSize,
        color: textColor,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
