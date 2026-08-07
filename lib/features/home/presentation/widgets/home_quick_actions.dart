import 'package:budgeting_app/app/theme/app_radius.dart';
import 'package:budgeting_app/app/theme/app_semantic_colors.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
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
      icon: Icons.remove_circle_outline,
      accent: context.appColors.expenseAccent,
      surface: context.appColors.expenseSurface,
      pressedSurface: context.appColors.expenseSurfacePressed,
      border: context.appColors.expenseBorder,
      onPressed: onAddExpense,
    );
    final Widget incomeButton = _QuickActionButton(
      key: const ValueKey<String>('home_add_income_button'),
      label: 'Add income',
      semanticLabel: 'Add income transaction',
      icon: Icons.add_circle_outline,
      accent: context.appColors.incomeAccent,
      surface: context.appColors.incomeSurface,
      pressedSurface: context.appColors.incomeSurfacePressed,
      border: context.appColors.incomeBorder,
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
        const SizedBox(width: AppSpacing.xs),
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
      child: OutlinedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll<Size>(Size(0, 48)),
          maximumSize: const WidgetStatePropertyAll<Size>(
            Size(double.infinity, 48),
          ),
          padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
            EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          ),
          shape: const WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(AppRadius.small)),
            ),
          ),
          backgroundColor: WidgetStateProperty.resolveWith<Color>((
            Set<WidgetState> states,
          ) {
            if (states.contains(WidgetState.disabled)) {
              return context.appColors.surfaceSecondary;
            }
            if (states.contains(WidgetState.pressed)) {
              return pressedSurface;
            }
            return surface;
          }),
          foregroundColor: WidgetStateProperty.resolveWith<Color>((
            Set<WidgetState> states,
          ) {
            if (states.contains(WidgetState.disabled)) {
              return context.appColors.textDisabled;
            }
            if (states.contains(WidgetState.pressed)) {
              return context.appColors.textPrimary;
            }
            return context.appColors.textPrimary;
          }),
          side: WidgetStateProperty.resolveWith<BorderSide>((
            Set<WidgetState> states,
          ) {
            if (states.contains(WidgetState.focused)) {
              return BorderSide(
                color: context.appColors.primaryAction,
                width: 2,
              );
            }
            if (states.contains(WidgetState.disabled)) {
              return BorderSide(color: context.appColors.borderSubtle);
            }
            return BorderSide(color: border);
          }),
          overlayColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              size: 18,
              color: WidgetStateColor.resolveWith((Set<WidgetState> states) {
                return states.contains(WidgetState.disabled)
                    ? context.appColors.textDisabled
                    : accent;
              }),
            ),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(label, maxLines: 1, overflow: TextOverflow.fade),
            ),
          ],
        ),
      ),
    );
  }
}
