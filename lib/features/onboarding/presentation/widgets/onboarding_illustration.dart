import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// A local vector food illustration: no network request or demo nutrition data.
class OnboardingIllustration extends StatelessWidget {
  const OnboardingIllustration({super.key});

  @override
  Widget build(BuildContext context) => Semantics(
    image: true,
    label: 'A colorful bowl of vegetables and grains',
    child: AspectRatio(
      aspectRatio: 1.6,
      child: CustomPaint(painter: _FoodBowlPainter()),
    ),
  );
}

class _FoodBowlPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.height * .43;
    final paint = Paint()..isAntiAlias = true;
    canvas.drawOval(
      Rect.fromCenter(
        center: center + Offset(0, radius * .12),
        width: radius * 2.2,
        height: radius * 1.9,
      ),
      paint..color = AppColors.border,
    );
    canvas.drawCircle(center, radius, paint..color = Colors.white);
    canvas.drawCircle(
      center,
      radius * .86,
      paint..color = const Color(0xFFF0E9D8),
    );
    // Small grains fill the bowl behind the vegetables.
    for (var i = 0; i < 50; i++) {
      final angle = i * 2.399;
      final distance = radius * .72 * math.sqrt(i / 50);
      final point =
          center + Offset(math.cos(angle), math.sin(angle)) * distance;
      canvas.drawOval(
        Rect.fromCenter(
          center: point,
          width: radius * .1,
          height: radius * .055,
        ),
        paint..color = const Color(0xFFD6BE8A),
      );
    }
    for (var i = 0; i < 9; i++) {
      final angle = i * .38 + 2.8;
      final point =
          center +
          Offset(
            math.cos(angle) * radius * .55,
            math.sin(angle) * radius * .55,
          );
      canvas.drawOval(
        Rect.fromCenter(
          center: point,
          width: radius * .5,
          height: radius * .32,
        ),
        paint
          ..color = i.isEven
              ? const Color(0xFF6A9D62)
              : const Color(0xFF92B97B),
      );
    }
    // Cucumber slices and tomatoes.
    for (final delta in [
      const Offset(.38, .2),
      const Offset(.50, -.07),
      const Offset(.24, .42),
    ]) {
      final point = center + delta * radius;
      canvas.drawCircle(
        point,
        radius * .2,
        paint..color = const Color(0xFF508360),
      );
      canvas.drawCircle(
        point,
        radius * .15,
        paint..color = const Color(0xFFD2DFAB),
      );
      canvas.drawCircle(
        point,
        radius * .04,
        paint..color = const Color(0xFF9CB57A),
      );
    }
    for (final delta in [
      const Offset(-.2, .3),
      const Offset(-.48, .28),
      const Offset(-.34, .5),
    ]) {
      final point = center + delta * radius;
      canvas.drawCircle(
        point,
        radius * .16,
        paint..color = const Color(0xFFD78572),
      );
      canvas.drawCircle(
        point - Offset(radius * .04, radius * .04),
        radius * .035,
        paint..color = const Color(0xFFF2B6A0),
      );
    }
    final leaf = Path()
      ..moveTo(center.dx + radius * .08, center.dy - radius * .12)
      ..quadraticBezierTo(
        center.dx - radius * .15,
        center.dy - radius * .65,
        center.dx + radius * .35,
        center.dy - radius * .55,
      )
      ..quadraticBezierTo(
        center.dx + radius * .45,
        center.dy - radius * .15,
        center.dx + radius * .08,
        center.dy - radius * .12,
      );
    canvas.drawPath(leaf, paint..color = AppColors.primary);
  }

  @override
  bool shouldRepaint(_FoodBowlPainter oldDelegate) => false;
}
