import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';

class GreetingHeader extends StatelessWidget {
  const GreetingHeader({
    super.key,
    required this.name,
    required this.date,
    required this.onProfile,
  });
  final String name;
  final DateTime date;
  final VoidCallback onProfile;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('EEEE, MMM d').format(date),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${date.hour < 12
                  ? 'Good morning'
                  : date.hour < 18
                  ? 'Good afternoon'
                  : 'Good evening'}, $name',
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
      const SizedBox(width: 12),
      IconButton.filled(
        onPressed: onProfile,
        tooltip: 'Profile',
        icon: Text(name.isEmpty ? '?' : name.characters.first.toUpperCase()),
      ),
    ],
  );
}
