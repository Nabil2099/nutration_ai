import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 64});
  final double size;
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Nutrition & AI Coach',
    image: true,
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size / 3),
        border: Border.all(color: AppColors.border),
      ),
      child: Icon(
        Icons.spa_outlined,
        color: AppColors.primary,
        size: size * .46,
      ),
    ),
  );
}
