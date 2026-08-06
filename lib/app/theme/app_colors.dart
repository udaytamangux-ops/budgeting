import 'package:flutter/material.dart';

abstract final class AppColors {
  // Lively Personal Ledger foundations.
  static const Color canvasWarm = Color(0xFFF7F7F3);
  static const Color surfacePrimary = Color(0xFFFFFFFF);
  static const Color surfaceTinted = Color(0xFFF0F2FF);
  static const Color surfaceStrong = Color(0xFF20243B);

  static const Color inkPrimary = Color(0xFF17191F);
  static const Color inkSecondary = Color(0xFF6C7280);
  static const Color inkSecondaryOnWarm = Color(0xFF656B77);
  static const Color inkOnStrong = Color(0xFFFFFFFF);
  static const Color inkOnStrongMuted = Color(0xB8FFFFFF);

  static const Color brandCobalt = Color(0xFF4859E8);
  static const Color brandPressed = Color(0xFF3947C7);
  static const Color brandSoft = Color(0xFFEDEFFF);

  static const Color incomeAccent = Color(0xFF168B65);
  static const Color incomeSoft = Color(0xFFE7F7F0);

  static const Color expenseAccentStrong = Color(0xFFF04438);
  static const Color expenseText = Color(0xFFC43A31);
  static const Color expenseSoft = Color(0xFFFFF0EE);

  static const Color warmAccent = Color(0xFFF4B64A);

  // Compatibility names used by established screens.
  static const Color primaryAction = brandCobalt;
  static const Color primaryActionPressed = brandPressed;
  static const Color primarySubtle = brandSoft;

  static const Color expenseAccent = expenseText;
  static const Color expenseIconAccent = expenseAccentStrong;
  static const Color expenseSurface = expenseSoft;
  static const Color expenseSurfacePressed = Color(0xFFFFE2DE);
  static const Color expenseBorder = Color(0xFFF5C5BF);

  static const Color incomeSurface = incomeSoft;
  static const Color incomeSurfacePressed = Color(0xFFD4F0E4);
  static const Color incomeBorder = Color(0xFFBDE3D3);

  static const Color background = canvasWarm;
  static const Color surfaceSecondary = surfaceTinted;
  static const Color recordedBalanceSurface = surfaceStrong;
  static const Color recordedBalanceBorder = Color(0xFF30364F);

  static const Color textPrimary = inkPrimary;
  static const Color textSecondary = inkSecondaryOnWarm;
  static const Color textDisabled = Color(0xFF98A2B3);

  static const Color borderSubtle = Color(0xFFE2E4EA);
  static const Color borderStrong = Color(0xFFC9CDD7);

  static const Color balancePositive = incomeAccent;
  static const Color positiveSubtle = incomeSoft;

  static const Color budgetWarning = Color(0xFFB45309);
  static const Color warningSubtle = Color(0xFFFFF7E8);

  static const Color categoryVioletAccent = Color(0xFF6D5D92);
  static const Color categoryVioletSurface = Color(0xFFF2EFF8);
  static const Color categoryBlueAccent = Color(0xFF3B718D);
  static const Color categoryBlueSurface = Color(0xFFECF4F7);
  static const Color categoryAmberAccent = Color(0xFF8A6116);
  static const Color categoryAmberSurface = Color(0xFFFFF7E7);
  static const Color categoryTealAccent = Color(0xFF2E746A);
  static const Color categoryTealSurface = Color(0xFFEDF7F4);
  static const Color categoryPlumAccent = Color(0xFF8A496D);
  static const Color categoryPlumSurface = Color(0xFFF8EFF5);
  static const Color categoryIndigoAccent = Color(0xFF4B649F);
  static const Color categoryIndigoSurface = Color(0xFFEEF1F8);
  static const Color categoryEarthAccent = Color(0xFF7B5D3F);
  static const Color categoryEarthSurface = Color(0xFFF7F1EB);
  static const Color categorySlateAccent = Color(0xFF526173);
  static const Color categorySlateSurface = Color(0xFFEEF1F4);

  static const Color dangerAction = Color(0xFFB42318);
  static const Color destructiveAction = dangerAction;
  static const Color dangerSubtle = Color(0xFFFEF3F2);
}
