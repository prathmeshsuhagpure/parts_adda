import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Brand (same for both themes)
  static const Color primary = Color(0xFFE8290B);
  static const Color primaryDark = Color(0xFFC41E0A);
  static const Color primaryLight = Color(0xFFFF4422);
}

/// 🌙 DARK THEME COLORS
class AppColorsDark {
  AppColorsDark._();

  // Background
  static const Color bg = Color(0xFF0A0A0A);
  static const Color bgCard = Color(0xFF1E1E1E);
  static const Color bgCard2 = Color(0xFF1A1A1A);
  static const Color bgInput = Color(0xFF242424);
  static const Color bgSection = Color(0xFF111111);

  // Text
  static const Color textPrimary = Color(0xFFF5F4F2);
  static const Color textSecondary = Color(0xFFAAAAAA);
  static const Color textMuted = Color(0xFF555555);

  // Borders
  static const Color border = Color(0xFF2A2A2A);
  static const Color borderLight = Color(0xFF3A3A3A);

  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFFFB800);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Tags
  static Color tagRedBg = const Color(0xFFE8290B).withValues(alpha: 0.15);
  static Color tagGreenBg = const Color(0xFF22C55E).withValues(alpha: 0.12);
  static Color tagYellowBg = const Color(0xFFFFB800).withValues(alpha: 0.12);
  static Color tagBlueBg = const Color(0xFF3B82F6).withValues(alpha: 0.12);
}

/// ☀️ LIGHT THEME COLORS
class AppColorsLight {
  AppColorsLight._();

  // Background
  static const Color bg = Color(0xFFF7F7F7);
  static const Color bgCard = Colors.white;
  static const Color bgCard2 = Color(0xFFF1F1F1);
  static const Color bgInput = Color(0xFFF3F3F3);
  static const Color bgSection = Color(0xFFEDEDED);

  // Text
  static const Color textPrimary = Color(0xFF111111);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textMuted = Color(0xFF999999);

  // Borders
  static const Color border = Color(0xFFE5E5E5);
  static const Color borderLight = Color(0xFFF0F0F0);

  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFFFB800);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Tags
  static Color tagRedBg = const Color(0xFFE8290B).withValues(alpha: 0.10);
  static Color tagGreenBg = const Color(0xFF22C55E).withValues(alpha: 0.10);
  static Color tagYellowBg = const Color(0xFFFFB800).withValues(alpha: 0.10);
  static Color tagBlueBg = const Color(0xFF3B82F6).withValues(alpha: 0.10);
}