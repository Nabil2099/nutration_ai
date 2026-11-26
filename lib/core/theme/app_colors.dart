import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background = Color(0xFFF3F9F5),
      surface = Colors.white,
      primary = Color(0xFF0A5438),
      primaryBright = Color(0xFF146345),
      primaryContainer = Color(0xFFD6F2E2),
      mintBadge = Color(0xFFA6F0C6),
      surfaceVariant = Color(0xFFE9F2EC),
      cardTint = Color(0xFFECF4EF),
      textPrimary = Color(0xFF111C16),
      textSecondary = Color(0xFF5A6A60),
      border = Color(0xFFE0EAE4),
      protein = Color(0xFFD77A61),
      carbs = Color(0xFFD9A34A),
      fats = Color(0xFF4A9BD1);

  // Meal photo scan accents (gradient CTA, result card, in-progress states).
  static const scan = Color(0xFF16A475),
      scanContainer = Color(0xFFDDF6EC),
      scanGradientStart = Color(0xFF0A5438),
      scanGradientEnd = Color(0xFF23B984);

  // Semantic feedback states (success / warning / error / info).
  static const success = Color(0xFF1E8E5A),
      successContainer = Color(0xFFD9F5E7),
      warning = Color(0xFFB45309),
      warningContainer = Color(0xFFFEF0D9),
      error = Color(0xFFC2453D),
      errorContainer = Color(0xFFFBE4E2),
      info = Color(0xFF3D7EB8),
      infoContainer = Color(0xFFE3F0FA);
}
