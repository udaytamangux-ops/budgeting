import 'package:budgeting_app/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

@immutable
final class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.canvas,
    required this.surfacePrimary,
    required this.surfaceSecondary,
    required this.surfaceElevated,
    required this.recordedBalanceSurface,
    required this.recordedBalanceBorder,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.borderSubtle,
    required this.borderStrong,
    required this.primaryAction,
    required this.primaryActionPressed,
    required this.primarySubtle,
    required this.incomeAccent,
    required this.incomeSurface,
    required this.incomeSurfacePressed,
    required this.incomeBorder,
    required this.expenseAccent,
    required this.expenseText,
    required this.expenseAccentStrong,
    required this.expenseSurface,
    required this.expenseSurfacePressed,
    required this.expenseBorder,
    required this.destructiveAction,
    required this.dangerSubtle,
    required this.balancePositive,
    required this.positiveSubtle,
    required this.warning,
    required this.warningSubtle,
  });

  static const AppSemanticColors light = AppSemanticColors(
    canvas: AppColors.background,
    surfacePrimary: AppColors.surfacePrimary,
    surfaceSecondary: AppColors.surfaceSecondary,
    surfaceElevated: AppColors.surfacePrimary,
    recordedBalanceSurface: AppColors.recordedBalanceSurface,
    recordedBalanceBorder: AppColors.recordedBalanceBorder,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    textDisabled: AppColors.textDisabled,
    borderSubtle: AppColors.borderSubtle,
    borderStrong: AppColors.borderStrong,
    primaryAction: AppColors.primaryAction,
    primaryActionPressed: AppColors.primaryActionPressed,
    primarySubtle: AppColors.primarySubtle,
    incomeAccent: AppColors.incomeAccent,
    incomeSurface: AppColors.incomeSurface,
    incomeSurfacePressed: AppColors.incomeSurfacePressed,
    incomeBorder: AppColors.incomeBorder,
    expenseAccent: AppColors.expenseAccent,
    expenseText: AppColors.expenseText,
    expenseAccentStrong: AppColors.expenseAccentStrong,
    expenseSurface: AppColors.expenseSurface,
    expenseSurfacePressed: AppColors.expenseSurfacePressed,
    expenseBorder: AppColors.expenseBorder,
    destructiveAction: AppColors.destructiveAction,
    dangerSubtle: AppColors.dangerSubtle,
    balancePositive: AppColors.balancePositive,
    positiveSubtle: AppColors.positiveSubtle,
    warning: AppColors.budgetWarning,
    warningSubtle: AppColors.warningSubtle,
  );

  static const AppSemanticColors dark = AppSemanticColors(
    canvas: Color(0xFF101218),
    surfacePrimary: Color(0xFF191C24),
    surfaceSecondary: Color(0xFF222631),
    surfaceElevated: Color(0xFF292D38),
    recordedBalanceSurface: Color(0xFF252A42),
    recordedBalanceBorder: Color(0xFF3B4262),
    textPrimary: Color(0xFFF5F6FA),
    textSecondary: Color(0xFFBAC0CC),
    textDisabled: Color(0xFF7B8290),
    borderSubtle: Color(0xFF303541),
    borderStrong: Color(0xFF494F5D),
    primaryAction: Color(0xFF91A0FF),
    primaryActionPressed: Color(0xFFAAB5FF),
    primarySubtle: Color(0xFF293052),
    incomeAccent: Color(0xFF62D3AA),
    incomeSurface: Color(0xFF18372D),
    incomeSurfacePressed: Color(0xFF21493B),
    incomeBorder: Color(0xFF316A57),
    expenseAccent: Color(0xFFFF9A93),
    expenseText: Color(0xFFFFAAA4),
    expenseAccentStrong: Color(0xFFFF746B),
    expenseSurface: Color(0xFF3B2426),
    expenseSurfacePressed: Color(0xFF4D2C2E),
    expenseBorder: Color(0xFF75413F),
    destructiveAction: Color(0xFFFF817A),
    dangerSubtle: Color(0xFF3B2022),
    balancePositive: Color(0xFF62D3AA),
    positiveSubtle: Color(0xFF18372D),
    warning: Color(0xFFF3C66D),
    warningSubtle: Color(0xFF3A301E),
  );

  final Color canvas;
  final Color surfacePrimary;
  final Color surfaceSecondary;
  final Color surfaceElevated;
  final Color recordedBalanceSurface;
  final Color recordedBalanceBorder;
  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;
  final Color borderSubtle;
  final Color borderStrong;
  final Color primaryAction;
  final Color primaryActionPressed;
  final Color primarySubtle;
  final Color incomeAccent;
  final Color incomeSurface;
  final Color incomeSurfacePressed;
  final Color incomeBorder;
  final Color expenseAccent;
  final Color expenseText;
  final Color expenseAccentStrong;
  Color get expenseIconAccent => expenseAccentStrong;
  final Color expenseSurface;
  final Color expenseSurfacePressed;
  final Color expenseBorder;
  final Color destructiveAction;
  Color get dangerAction => destructiveAction;
  final Color dangerSubtle;
  final Color balancePositive;
  final Color positiveSubtle;
  final Color warning;
  final Color warningSubtle;

  @override
  AppSemanticColors copyWith() => this;

  @override
  AppSemanticColors lerp(AppSemanticColors? other, double t) {
    return t < 0.5 || other == null ? this : other;
  }
}

extension AppSemanticColorsContext on BuildContext {
  AppSemanticColors get appColors {
    final ThemeData theme = Theme.of(this);
    return theme.extension<AppSemanticColors>() ??
        (theme.brightness == Brightness.dark
            ? AppSemanticColors.dark
            : AppSemanticColors.light);
  }
}
