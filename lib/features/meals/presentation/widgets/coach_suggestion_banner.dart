import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class CoachSuggestionBanner extends StatelessWidget {
  const CoachSuggestionBanner({super.key});

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.surfaceVariant,
    borderRadius: BorderRadius.circular(18),
    child: InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'AI suggestions will be available when Coach is connected.',
          ),
        ),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.auto_awesome, size: 15, color: Colors.white),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'AI Suggestion: High-protein pairing based on your goals',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, color: AppColors.primary),
              ),
            ),
            Icon(
              Icons.arrow_forward_rounded,
              size: 18,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    ),
  );
}
