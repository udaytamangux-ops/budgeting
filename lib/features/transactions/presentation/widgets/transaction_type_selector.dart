import 'package:budgeting_app/app/theme/app_colors.dart';
import 'package:budgeting_app/app/theme/app_motion.dart';
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
    final bool isExpense = value == TransactionType.expense;
    final Duration duration = AppMotion.accessibleDuration(
      context,
      AppMotion.selection,
    );
    return Semantics(
      container: true,
      label: 'Transaction type',
      child: Container(
        key: const ValueKey<String>('transaction_type_segmented_control'),
        padding: const EdgeInsets.all(AppSpacing.xxs),
        decoration: BoxDecoration(
          color: AppColors.surfaceTinted,
          borderRadius: BorderRadius.circular(AppRadius.inputAndChip),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: AnimatedAlign(
                key: const ValueKey<String>('transaction_type_indicator'),
                alignment: isExpense
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                duration: duration,
                curve: AppMotion.emphasized,
                child: FractionallySizedBox(
                  widthFactor: 0.5,
                  heightFactor: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: isExpense
                          ? AppColors.expenseSoft
                          : AppColors.incomeSoft,
                      borderRadius: BorderRadius.circular(
                        AppRadius.compactControl,
                      ),
                      border: Border.all(
                        color: isExpense
                            ? AppColors.expenseBorder
                            : AppColors.incomeBorder,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: _TransactionTypeOption(
                    key: const ValueKey<String>('transaction_type_expense'),
                    type: TransactionType.expense,
                    label: 'Expense',
                    icon: Icons.north_east_rounded,
                    isSelected: isExpense,
                    isEnabled: isEnabled,
                    onTap: () => onChanged(TransactionType.expense),
                  ),
                ),
                Expanded(
                  child: _TransactionTypeOption(
                    key: const ValueKey<String>('transaction_type_income'),
                    type: TransactionType.income,
                    label: 'Income',
                    icon: Icons.south_west_rounded,
                    isSelected: !isExpense,
                    isEnabled: isEnabled,
                    onTap: () => onChanged(TransactionType.income),
                  ),
                ),
              ],
            ),
          ],
        ),
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
    final Color selectedColor = isExpense
        ? AppColors.expenseText
        : AppColors.incomeAccent;
    final Color color = !isEnabled
        ? AppColors.textDisabled
        : isSelected
        ? selectedColor
        : AppColors.textSecondary;
    return Semantics(
      button: true,
      selected: isSelected,
      enabled: isEnabled,
      label: '$label transaction type',
      excludeSemantics: true,
      onTap: isEnabled ? onTap : null,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppRadius.compactControl),
        overlayColor: WidgetStatePropertyAll<Color>(
          selectedColor.withValues(alpha: 0.08),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 54),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(icon, color: color, size: 20),
                const SizedBox(width: AppSpacing.xs),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: color,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w600,
                    ),
                  ),
                ),
                AnimatedSwitcher(
                  duration: AppMotion.accessibleDuration(
                    context,
                    AppMotion.selection,
                  ),
                  child: isSelected
                      ? Padding(
                          key: const ValueKey<String>('selected'),
                          padding: const EdgeInsets.only(left: AppSpacing.xs),
                          child: Icon(
                            Icons.check_rounded,
                            color: color,
                            size: 18,
                          ),
                        )
                      : const SizedBox.shrink(
                          key: ValueKey<String>('unselected'),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
