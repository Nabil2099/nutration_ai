import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/home_summary.dart';

class DailyCaloriesChart extends StatelessWidget {
  const DailyCaloriesChart({super.key, required this.days, required this.goal});

  final List<DailyCalories> days;
  final double goal;

  static int _isoWeekNumber(DateTime date) {
    final dayOfYear = int.parse(DateFormat('D').format(date));
    return ((dayOfYear - date.weekday + 10) ~/ 7).clamp(1, 53);
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.decimalPattern();
    final max = days.fold<double>(
      goal > 0 ? goal : 1,
      (value, day) => math.max(value, day.calories ?? 0),
    );
    final logged = days.where((d) => d.calories != null).toList();
    final avg = logged.isEmpty
        ? 0.0
        : logged.fold<double>(0, (sum, d) => sum + d.calories!) / logged.length;
    final week = days.isEmpty ? 43 : _isoWeekNumber(days.last.day);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.start,
              spacing: 12,
              runSpacing: 8,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Text(
                          'Daily Calories',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2E8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Week $week',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryBright,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Last 7 days trend',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      logged.isEmpty ? '—' : fmt.format(avg.round()),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const Text(
                      'kcal avg / day',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (goal > 0)
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${fmt.format(goal.round())} kcal target',
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            const SizedBox(height: 4),
            SizedBox(
              height: 156,
              child: Column(
                children: [
                  Expanded(
                    child: SizedBox.expand(
                      child: CustomPaint(
                        painter: _TrendSplinePainter(
                          days: days,
                          goal: goal,
                          max: max,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      for (var i = 0; i < days.length; i++)
                        Expanded(
                          child: Semantics(
                            label:
                                '${DateFormat.MMMd().format(days[i].day)}: ${days[i].calories == null ? 'not logged' : '${days[i].calories!.round()} kcal logged'}',
                            child: Center(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  DateFormat.E().format(days[i].day),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: i == days.length - 1
                                        ? FontWeight.w800
                                        : FontWeight.w500,
                                    color: i == days.length - 1
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendSplinePainter extends CustomPainter {
  const _TrendSplinePainter({
    required this.days,
    required this.goal,
    required this.max,
  });

  final List<DailyCalories> days;
  final double goal;
  final double max;

  @override
  void paint(Canvas canvas, Size size) {
    if (days.isEmpty) return;

    const topPad = 12.0;
    const bottomPad = 10.0;
    final chartHeight = math.max(1.0, size.height - topPad - bottomPad);
    final stepX = size.width / days.length;

    double yFor(double kcal) {
      final ratio = (kcal / (max > 0 ? max : 1)).clamp(0.0, 1.0);
      return topPad + chartHeight * (1.0 - ratio * 0.85);
    }

    // Dashed target line
    final targetY = goal > 0 ? yFor(goal) : topPad + chartHeight * 0.18;
    final dashPaint = Paint()
      ..color = const Color(0xFFD0DCD5)
      ..strokeWidth = 1.2;
    for (var x = 0.0; x < size.width; x += 9) {
      canvas.drawLine(
        Offset(x, targetY),
        Offset(math.min(x + 5, size.width), targetY),
        dashPaint,
      );
    }

    final points = <Offset>[];
    for (var i = 0; i < days.length; i++) {
      final cx = stepX * (i + 0.5);
      final value = days[i].calories;
      final cy = value == null ? topPad + chartHeight : yFor(value);
      points.add(Offset(cx, cy));
    }

    if (points.length >= 2) {
      final curve = Path()..moveTo(points.first.dx, points.first.dy);
      for (var i = 0; i < points.length - 1; i++) {
        final p0 = points[i];
        final p1 = points[i + 1];
        final midX = (p0.dx + p1.dx) / 2;
        curve.cubicTo(midX, p0.dy, midX, p1.dy, p1.dx, p1.dy);
      }

      final fillPath = Path.from(curve)
        ..lineTo(points.last.dx, size.height)
        ..lineTo(points.first.dx, size.height)
        ..close();

      canvas.drawPath(
        fillPath,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF47B881).withValues(alpha: 0.25),
              const Color(0xFF47B881).withValues(alpha: 0.0),
            ],
          ).createShader(Offset.zero & size),
      );

      canvas.drawPath(
        curve,
        Paint()
          ..color = AppColors.primaryBright
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.6
          ..strokeCap = StrokeCap.round,
      );
    }

    // Data point markers
    for (var i = 0; i < points.length; i++) {
      final pt = points[i];
      final isLast = i == points.length - 1;
      if (isLast) {
        canvas.drawCircle(
          pt,
          7.5,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill,
        );
        canvas.drawCircle(
          pt,
          7.5,
          Paint()
            ..color = AppColors.primaryBright.withValues(alpha: 0.35)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
        canvas.drawCircle(
          pt,
          4.5,
          Paint()
            ..color = AppColors.primaryBright
            ..style = PaintingStyle.fill,
        );
      } else {
        canvas.drawCircle(
          pt,
          3.8,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill,
        );
        canvas.drawCircle(
          pt,
          3.8,
          Paint()
            ..color = AppColors.primaryBright
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TrendSplinePainter oldDelegate) =>
      oldDelegate.days != days ||
      oldDelegate.goal != goal ||
      oldDelegate.max != max;
}
