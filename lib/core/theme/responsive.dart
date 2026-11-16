import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Responsive sizing helpers backed by `flutter_screenutil` (`ScreenUtil`),
/// clamped so small phones (`320px`) scale down cleanly and large tablets
/// (`1000px+`) stay well-proportioned without oversized text or cards.
extension ResponsiveNum on num {
  static double _clampedWidthScale() {
    try {
      return ScreenUtil().scaleWidth.clamp(0.82, 1.20);
    } catch (_) {
      return 1.0;
    }
  }

  static double _clampedHeightScale() {
    try {
      return ScreenUtil().scaleHeight.clamp(0.82, 1.18);
    } catch (_) {
      return 1.0;
    }
  }

  static double _clampedTextScale() {
    try {
      return ScreenUtil().scaleText.clamp(0.88, 1.15);
    } catch (_) {
      return 1.0;
    }
  }

  double get rw => toDouble() * _clampedWidthScale();
  double get rh => toDouble() * _clampedHeightScale();
  double get rsp => toDouble() * _clampedTextScale();
  double get rr => toDouble() * _clampedWidthScale();
}

/// Ensures `ScreenUtil` is initialized for top-level app shells.
Widget withScreenUtil({required Widget child}) => ScreenUtilInit(
  designSize: const Size(390, 844),
  minTextAdapt: true,
  splitScreenMode: true,
  builder: (_, _) => child,
);

