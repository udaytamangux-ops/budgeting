import 'package:budgeting_app/app/theme/app_colors.dart';
import 'package:budgeting_app/app/theme/app_radius.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/core/widgets/pressable_scale.dart';
import 'package:flutter/material.dart';

final class HomeQuickActions extends StatelessWidget {
  const HomeQuickActions({
    required this.onAddExpense,
    required this.onAddIncome,
    super.key,
  });

  final VoidCallback onAddExpense;
  final VoidCallback onAddIncome;

  @override
  Widget build(BuildContext context) {
    final bool shouldStack = MediaQuery.textScalerOf(context).scale(14) > 20;
    final Widget expenseButton = _QuickActionButton(
      key: const ValueKey<String>('home_add_expense_button'),
      label: 'Add expense',
      semanticLabel: 'Add expense transaction',
      icon: Icons.north_east_rounded,
      accent: AppColors.expenseText,
      surface: AppColors.expenseSoft,
      pressedSurface: AppColors.expenseSurfacePressed,
      border: AppColors.expenseBorder,
      onPressed: onAddExpense,
    );
    final Widget incomeButton = _QuickActionButton(
      key: const ValueKey<String>('home_add_income_button'),
      label: 'Add income',
      semanticLabel: 'Add income transaction',
      icon: Icons.south_west_rounded,
      accent: AppColors.incomeAccent,
      surface: AppColors.incomeSoft,
      pressedSurface: AppColors.incomeSurfacePressed,
      border: AppColors.incomeBorder,
      onPressed: onAddIncome,
    );

    if (shouldStack) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          expenseButton,
          const SizedBox(height: AppSpacing.xs),
          incomeButton,
        ],
      );
    }
    return Row(
      children: <Widget>[
        Expanded(child: expenseButton),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: incomeButton),
      ],
    );
  }
}

final class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.label,
    required this.semanticLabel,
    required this.icon,
    required this.accent,
    required this.surface,
    required this.pressedSurface,
    required this.border,
    required this.onPressed,
    super.key,
  });

  final String label;
  final String semanticLabel;
  final IconData icon;
  final Color accent;
  final Color surface;
  final Color pressedSurface;
  final Color border;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: semanticLabel,
      excludeSemantics: true,
      child: PressableScale(
        enabled: onPressed != null,
        child: OutlinedButton(
          onPressed: onPressed,
          style: ButtonStyle(
            minimumSize: const WidgetStatePropertyAll<Size>(Size(0, 58)),
            padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
              EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            ),
            shape: WidgetStatePropertyAll<OutlinedBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.inputAndChip),
              ),
            ),
            backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.disabled)) {
                return AppColors.surfaceSecondary;
              }
              return states.contains(WidgetState.pressed)
                  ? pressedSurface
                  : surface;
            }),
            foregroundColor: WidgetStatePropertyAll<Color>(accent),
            side: WidgetStateProperty.resolveWith<BorderSide>((states) {
              if (states.contains(WidgetState.focused)) {
                return const BorderSide(color: AppColors.brandCobalt, width: 2);
              }
              return BorderSide(
                color: states.contains(WidgetState.disabled)
                    ? AppColors.borderSubtle
                    : border,
              );
            }),
            overlayColor: const WidgetStatePropertyAll<Color>(
              Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.surfacePrimary.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(AppRadius.compactControl),
                ),
                child: Icon(icon, size: 18, color: accent),
              ),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(label, maxLines: 1, overflow: TextOverflow.fade),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
