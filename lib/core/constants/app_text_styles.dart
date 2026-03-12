import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // Display / Headings — Syne font
  static TextStyle displayLg(bool isDarkMode) => TextStyle(
    fontFamily: 'Syne',
    fontWeight: FontWeight.w800,
    fontSize: 32,
    letterSpacing: -0.5,
    color:
    isDarkMode ? AppColorsDark.textPrimary : AppColorsLight.textPrimary,
  );

  static TextStyle displayMd(bool isDarkMode) => TextStyle(
    fontFamily: 'Syne',
    fontWeight: FontWeight.w800,
    fontSize: 26,
    letterSpacing: -0.3,
    color:
    isDarkMode ? AppColorsDark.textPrimary : AppColorsLight.textPrimary,
  );

  static TextStyle displaySm(bool isDarkMode) => TextStyle(
    fontFamily: 'Syne',
    fontWeight: FontWeight.w700,
    fontSize: 20,
    color:
    isDarkMode ? AppColorsDark.textPrimary : AppColorsLight.textPrimary,
  );

  static TextStyle heading(bool isDarkMode) => TextStyle(
    fontFamily: 'Syne',
    fontWeight: FontWeight.w700,
    fontSize: 18,
    color:
    isDarkMode ? AppColorsDark.textPrimary : AppColorsLight.textPrimary,
  );

  static TextStyle headingSm(bool isDarkMode) => TextStyle(
    fontFamily: 'Syne',
    fontWeight: FontWeight.w700,
    fontSize: 15,
    color:
    isDarkMode ? AppColorsDark.textPrimary : AppColorsLight.textPrimary,
  );

  // Price — Syne
  static TextStyle priceLg() => const TextStyle(
    fontFamily: 'Syne',
    fontWeight: FontWeight.w800,
    fontSize: 24,
    color: AppColors.primary,
  );

  static TextStyle priceMd() => const TextStyle(
    fontFamily: 'Syne',
    fontWeight: FontWeight.w700,
    fontSize: 16,
    color: AppColors.primary,
  );

  static TextStyle priceSm() => const TextStyle(
    fontFamily: 'Syne',
    fontWeight: FontWeight.w700,
    fontSize: 14,
    color: AppColors.primary,
  );

  // Body — DMSans
  static TextStyle bodyLg(bool isDarkMode) => TextStyle(
    fontFamily: 'DMSans',
    fontWeight: FontWeight.w400,
    fontSize: 15,
    color:
    isDarkMode ? AppColorsDark.textPrimary : AppColorsLight.textPrimary,
  );

  static TextStyle bodyMd(bool isDarkMode) => TextStyle(
    fontFamily: 'DMSans',
    fontWeight: FontWeight.w400,
    fontSize: 13,
    color:
    isDarkMode ? AppColorsDark.textPrimary : AppColorsLight.textPrimary,
  );

  static TextStyle bodySm(bool isDarkMode) => TextStyle(
    fontFamily: 'DMSans',
    fontWeight: FontWeight.w400,
    fontSize: 12,
    color: isDarkMode
        ? AppColorsDark.textSecondary
        : AppColorsLight.textSecondary,
  );

  static TextStyle bodyXs(bool isDarkMode) => TextStyle(
    fontFamily: 'DMSans',
    fontWeight: FontWeight.w400,
    fontSize: 11,
    color:
    isDarkMode ? AppColorsDark.textMuted : AppColorsLight.textMuted,
  );

  // Labels
  static TextStyle labelMd(bool isDarkMode) => TextStyle(
    fontFamily: 'DMSans',
    fontWeight: FontWeight.w600,
    fontSize: 13,
    color:
    isDarkMode ? AppColorsDark.textPrimary : AppColorsLight.textPrimary,
  );

  static TextStyle labelSm(bool isDarkMode) => TextStyle(
    fontFamily: 'DMSans',
    fontWeight: FontWeight.w600,
    fontSize: 12,
    letterSpacing: 0.3,
    color: isDarkMode
        ? AppColorsDark.textSecondary
        : AppColorsLight.textSecondary,
  );

  static TextStyle labelXs(bool isDarkMode) => TextStyle(
    fontFamily: 'DMSans',
    fontWeight: FontWeight.w600,
    fontSize: 10,
    letterSpacing: 1.2,
    color:
    isDarkMode ? AppColorsDark.textMuted : AppColorsLight.textMuted,
  );

  // Button
  static const TextStyle button = TextStyle(
    fontFamily: 'Syne',
    fontWeight: FontWeight.w700,
    fontSize: 15,
    color: Colors.white,
  );

  static const TextStyle buttonSm = TextStyle(
    fontFamily: 'Syne',
    fontWeight: FontWeight.w700,
    fontSize: 13,
    color: Colors.white,
  );

  // Mono
  static TextStyle mono(bool isDarkMode) => TextStyle(
    fontFamily: 'monospace',
    fontWeight: FontWeight.w500,
    fontSize: 12,
    color: isDarkMode
        ? AppColorsDark.textSecondary
        : AppColorsLight.textSecondary,
  );

  static TextStyle strikethrough(bool isDarkMode) => TextStyle(
    fontFamily: 'DMSans',
    fontSize: 12,
    decoration: TextDecoration.lineThrough,
    color:
    isDarkMode ? AppColorsDark.textMuted : AppColorsLight.textMuted,
  );
}