import 'package:budgeting_app/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

abstract final class AppTypography {
  // Inter is bundled with the app and is the offline geometric-humanist
  // fallback for this pass. All roles stay centralized here.
  static const String fontFamily = 'Inter';
  static const List<FontFeature> tabularFigures = <FontFeature>[
    FontFeature.tabularFigures(),
  ];

  static TextTheme textTheme(TextTheme base) {
    final TextTheme inter = base.apply(
      fontFamily: fontFamily,
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );

    return inter.copyWith(
      displaySmall: inter.displaySmall?.copyWith(
        color: AppColors.textPrimary,
        fontSize: 42,
        fontWeight: FontWeight.w600,
        height: 1.05,
        letterSpacing: -1.2,
        fontFeatures: tabularFigures,
      ),
      headlineSmall: inter.headlineSmall?.copyWith(
        color: AppColors.textPrimary,
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: -0.5,
      ),
      titleLarge: inter.titleLarge?.copyWith(
        color: AppColors.textPrimary,
        fontSize: 21,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      titleMedium: inter.titleMedium?.copyWith(
        color: AppColors.textPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      bodyLarge: inter.bodyLarge?.copyWith(
        color: AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodyMedium: inter.bodyMedium?.copyWith(
        color: AppColors.textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      labelLarge: inter.labelLarge?.copyWith(
        color: AppColors.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.35,
      ),
      labelMedium: inter.labelMedium?.copyWith(
        color: AppColors.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.35,
      ),
      bodySmall: inter.bodySmall?.copyWith(
        color: AppColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
      labelSmall: inter.labelSmall?.copyWith(
        color: AppColors.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        height: 1.35,
        letterSpacing: 0.2,
      ),
    );
  }

  static TextStyle financialDisplay(
    BuildContext context, {
    Color color = AppColors.textPrimary,
  }) {
    return Theme.of(context).textTheme.displaySmall!.copyWith(
      color: color,
      fontFeatures: tabularFigures,
    );
  }

  static TextStyle sectionTitle(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge!;
  }
}
