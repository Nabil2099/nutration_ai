import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ProfileHeading extends StatelessWidget {
  const ProfileHeading({super.key});

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Profile',
        style: TextStyle(
          fontSize: 26,
          height: 1.2,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
      SizedBox(height: 2),
      Text(
        'Your personal space',
        style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
      ),
    ],
  );
}
