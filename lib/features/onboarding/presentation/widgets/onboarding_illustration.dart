import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Overhead nourish-bowl showcase card matching the onboarding hero design.
class OnboardingIllustration extends StatelessWidget {
  const OnboardingIllustration({super.key});

  @override
  Widget build(BuildContext context) => Semantics(
    image: true,
    label: 'A colorful bowl of vegetables and grains',
    child: ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: 196,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(painter: _FoodShowcasePainter()),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Welcome to Nomad',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.black.withValues(alpha: 0.78),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Nourishing meals, balanced for your daily rhythm',
                      style: TextStyle(
                        fontSize: 6.5,
                        color: Colors.black.withValues(alpha: 0.48),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1F000000),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Smart meal suggestions synced to metabolism',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _FoodShowcasePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    // Soft studio backdrop with bottom vignette
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF3F6F8), Color(0xFFE9ECEE), Color(0xFF8C9492)],
          stops: [0.0, 0.58, 1.0],
        ).createShader(rect),
    );

    // Center phone/card strip highlight like the reference image
    final stripWidth = math.min(size.width * 0.44, 150.0);
    final stripRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: stripWidth,
      height: size.height,
    );
    canvas.drawRect(
      stripRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFAF8F4), Color(0xFFE7DEC9), Color(0xFF6B7770)],
          stops: [0.0, 0.52, 1.0],
        ).createShader(stripRect),
    );

    final bowlCenter = Offset(size.width / 2, size.height * 0.50);
    final radius = math.min(stripWidth * 0.38, size.height * 0.27);
    final paint = Paint()..isAntiAlias = true;

    // Bowl shadow
    canvas.drawCircle(
      bowlCenter + const Offset(4, 7),
      radius * 1.04,
      paint..color = const Color(0x33000000),
    );
    // Ceramic rim & base
    canvas.drawCircle(
      bowlCenter,
      radius,
      paint..color = const Color(0xFFE2E6DF),
    );
    canvas.drawCircle(
      bowlCenter,
      radius * 0.90,
      paint..color = const Color(0xFFC8B08B),
    );

    // Quinoa / grain cluster (bottom-left)
    for (var i = 0; i < 42; i++) {
      final angle = i * 2.399;
      final dist = radius * 0.72 * math.sqrt(i / 42);
      final pt = bowlCenter + Offset(math.cos(angle), math.sin(angle)) * dist;
      canvas.drawCircle(
        pt,
        radius * 0.055,
        paint
          ..color = i.isEven
              ? const Color(0xFF9C7B54)
              : const Color(0xFFB89668),
      );
    }

    // Spinach leaves (top-right)
    for (var i = 0; i < 7; i++) {
      final angle = -0.9 + i * 0.28;
      final pt =
          bowlCenter +
          Offset(math.cos(angle), math.sin(angle)) * (radius * 0.48);
      canvas.drawOval(
        Rect.fromCenter(
          center: pt,
          width: radius * 0.42,
          height: radius * 0.26,
        ),
        paint
          ..color = i.isEven
              ? const Color(0xFF2D6A3E)
              : const Color(0xFF458B52),
      );
    }

    // Edamame beans (bottom-right)
    for (final offset in const [
      Offset(0.28, 0.30),
      Offset(0.42, 0.16),
      Offset(0.16, 0.44),
      Offset(0.36, 0.38),
      Offset(0.50, 0.28),
    ]) {
      canvas.drawCircle(
        bowlCenter + offset * radius,
        radius * 0.11,
        paint..color = const Color(0xFF6CC04A),
      );
    }

    // Avocado half (left)
    final avoCenter = bowlCenter + Offset(-radius * 0.36, -radius * 0.08);
    canvas.drawOval(
      Rect.fromCenter(
        center: avoCenter,
        width: radius * 0.56,
        height: radius * 0.42,
      ),
      paint..color = const Color(0xFF4C7C34),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: avoCenter,
        width: radius * 0.46,
        height: radius * 0.33,
      ),
      paint..color = const Color(0xFFDCE784),
    );
    canvas.drawCircle(
      avoCenter,
      radius * 0.10,
      paint..color = const Color(0xFF7A4B2A),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
