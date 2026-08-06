import 'package:budgeting_app/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

abstract final class AppElevation {
  static const double none = 0;
  static const double raised = 1;

  static const List<BoxShadow> subtleShadow = <BoxShadow>[
    BoxShadow(color: Color(0x0A101828), blurRadius: 12, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> utilityDockShadow = <BoxShadow>[
    BoxShadow(color: Color(0x1217192B), blurRadius: 20, offset: Offset(0, 8)),
  ];

  static const BorderSide subtleBorder = BorderSide(
    color: AppColors.borderSubtle,
  );
}
