import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 68, this.circular = false});

  final double size;
  final bool circular;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Nutrition & AI Coach',
    image: true,
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: circular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circular ? null : BorderRadius.circular(size * 0.30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x220A5438),
            blurRadius: 32,
            spreadRadius: 4,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: circular
            ? Container(
                width: size * 0.76,
                height: size * 0.76,
                decoration: const BoxDecoration(
                  color: Color(0xFFF3F6F4),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.eco_rounded,
                          color: AppColors.primary,
                          size: size * 0.24,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'NUTRITION\n& HEALTH',
                          style: TextStyle(
                            fontSize: size * 0.075,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            height: 1.05,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : SizedBox(
                width: size * 0.44,
                height: size * 0.44,
                child: CustomPaint(painter: _LeafMarkPainter()),
              ),
      ),
    ),
  );
}

class _LeafMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final stroke = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.085
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final leafPath = Path()
      ..moveTo(w * 0.50, h * 0.10)
      ..cubicTo(w * 0.14, h * 0.36, w * 0.16, h * 0.84, w * 0.50, h * 0.88)
      ..cubicTo(w * 0.84, h * 0.84, w * 0.86, h * 0.36, w * 0.50, h * 0.10)
      ..close();
    canvas.drawPath(leafPath, stroke);

    // Center vein and angled lateral veins
    canvas.drawLine(
      Offset(w * 0.50, h * 0.24),
      Offset(w * 0.50, h * 0.90),
      stroke,
    );
    canvas.drawLine(
      Offset(w * 0.50, h * 0.62),
      Offset(w * 0.34, h * 0.48),
      stroke,
    );
    canvas.drawLine(
      Offset(w * 0.50, h * 0.52),
      Offset(w * 0.66, h * 0.38),
      stroke,
    );

    // Top-right accent dot
    canvas.drawCircle(
      Offset(w * 0.78, h * 0.18),
      w * 0.055,
      Paint()..color = AppColors.primary,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
