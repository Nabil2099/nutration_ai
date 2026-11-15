import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/day_key.dart';

class DateStrip extends StatelessWidget {
  const DateStrip({
    super.key,
    required this.today,
    required this.selectedDay,
    required this.onSelected,
  });

  final DateTime today;
  final DateTime selectedDay;
  final ValueChanged<DateTime> onSelected;

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final days = List.generate(7, (i) => calendarDay(today, i - 6));

    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected = dayKey(day) == dayKey(selectedDay);
          final foreground = isSelected ? Colors.white : AppColors.textPrimary;
          final muted = isSelected ? Colors.white70 : AppColors.textSecondary;

          return GestureDetector(
            onTap: () => onSelected(day),
            child: Container(
              width: 56,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _weekdays[day.weekday - 1],
                    style: textTheme.labelSmall?.copyWith(color: muted),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${day.day}',
                    style: textTheme.titleMedium?.copyWith(color: foreground),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
