import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';
import '../../../../core/widgets/brand_mark.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    this.animateEntrance = true,
    this.elapsed = Duration.zero,
  });

  static const minimumDuration = Duration(seconds: 6);
  static const entranceDuration = Duration(milliseconds: 3200);

  final bool animateEntrance;
  final Duration elapsed;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final _entrance = AnimationController(
    vsync: this,
    duration: SplashScreen.entranceDuration,
    value: widget.animateEntrance
        ? (widget.elapsed.inMicroseconds /
                  SplashScreen.entranceDuration.inMicroseconds)
              .clamp(0.0, 1.0)
        : 1,
  );
  late final _ambient = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 8),
  );
  late final _logo = _reveal(0, 0.5);
  late final _heading = _reveal(0.2, 0.75);
  late final _subtitle = _reveal(0.4, 0.9);
  late final _loading = _reveal(0.6, 1);
  bool _reduceMotion = false;

  Animation<double> _reveal(double begin, double end) => _entrance.drive(
    CurveTween(curve: Interval(begin, end, curve: Curves.easeOutCubic)),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion) {
      _entrance.value = 1;
      _ambient.stop();
      _ambient.value = 0;
    } else {
      if (!_entrance.isCompleted) _entrance.forward();
      if (!_ambient.isAnimating) _ambient.repeat();
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    _ambient.dispose();
    super.dispose();
  }

  Widget _revealContent(Animation<double> animation, Widget child) =>
      FadeTransition(
        opacity: animation,
        child: AnimatedBuilder(
          animation: animation,
          child: child,
          builder: (context, child) => Transform.translate(
            offset: Offset(0, 18 * (1 - animation.value)),
            child: child,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE4F4E9), AppColors.background, Color(0xFFFAFCFA)],
        ),
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 28.rw,
                  vertical: 32.rh,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _revealContent(
                          _logo,
                          RepaintBoundary(
                            child: _AnimatedEmblem(
                              entrance: _logo,
                              ambient: _ambient,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        _revealContent(
                          _heading,
                          Text(
                            'Nutrition & AI Coach',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontSize: 30,
                                  height: 1.2,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.9,
                                  color: AppColors.textPrimary,
                                ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _revealContent(
                          _subtitle,
                          const Text(
                            'Mindful nutrition.\nA healthier daily rhythm.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.65,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 44),
                        _revealContent(
                          _loading,
                          Semantics(
                            liveRegion: true,
                            label: 'Getting things ready. Please wait.',
                            child: ExcludeSemantics(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 112,
                                    child: _reduceMotion
                                        ? const Divider(
                                            thickness: 3,
                                            color: AppColors.primary,
                                          )
                                        : const LinearProgressIndicator(
                                            minHeight: 3,
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(8),
                                            ),
                                            color: AppColors.primary,
                                            backgroundColor:
                                                AppColors.primaryContainer,
                                          ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Getting things ready…',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
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
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _AnimatedEmblem extends StatelessWidget {
  const _AnimatedEmblem({required this.entrance, required this.ambient});

  final Animation<double> entrance;
  final Animation<double> ambient;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: 224,
    child: AnimatedBuilder(
      animation: Listenable.merge([entrance, ambient]),
      child: const BrandMark(size: 112),
      builder: (context, child) {
        final breath = (1 - math.cos(ambient.value * math.pi * 2)) / 2;
        return CustomPaint(
          painter: _EmblemRingPainter(
            reveal: entrance.value,
            phase: ambient.value,
          ),
          child: Center(
            child: Transform.translate(
              offset: Offset(0, -4 * breath),
              child: Transform.scale(
                scale: 0.88 + 0.12 * entrance.value + 0.015 * breath,
                child: child,
              ),
            ),
          ),
        );
      },
    ),
  );
}

/// Decorative orbital accents, not a measured percentage of startup work.
class _EmblemRingPainter extends CustomPainter {
  const _EmblemRingPainter({required this.reveal, required this.phase});

  final double reveal;
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 8;
    final breath = (1 - math.cos(phase * math.pi * 2)) / 2;
    canvas.drawCircle(
      center,
      radius * (0.8 + 0.03 * breath),
      Paint()..color = AppColors.primaryContainer.withValues(alpha: 0.48),
    );
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.2
      ..color = AppColors.primary.withValues(alpha: 0.12);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 2 * reveal,
      false,
      stroke,
    );
    final angle = -math.pi / 2 + phase * math.pi * 2;
    for (final offset in [0.0, math.pi]) {
      final position =
          center +
          Offset(math.cos(angle + offset), math.sin(angle + offset)) * radius;
      canvas.drawCircle(
        position,
        offset == 0 ? 4 : 2.5,
        Paint()
          ..color = AppColors.primary.withValues(
            alpha: reveal * (offset == 0 ? 0.65 : 0.25),
          ),
      );
    }
  }

  @override
  bool shouldRepaint(_EmblemRingPainter oldDelegate) =>
      oldDelegate.reveal != reveal || oldDelegate.phase != phase;
}
