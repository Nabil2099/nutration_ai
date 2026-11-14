import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class CalorieProgressRing extends StatelessWidget {
  const CalorieProgressRing({
    super.key,
    required this.progress,
    required this.remaining,
    required this.goal,
  });
  final double progress, remaining, goal;
  @override
  Widget build(BuildContext context) => Semantics(
    label: goal <= 0
        ? 'Set a daily goal'
        : '${remaining.abs().round()} kilocalories ${remaining < 0 ? 'over goal' : 'remaining'}',
    child: SizedBox(
      width: 220,
      height: 220,
      child: CustomPaint(
        painter: _RingPainter(progress),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    goal <= 0
                        ? 'SET A DAILY GOAL'
                        : remaining < 0
                        ? 'OVER GOAL'
                        : 'REMAINING',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    goal <= 0 ? '—' : '${remaining.abs().round()}',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'kcal • out of ${goal.round()} kcal',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _RingPainter extends CustomPainter {
  const _RingPainter(this.progress);
  final double progress;
  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(12);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      paint..color = AppColors.surfaceVariant,
    );
    final value = progress.isFinite ? progress.clamp(0.0, 1.0) : 0.0;
    if (value > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        math.pi * 2 * value,
        false,
        paint..color = AppColors.primary,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
