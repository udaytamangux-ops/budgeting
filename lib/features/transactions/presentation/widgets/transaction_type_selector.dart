import 'package:budgeting_app/app/theme/app_radius.dart';
import 'package:budgeting_app/app/theme/app_semantic_colors.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/features/financial_activity/domain/entities/financial_activity.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:flutter/material.dart';

final class TransactionTypeSelector extends StatelessWidget {
  TransactionTypeSelector({
    required TransactionType value,
    required this.isEnabled,
    required ValueChanged<TransactionType> onChanged,
    this.showTransfer = false,
    super.key,
  }) : value = value,
       activityValue = value == TransactionType.expense
           ? FinancialActivityType.expense
           : FinancialActivityType.income,
       onChanged = ((FinancialActivityType selected) {
         if (selected == FinancialActivityType.transfer) return;
         onChanged(
           selected == FinancialActivityType.income
               ? TransactionType.income
               : TransactionType.expense,
         );
       });

  const TransactionTypeSelector.activity({
    required FinancialActivityType value,
    required this.isEnabled,
    required this.onChanged,
    this.showTransfer = true,
    super.key,
  }) : value = value == FinancialActivityType.expense
           ? TransactionType.expense
           : value == FinancialActivityType.income
           ? TransactionType.income
           : value,
       activityValue = value;

  /// Retains the legacy [TransactionType] value for the two-mode constructor.
  /// The activity constructor exposes [FinancialActivityType].
  final Object value;
  final FinancialActivityType activityValue;
  final bool isEnabled;
  final ValueChanged<FinancialActivityType> onChanged;
  final bool showTransfer;

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
              type: FinancialActivityType.expense,
              label: 'Expense',
              icon: Icons.remove_circle_outline,
              isSelected: activityValue == FinancialActivityType.expense,
              isEnabled: isEnabled,
              onTap: () => onChanged(FinancialActivityType.expense),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: _TransactionTypeOption(
              key: const ValueKey<String>('transaction_type_income'),
              type: FinancialActivityType.income,
              label: 'Income',
              icon: Icons.add_circle_outline,
              isSelected: activityValue == FinancialActivityType.income,
              isEnabled: isEnabled,
              onTap: () => onChanged(FinancialActivityType.income),
            ),
          ),
          if (showTransfer) ...<Widget>[
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: _TransactionTypeOption(
                key: const ValueKey<String>('transaction_type_transfer'),
                type: FinancialActivityType.transfer,
                label: 'Transfer',
                icon: Icons.swap_horiz,
                isSelected: activityValue == FinancialActivityType.transfer,
                isEnabled: isEnabled,
                onTap: () => onChanged(FinancialActivityType.transfer),
              ),
            ),
          ],
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

  final FinancialActivityType type;
  final String label;
  final IconData icon;
  final bool isSelected;
  final bool isEnabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color selectedSurface = switch (type) {
      FinancialActivityType.expense => context.appColors.expenseSurface,
      FinancialActivityType.income => context.appColors.incomeSurface,
      FinancialActivityType.transfer => context.appColors.primarySubtle,
    };
    final Color selectedPressedSurface = switch (type) {
      FinancialActivityType.expense => context.appColors.expenseSurfacePressed,
      FinancialActivityType.income => context.appColors.incomeSurfacePressed,
      FinancialActivityType.transfer => context.appColors.surfaceSecondary,
    };
    final Color selectedText = switch (type) {
      FinancialActivityType.expense => context.appColors.expenseText,
      FinancialActivityType.income => context.appColors.incomeAccent,
      FinancialActivityType.transfer => context.appColors.primaryAction,
    };
    final Color selectedIcon = switch (type) {
      FinancialActivityType.expense => context.appColors.expenseIconAccent,
      FinancialActivityType.income => context.appColors.incomeAccent,
      FinancialActivityType.transfer => context.appColors.primaryAction,
    };
    final Color selectedBorder = switch (type) {
      FinancialActivityType.expense => context.appColors.expenseBorder,
      FinancialActivityType.income => context.appColors.incomeBorder,
      FinancialActivityType.transfer => context.appColors.primaryAction,
    };
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
