import 'package:budgeting_app/app/theme/app_colors.dart';
import 'package:budgeting_app/app/theme/app_radius.dart';
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
        ? AppColors.expenseSurface
        : AppColors.incomeSurface;
    final Color selectedPressedSurface = isExpense
        ? AppColors.expenseSurfacePressed
        : AppColors.incomeSurfacePressed;
    final Color selectedText = isExpense
        ? AppColors.expenseText
        : AppColors.incomeAccent;
    final Color selectedIcon = isExpense
        ? AppColors.expenseIconAccent
        : AppColors.incomeAccent;
    final Color selectedBorder = isExpense
        ? AppColors.expenseBorder
        : AppColors.incomeBorder;
    final Color textColor = !isEnabled
        ? AppColors.textDisabled
        : isSelected
        ? selectedText
        : AppColors.textSecondary;
    final Color iconColor = !isEnabled
        ? AppColors.textDisabled
        : isSelected
        ? selectedIcon
        : AppColors.textSecondary;
    return Semantics(
      button: true,
      selected: isSelected,
      enabled: isEnabled,
      label: '$label transaction type',
      excludeSemantics: true,
      onTap: isEnabled ? onTap : null,
      child: Material(
        color: isSelected ? selectedSurface : AppColors.surfaceSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          side: BorderSide(
            color: isSelected ? selectedBorder : AppColors.borderSubtle,
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
                  : AppColors.surfacePrimary;
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
