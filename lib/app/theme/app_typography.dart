import 'package:flutter/material.dart';

abstract final class AppTypography {
  static const List<FontFeature> tabularFigures = <FontFeature>[
    FontFeature.tabularFigures(),
  ];

  static TextTheme textTheme(
    TextTheme base, {
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final TextTheme inter = base.apply(
      fontFamily: 'Inter',
      bodyColor: textPrimary,
      displayColor: textPrimary,
    );

    return inter.copyWith(
      displaySmall: inter.displaySmall?.copyWith(
        color: textPrimary,
        fontSize: 36,
        fontWeight: FontWeight.w700,
        height: 1.1,
        letterSpacing: -1,
        fontFeatures: tabularFigures,
      ),
      headlineSmall: inter.headlineSmall?.copyWith(
        color: textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.25,
      ),
      titleLarge: inter.titleLarge?.copyWith(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.3,
      ),
      titleMedium: inter.titleMedium?.copyWith(
        color: textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      bodyLarge: inter.bodyLarge?.copyWith(
        color: textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodyMedium: inter.bodyMedium?.copyWith(
        color: textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      labelLarge: inter.labelLarge?.copyWith(
        color: textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.35,
      ),
      labelMedium: inter.labelMedium?.copyWith(
        color: textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.35,
      ),
      bodySmall: inter.bodySmall?.copyWith(
        color: textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
    );
  }
}
