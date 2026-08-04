import 'package:flutter/material.dart';

abstract final class AppMotion {
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 160);
  static const Duration standard = Duration(milliseconds: 240);
  static const Duration slow = Duration(milliseconds: 360);

  static const Curve emphasized = Curves.easeOutCubic;
  static const Curve entering = Curves.easeOut;
  static const Curve exiting = Curves.easeIn;

  static Duration accessibleDuration(BuildContext context, Duration preferred) {
    final bool shouldDisableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return shouldDisableAnimations ? Duration.zero : preferred;
  }
}
