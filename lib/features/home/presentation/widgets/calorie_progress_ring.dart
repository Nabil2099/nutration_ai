import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';

class CalorieProgressRing extends StatelessWidget {
  const CalorieProgressRing({
    super.key,
    required this.progress,
    required this.remaining,
    required this.goal,
  });

  final double progress;
  final double remaining;
  final double goal;

  @override
  Widget build(BuildContext context) {
    final formattedGoal = NumberFormat.decimalPattern().format(goal.round());
    return Semantics(
      label: goal <= 0
          ? 'Set a daily goal'
          : '${remaining.abs().round()} kilocalories ${remaining < 0 ? 'over goal' : 'remaining'}',
      child: SizedBox(
        width: 220.rw,
        height: 220.rw,
        child: CustomPaint(
          painter: _RingPainter(progress),
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(30.rw),
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
                      style: TextStyle(
                        fontSize: 11.5.rsp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 4.rh),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          goal <= 0 ? '—' : '${remaining.abs().round()}',
                          style: TextStyle(
                            fontSize: 38.rsp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.8,
                          ),
                        ),
                        if (goal > 0) ...[
                          SizedBox(width: 4.rw),
                          Text(
                            'kcal',
                            style: TextStyle(
                              fontSize: 15.rsp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryBright,
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 2.rh),
                    Text(
                      'out of $formattedGoal kcal',
                      style: TextStyle(
                        fontSize: 12.rsp,
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
}

class _RingPainter extends CustomPainter {
  const _RingPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(14);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      paint..color = const Color(0xFFE1ECE6),
    );
    final value = progress.isFinite ? progress.clamp(0.0, 1.0) : 0.0;
    if (value > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        math.pi * 2 * value,
        false,
        paint..color = AppColors.primaryBright,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
