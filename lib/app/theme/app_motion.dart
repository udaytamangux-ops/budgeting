import 'package:flutter/material.dart';

abstract final class AppMotion {
  static const Duration tapFeedback = Duration(milliseconds: 110);
  static const Duration selection = Duration(milliseconds: 180);
  static const Duration navigation = Duration(milliseconds: 240);
  static const Duration screenTransition = Duration(milliseconds: 270);
  static const Duration financialValue = Duration(milliseconds: 300);
  static const Duration dialogOrSheet = Duration(milliseconds: 250);

  // Compatibility names for existing motion outside this pass.
  static const Duration instant = tapFeedback;
  static const Duration fast = selection;
  static const Duration standard = navigation;
  static const Duration slow = Duration(milliseconds: 340);

  static const Curve emphasized = Curves.easeOutCubic;
  static const Curve responsive = Curves.easeOutBack;
  static const Curve entering = Curves.easeOut;
  static const Curve exiting = Curves.easeIn;

  static Duration accessibleDuration(BuildContext context, Duration preferred) {
    final bool shouldDisableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return shouldDisableAnimations ? Duration.zero : preferred;
  }
}
