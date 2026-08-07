import 'package:budgeting_app/app/theme/app_radius.dart';
import 'package:budgeting_app/app/theme/app_semantic_colors.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:flutter/material.dart';

final class TransactionTypeSelector extends StatelessWidget {
  const TransactionTypeSelector({
    required this.value,
    required this.isEnabled,
    required this.onChanged,
    super.key,
  });

  final TransactionType value;
  final bool isEnabled;
  final ValueChanged<TransactionType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Transaction type',
      child: Row(
        children: <Widget>[
          Expanded(
            child: _TransactionTypeOption(
              key: const ValueKey<String>('transaction_type_expense'),
              type: TransactionType.expense,
              label: 'Expense',
              icon: Icons.remove_circle_outline,
              isSelected: value == TransactionType.expense,
              isEnabled: isEnabled,
              onTap: () => onChanged(TransactionType.expense),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: _TransactionTypeOption(
              key: const ValueKey<String>('transaction_type_income'),
              type: TransactionType.income,
              label: 'Income',
              icon: Icons.add_circle_outline,
              isSelected: value == TransactionType.income,
              isEnabled: isEnabled,
              onTap: () => onChanged(TransactionType.income),
            ),
          ),
        ],
      ),
    );
  }
}

final class _TransactionTypeOption extends StatelessWidget {
  const _TransactionTypeOption({
    required this.type,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.isEnabled,
    required this.onTap,
    super.key,
  });

  final TransactionType type;
  final String label;
  final IconData icon;
  final bool isSelected;
  final bool isEnabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isExpense = type == TransactionType.expense;
    final Color selectedSurface = isExpense
        ? context.appColors.expenseSurface
        : context.appColors.incomeSurface;
    final Color selectedPressedSurface = isExpense
        ? context.appColors.expenseSurfacePressed
        : context.appColors.incomeSurfacePressed;
    final Color selectedText = isExpense
        ? context.appColors.expenseText
        : context.appColors.incomeAccent;
    final Color selectedIcon = isExpense
        ? context.appColors.expenseIconAccent
        : context.appColors.incomeAccent;
    final Color selectedBorder = isExpense
        ? context.appColors.expenseBorder
        : context.appColors.incomeBorder;
    final Color textColor = !isEnabled
        ? context.appColors.textDisabled
        : isSelected
        ? selectedText
        : context.appColors.textSecondary;
    final Color iconColor = !isEnabled
        ? context.appColors.textDisabled
        : isSelected
        ? selectedIcon
        : context.appColors.textSecondary;
    return Semantics(
      button: true,
      selected: isSelected,
      enabled: isEnabled,
      label: '$label transaction type',
      excludeSemantics: true,
      onTap: isEnabled ? onTap : null,
      child: Material(
        color: isSelected
            ? selectedSurface
            : context.appColors.surfaceSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          side: BorderSide(
            color: isSelected ? selectedBorder : context.appColors.borderSubtle,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: isEnabled ? onTap : null,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          overlayColor: WidgetStateProperty.resolveWith<Color?>((
            Set<WidgetState> states,
          ) {
            if (states.contains(WidgetState.pressed)) {
              return isSelected
                  ? selectedPressedSurface
                  : context.appColors.surfacePrimary;
            }
            return null;
          }),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(icon, color: iconColor, size: 20),
                  const SizedBox(width: AppSpacing.xs),
                  Flexible(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: textColor,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
