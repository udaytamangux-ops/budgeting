import 'package:budgeting_app/app/theme/app_radius.dart';
import 'package:budgeting_app/app/theme/app_semantic_colors.dart';
import 'package:budgeting_app/app/theme/app_typography.dart';
import 'package:flutter/material.dart';

abstract final class AppTheme {
  static ThemeData light() =>
      _build(brightness: Brightness.light, colors: AppSemanticColors.light);

  static ThemeData dark() =>
      _build(brightness: Brightness.dark, colors: AppSemanticColors.dark);

  static ThemeData _build({
    required Brightness brightness,
    required AppSemanticColors colors,
  }) {
    final ColorScheme colorScheme = brightness == Brightness.light
        ? ColorScheme.light(
            primary: colors.primaryAction,
            onPrimary: Colors.white,
            primaryContainer: colors.primarySubtle,
            onPrimaryContainer: colors.textPrimary,
            secondary: colors.textSecondary,
            onSecondary: Colors.white,
            secondaryContainer: colors.surfaceSecondary,
            onSecondaryContainer: colors.textPrimary,
            error: colors.destructiveAction,
            onError: Colors.white,
            errorContainer: colors.dangerSubtle,
            onErrorContainer: colors.destructiveAction,
            surface: colors.surfacePrimary,
            onSurface: colors.textPrimary,
            onSurfaceVariant: colors.textSecondary,
            outline: colors.borderStrong,
            outlineVariant: colors.borderSubtle,
          )
        : ColorScheme.dark(
            primary: colors.primaryAction,
            onPrimary: const Color(0xFF101323),
            primaryContainer: colors.primarySubtle,
            onPrimaryContainer: colors.textPrimary,
            secondary: colors.textSecondary,
            onSecondary: const Color(0xFF111319),
            secondaryContainer: colors.surfaceSecondary,
            onSecondaryContainer: colors.textPrimary,
            error: colors.destructiveAction,
            onError: const Color(0xFF260504),
            errorContainer: colors.dangerSubtle,
            onErrorContainer: colors.destructiveAction,
            surface: colors.surfacePrimary,
            onSurface: colors.textPrimary,
            onSurfaceVariant: colors.textSecondary,
            outline: colors.borderStrong,
            outlineVariant: colors.borderSubtle,
          );
    final ThemeData base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: colors.canvas,
      colorScheme: colorScheme,
      extensions: <ThemeExtension<dynamic>>[colors],
    );
    final TextTheme textTheme = AppTypography.textTheme(
      base.textTheme,
      textPrimary: colors.textPrimary,
      textSecondary: colors.textSecondary,
    );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: colors.canvas,
        foregroundColor: colors.textPrimary,
        titleTextStyle: textTheme.titleLarge,
      ),
      bottomAppBarTheme: BottomAppBarThemeData(
        color: colors.surfacePrimary,
        elevation: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surfaceElevated,
        surfaceTintColor: Colors.transparent,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surfaceElevated,
        modalBackgroundColor: colors.surfaceElevated,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfacePrimary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(AppRadius.small),
          ),
          borderSide: BorderSide(color: colors.borderStrong),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(AppRadius.small),
          ),
          borderSide: BorderSide(color: colors.borderStrong),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(AppRadius.small),
          ),
          borderSide: BorderSide(color: colors.primaryAction, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(AppRadius.small),
          ),
          borderSide: BorderSide(color: colors.destructiveAction),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(AppRadius.small),
          ),
          borderSide: BorderSide(color: colors.destructiveAction, width: 2),
        ),
        labelStyle: TextStyle(color: colors.textSecondary),
        floatingLabelStyle: TextStyle(color: colors.textPrimary),
        errorMaxLines: 2,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 52),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.small)),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 52),
          side: BorderSide(color: colors.borderStrong),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.small)),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          textStyle: textTheme.labelLarge,
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: colors.surfacePrimary,
        selectedColor: colors.primarySubtle,
        side: BorderSide(color: colors.borderSubtle),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.small)),
        ),
        labelStyle: textTheme.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      ),
      dividerTheme: DividerThemeData(
        color: colors.borderSubtle,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.primaryAction,
        linearTrackColor: colors.surfaceSecondary,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: brightness == Brightness.dark
            ? colors.surfaceElevated
            : colors.textPrimary,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: brightness == Brightness.dark
              ? colors.textPrimary
              : Colors.white,
        ),
      ),
    );
  }
}
